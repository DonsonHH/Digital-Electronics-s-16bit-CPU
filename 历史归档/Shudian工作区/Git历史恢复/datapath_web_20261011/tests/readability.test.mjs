import {chromium} from 'file:///C:/Users/Donson/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/playwright/index.mjs';
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {pathToFileURL} from 'node:url';

fs.mkdirSync('review',{recursive:true});
const b=await chromium.launch({executablePath:'C:/Program Files/Google/Chrome/Application/chrome.exe',headless:true});
const p=await b.newPage({viewport:{width:1920,height:1080},acceptDownloads:true});
const errors=[],checks=[];
p.on('pageerror',e=>errors.push(e.message));
const check=(name,passed,detail)=>{checks.push({name,passed:!!passed,...detail===undefined?{}:{detail}});if(!passed)console.log('FAIL',name,detail);};
const settle=()=>p.evaluate(()=>new Promise(r=>requestAnimationFrame(()=>requestAnimationFrame(r))));
const url=process.argv[2]||pathToFileURL(path.resolve('dist/index.html')).href;
await p.goto(url);await p.waitForFunction(()=>window.__CPU_TEST__?.controller);await settle();

check('Requested floating introduction removed',await p.locator('.start-card').count()===0&&!(await p.locator('body').innerText()).includes('顺着一条线，理解整个过程'));
check('Corner counters and decorative page furniture removed',await p.locator('.app-footer,.canvas-status,.browse-footer,.header-badges,.minimap-header').count()===0&&!(await p.locator('body').innerText()).includes('LOCAL · OFFLINE READY'));
check('Print-sheet headings and microtext removed only from page SVG',await p.evaluate(()=>[...document.querySelector('.schematic-host>svg').children].every(e=>!['text','path'].includes(e.tagName.toLowerCase()))));
check('All circuit geometry still matches the audited SVG',await p.evaluate(()=>{
 const original=new DOMParser().parseFromString(window.CPU_SVG,'image/svg+xml');
 const attrs=['d','x','y','x1','x2','y1','y2','cx','cy','r','width','height','points','transform','marker-end'];
 const geometry=root=>[...root.querySelectorAll('.graph path,.graph line,.graph polyline,.graph polygon,.graph circle,.graph rect')].map(e=>[e.tagName,...attrs.map(a=>e.getAttribute(a))]);
 return JSON.stringify(geometry(original))===JSON.stringify(geometry(document.querySelector('.schematic-host')));
}));
check('Default view opens the readable PC, not a whole-sheet thumbnail',await p.evaluate(()=>{const c=window.__CPU_TEST__.controller,el=document.querySelector('[data-node="pc"] .port-label');return window.__CPU_TEST__.selection.id==='pc'&&parseFloat(getComputedStyle(el).fontSize)*el.getScreenCTM().a>=15&&!c.svg.classList.contains('low-detail');}));
const fontSizes=await p.evaluate(()=>Object.fromEntries(['.purpose','.behavior','.inspector-tabs button','.signal-item code','.module-item strong','.canvas-tools button','.search-field input','.header-actions button','.guide-choice code'].map(s=>[s,document.querySelector(s)?parseFloat(getComputedStyle(document.querySelector(s)).fontSize):null])));
check('UI body is 16px, port list 15px and common controls at least 14px',fontSizes['.purpose']>=16&&fontSizes['.behavior']>=16&&fontSizes['.signal-item code']>=15&&Object.values(fontSizes).filter(v=>v!==null).every(v=>v>=14),fontSizes);

const clickNode=async id=>{await p.evaluate(()=>window.__CPU_TEST__.controller.overview());await settle();const box=await p.locator(`.schematic-host [data-node="${id}"]>rect`).first().boundingBox();await p.mouse.click(box.x+box.width/2,box.y+box.height/2);await settle();};
const nodeMetrics=[];
for(const id of await p.evaluate(()=>window.CPU_MODEL.nodes.map(n=>n.id))){
 await clickNode(id);
 nodeMetrics.push(await p.evaluate(id=>{const el=document.querySelector(`[data-node="${id}"] .port-label`),c=window.__CPU_TEST__.controller;return {id,selected:window.__CPU_TEST__.selection?.id===id,px:parseFloat(getComputedStyle(el).fontSize)*el.getScreenCTM().a,detail:!c.svg.classList.contains('low-detail')};},id));
}
check('All 37 actual canvas node clicks focus with readable port text',nodeMetrics.every(n=>n.selected&&n.px>=15&&n.detail),{count:nodeMetrics.length,minPortPx:Math.min(...nodeMetrics.map(n=>n.px)),failures:nodeMetrics.filter(n=>!n.selected||n.px<15||!n.detail)});
await p.getByRole('button',{name:'Overview',exact:true}).click();await settle();
check('Overview hides tiny port text and retains all navigation labels',await p.evaluate(()=>document.querySelector('.schematic-host>svg').classList.contains('low-detail')&&[...document.querySelectorAll('.schematic-host .nav-label')].every(e=>getComputedStyle(e).display!=='none'&&Number(getComputedStyle(e.parentElement).opacity)>0)&&[...document.querySelectorAll('.schematic-host .port-label')].every(e=>getComputedStyle(e).display==='none')));
const labelOverflow=await p.evaluate(()=>window.CPU_MODEL.nodes.filter(n=>{const el=document.querySelector(`[data-node="${n.id}"] .nav-label`),r=el.getBBox();return r.x<n.x-2||r.y<n.y-2||r.x+r.width>n.x+n.width+2||r.y+r.height>n.y+n.height+2;}).map(n=>n.id));
check('Overview names remain within their real module boxes',labelOverflow.length===0,labelOverflow);
await clickNode('rf');
check('Reading view restores complete port and register detail',await p.locator('.schematic-host [data-node="rf"] .port-label').first().isVisible()&&await p.locator('.inspector-heading h2').innerText()==='regfile4x16');
check('Selected wires use restrained stroke widths',await p.evaluate(()=>[...document.querySelectorAll('.net.active .wire')].every(e=>parseFloat(getComputedStyle(e).strokeWidth)<=4.5)));

const sizes=[[1920,1080],[1536,960],[1366,900],[1100,900],[900,900],[820,850],[760,850],[480,850],[375,850]];
for(const [width,height]of sizes){
 await p.setViewportSize({width,height});await settle();
 const state=await p.evaluate(()=>{const host=document.querySelector('.schematic-host'),c=window.__CPU_TEST__.controller.camera;return {width:innerWidth,scroll:document.documentElement.scrollWidth,scale:host.clientWidth/c.w,visible:!!host.clientWidth};});
 check('Readable responsive layout at '+width+'px',state.scroll<=width&&(!state.visible||state.scale>=.919),state);
}
await p.setViewportSize({width:480,height:850});await p.getByRole('button',{name:'浏览模块',exact:true}).click();
await p.getByRole('textbox',{name:'搜索模块或信号'}).fill('rf');await p.getByRole('textbox',{name:'搜索模块或信号'}).press('Enter');await settle();
await p.getByRole('button',{name:'电路画布',exact:true}).click();await settle();
check('Narrow-screen module focus keeps title start and input edge visible',await p.evaluate(()=>{const host=document.querySelector('.schematic-host').getBoundingClientRect(),title=document.querySelector('[data-node="rf"] .node-title').getBoundingClientRect();return title.left>=host.left&&title.left<host.right&&title.top>=host.top&&title.top<host.bottom;}));
// A hidden canvas must not turn a valid camera into Infinity when shortcuts fire.
await p.getByRole('button',{name:'节点详情',exact:true}).click();const before=await p.evaluate(()=>({...window.__CPU_TEST__.controller.camera}));await p.keyboard.press('+');await settle();
check('Zoom shortcuts on a hidden canvas do not corrupt the view',await p.evaluate(before=>JSON.stringify(window.__CPU_TEST__.controller.camera)===JSON.stringify(before),before));
// Import/restore must win over an older deferred node-focus request.
await p.evaluate(()=>{const c=window.__CPU_TEST__.controller;c.focusNode('alu');c.restore({x:2300,y:1500,w:1000,h:800});});
await p.getByRole('button',{name:'电路画布',exact:true}).click();await settle();
check('Restoring a hidden canvas supersedes stale pending node focus',await p.evaluate(()=>{const c=window.__CPU_TEST__.controller.camera;return Math.abs(c.x+c.w/2-2800)<1&&Math.abs(c.y+c.h/2-1900)<1;}));
await p.setViewportSize({width:1536,height:960});await settle();
await p.getByRole('button',{name:'Overview',exact:true}).click();await settle();
const svg=await p.evaluate(()=>window.__CPU_TEST__.controller.exportSvg());
check('Export has all 134 nets and no temporary navigation labels',!svg.includes('class="nav-label"')&&!svg.includes('class="low-detail"')&&(svg.match(/class="net"/g)||[]).length===134);
await p.getByRole('button',{name:'保存进度',exact:true}).click();await p.locator('[data-sonner-toast]').first().waitFor();
check('One root toaster with 15px action feedback',await p.locator('[data-sonner-toaster]').count()===1&&await p.locator('[data-sonner-toast]').first().evaluate(e=>parseFloat(getComputedStyle(e).fontSize)>=15));
check('No runtime errors during readability checks',errors.length===0,errors);
const result={target:url,buildSha256:crypto.createHash('sha256').update(fs.readFileSync('dist/index.html')).digest('hex'),pass:checks.every(c=>c.passed),checks};
fs.writeFileSync('review/readability-tests.json',JSON.stringify(result,null,2));console.log(JSON.stringify({pass:result.pass,checks:checks.length,failed:checks.filter(c=>!c.passed)},null,2));
await b.close();if(!result.pass)process.exitCode=1;
