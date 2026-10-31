import {chromium} from 'file:///C:/Users/Donson/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/playwright/index.mjs';
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {pathToFileURL} from 'node:url';

fs.mkdirSync('review/focus',{recursive:true});
const b=await chromium.launch({executablePath:'C:/Program Files/Google/Chrome/Application/chrome.exe',headless:true});
const p=await b.newPage({viewport:{width:1920,height:1080},acceptDownloads:true});
const errors=[],checks=[];p.on('pageerror',e=>errors.push(e.message));
const check=(name,passed,detail)=>{checks.push({name,passed:!!passed,...detail===undefined?{}:{detail}});if(!passed)console.log('FAIL',name,detail);};
const settle=()=>p.evaluate(()=>new Promise(r=>requestAnimationFrame(()=>requestAnimationFrame(r))));
const url=process.argv[2]||pathToFileURL(path.resolve('dist/index.html')).href;
const search=async value=>{const input=p.getByRole('textbox',{name:'搜索模块或信号'});await input.fill(value);await input.press('Enter');await settle();};
const opacity=id=>p.locator(`.schematic-host [data-node="${id}"]`).evaluate(e=>Number(getComputedStyle(e).opacity));
await p.goto(url);await p.waitForFunction(()=>window.__CPU_TEST__?.controller);

await search('rf');
const detail={rf:await opacity('rf'),dm:await opacity('dm')};
await p.getByRole('button',{name:'Overview',exact:true}).click();await settle();
const overview={rf:await opacity('rf'),dm:await opacity('dm')};
check('Selecting RF dims unrelated DM both in detail and overview despite their shared clock',detail.rf===1&&overview.rf===1&&detail.dm<=.25&&overview.dm<=.25,{detail,overview});
await p.screenshot({path:'review/focus/01-rf-overview.png'});

const focusCues=await p.evaluate(()=>{
 const selected=document.querySelector('.schematic-host [data-node="rf"]>rect'),peer=document.querySelector('.schematic-host [data-node="wb_mux"]>rect');
 const style=getComputedStyle(selected),peerStyle=getComputedStyle(peer);
 const nodes=window.CPU_MODEL.nodes,mini=document.querySelectorAll('.minimap .mini-node');
 return {outline:style.stroke!==peerStyle.stroke&&parseFloat(style.strokeWidth)*(style.vectorEffect==='non-scaling-stroke'?1:selected.getScreenCTM().a)>=2,rf:Number(getComputedStyle(mini[nodes.findIndex(n=>n.id==='rf')]).opacity),dm:Number(getComputedStyle(mini[nodes.findIndex(n=>n.id==='dm')]).opacity)};
});
check('Selected module stands out by outline and the minimap mirrors the dimmed context',focusCues.outline&&focusCues.rf===1&&focusCues.dm<=.25,focusCues);

// Assert the visible result from independent graph adjacency, not renderer classes.
async function inspectFocus(s){return p.evaluate(s=>{
 const m=window.CPU_MODEL,expected=new Set();
 const nets=m.nets.filter(n=>s.kind==='net'?n.id===s.id:n.sourceNode===s.id||n.targets.some(t=>t.node===s.id));
 if(s.kind==='node')expected.add(s.id);
 for(const n of nets){expected.add(n.sourceNode);if(s.kind==='net'||n.sourceNode===s.id)for(const t of n.targets)expected.add(t.node);}
 const errors=[];
 for(const n of m.nodes){const el=document.querySelector(`.schematic-host [data-node="${n.id}"]`),opacity=Number(getComputedStyle(el).opacity);if(expected.has(n.id)?opacity!==1:opacity>.25)errors.push(n.id+': '+opacity);}
 for(const n of m.nets){const el=document.querySelector(`.schematic-host .net[data-net="${n.id}"]`),opacity=Number(getComputedStyle(el).opacity);if(nets.some(x=>x.id===n.id)?opacity!==1:opacity>.15)errors.push(n.signal+': '+opacity);}
 const minis=[...document.querySelectorAll('.minimap .mini-node')];
 for(const [i,n]of m.nodes.entries()){const opacity=Number(getComputedStyle(minis[i]).opacity);if(expected.has(n.id)?opacity!==1:opacity>.25)errors.push('mini '+n.id+': '+opacity);}
 return {errors,expected:[...expected],selected:window.__CPU_TEST__.selection};
},s);}
const nodes=await p.evaluate(()=>window.CPU_MODEL.nodes.map(n=>n.id));
const moduleFailures=[];
for(const id of nodes){
 await p.getByRole('button',{name:'Overview',exact:true}).click();await settle();
 const box=await p.locator(`.schematic-host [data-node="${id}"]>rect`).first().boundingBox();
 await p.mouse.click(box.x+box.width/2,box.y+box.height/2);await settle();
 const state=await inspectFocus({kind:'node',id});
 if(state.selected?.kind!=='node'||state.selected.id!==id||state.errors.length)moduleFailures.push({id,...state});
}
check('All 37 modules including dimmed nodes remain clickable with exact direct-neighbor focus',moduleFailures.length===0,{count:nodes.length,failures:moduleFailures});
const nets=await p.evaluate(()=>window.CPU_MODEL.nets.map(n=>({id:n.id,signal:n.signal})));
const netFailures=[];
for(const n of nets){await p.evaluate(id=>window.__CPU_TEST__.pick({kind:'net',id},false),n.id);await settle();const state=await inspectFocus({kind:'net',id:n.id});if(state.errors.length)netFailures.push({signal:n.signal,...state});}
check('All 134 signals retain their complete fanout while every unrelated module is dimmed',netFailures.length===0,{count:nets.length,failures:netFailures});

await search('clk');
check('Explicit clock selection still reveals every real clock receiver',await opacity('rf')===1&&await opacity('dm')===1);
await search('wb_data');await p.getByRole('button',{name:'Overview',exact:true}).click();await settle();
await p.screenshot({path:'review/focus/02-wb-data-overview.png'});
const wb=nets.find(n=>n.signal==='wb_data');
check('Overview keeps unrelated blocks dim for a selected net',(await inspectFocus({kind:'net',id:wb.id})).errors.length===0);
const overviewWirePx=await p.locator(`.schematic-host .net[data-net="${wb.id}"] .wire`).first().evaluate(e=>{const s=getComputedStyle(e);return parseFloat(s.strokeWidth)*(s.vectorEffect==='non-scaling-stroke'?1:e.getScreenCTM().a);});
check('The selected signal stays visibly traceable at overview scale',overviewWirePx>=1.2,{screenStrokePx:overviewWirePx});
for(const choice of ['data','control','full']){await p.getByLabel('线路强调').selectOption(choice);await settle();}
check('Changing wire emphasis does not override explicit selection',(await inspectFocus({kind:'net',id:wb.id})).errors.length===0);
await p.locator('.endpoint .locate').first().click();await settle();
check('Only locate preserves the selected net and its endpoint focus',(await inspectFocus({kind:'net',id:wb.id})).errors.length===0&&await p.locator('.inspector-heading h2').innerText()==='wb_data');

await search('alu');
const netPoint=await p.evaluate(()=>{const n=window.CPU_MODEL.nodes.find(n=>n.id==='alu'),c=window.__CPU_TEST__.controller.camera,r=document.querySelector('.schematic-host').getBoundingClientRect();return {x:r.left+(n.x+80+n.width+20-c.x)/c.w*r.width,y:r.top+(n.y+285+n.outs[0].y-c.y)/c.h*r.height};});
await p.mouse.click(netPoint.x,netPoint.y);await settle();
const aluResult=nets.find(n=>n.signal==='alu_result');
check('Actual wire click selects the complete signal with the correct dimmed surroundings',await p.locator('.inspector-heading h2').innerText()==='alu_result'&&(await inspectFocus({kind:'net',id:aluResult.id})).errors.length===0);
await p.getByRole('button',{name:'返回上一步',exact:true}).click();await settle();
check('Back restores the previous module focus',(await inspectFocus({kind:'node',id:'alu'})).errors.length===0&&await p.locator('.inspector-heading h2').innerText()==='alu16 + CLA16');

await search('STR');await p.getByRole('button',{name:'Next →',exact:true}).click();await settle();
const guideSelection=await p.evaluate(()=>window.__CPU_TEST__.selection);
check('Instruction walkthroughs apply the same full-signal focus',(await inspectFocus(guideSelection)).errors.length===0);
const navigationFeedback={toasts:await p.locator('[data-sonner-toast]').count(),containers:await p.locator('[data-sonner-toaster]').count()};
check('Ordinary selection and navigation do not create toast noise',navigationFeedback.toasts===0&&navigationFeedback.containers<=1,navigationFeedback);

await search('rf');
const save=await Promise.all([p.waitForEvent('download'),p.getByRole('button',{name:'保存进度',exact:true}).click()]);
const session=fs.readFileSync(await save[0].path());
await p.getByRole('button',{name:'Clear',exact:true}).click();await settle();
check('Clear restores every module and net including the minimap',await p.evaluate(()=>[...document.querySelectorAll('.schematic-host .node,.schematic-host .net,.minimap .mini-node')].every(e=>Number(getComputedStyle(e).opacity)===1)&&!document.querySelector('.schematic-host .picked')));
await p.getByRole('button',{name:'Overview',exact:true}).click();await settle();await p.screenshot({path:'review/focus/03-cleared-overview.png'});
await p.locator('input[type=file]').setInputFiles({name:'focus-session.json',mimeType:'application/json',buffer:session});await settle();
check('Imported progress restores the correct focus without stale classes',(await inspectFocus({kind:'node',id:'rf'})).errors.length===0&&await p.locator('.inspector-heading h2').innerText()==='regfile4x16');
const exported=await Promise.all([p.waitForEvent('download'),p.getByRole('button',{name:'Export SVG',exact:false}).click()]);
const svg=fs.readFileSync(await exported[0].path(),'utf8');
const classes=[...svg.matchAll(/class="([^"]*)"/g)].flatMap(m=>m[1].split(/\s+/));
check('Export removes focus styling without losing any node or net',!classes.some(c=>['selected','active','picked','net-selection','low-detail','nav-label'].includes(c))&&(svg.match(/class="node"/g)||[]).length===37&&(svg.match(/class="net"/g)||[]).length===134);

await p.setViewportSize({width:760,height:850});await p.getByRole('button',{name:'电路画布',exact:true}).click();await settle();
await p.getByRole('button',{name:'Overview',exact:true}).click();await settle();
check('Narrow-screen overview retains the focus contrast',(await inspectFocus({kind:'node',id:'rf'})).errors.length===0);
await p.emulateMedia({reducedMotion:'reduce'});await p.getByRole('button',{name:'浏览模块',exact:true}).click();await search('alu');await p.getByRole('button',{name:'电路画布',exact:true}).click();await settle();
check('Reduced-motion mode retains immediate focus feedback',(await inspectFocus({kind:'node',id:'alu'})).errors.length===0);
await p.screenshot({path:'review/focus/04-narrow-selected.png'});
check('No runtime errors',errors.length===0,errors);

const result={target:url,buildSha256:crypto.createHash('sha256').update(fs.readFileSync('dist/index.html')).digest('hex'),pass:checks.every(c=>c.passed)&&errors.length===0,checks,errors};
fs.writeFileSync('review/focus-tests.json',JSON.stringify(result,null,2));console.log(JSON.stringify({pass:result.pass,checks:checks.length,failed:checks.filter(c=>!c.passed),errors},null,2));
await b.close();if(!result.pass)process.exitCode=1;
