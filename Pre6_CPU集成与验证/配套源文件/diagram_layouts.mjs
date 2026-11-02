// Presentation-sized complete diagrams. Every named module/role exists in AC1.
import fs from 'node:fs/promises';
import path from 'node:path';
const C={data:'#24384B',ctrl:'#2867A5',fwd:'#087C7C',kill:'#BD4E26',pale:'#EAF3F7',mint:'#E5F4F1',grid:'#BCCEDB',white:'#FFFFFF'};
const diagrams={};let a=[];
function text(t,x,y,w,h,size=23,fill=C.data,bold=false,align='left'){a.push({kind:'text',text:t,x,y,w,h,size,fill,bold,align});}
function rect(x,y,w,h,fill=C.white,stroke=C.grid,width=1.3){a.push({kind:'rect',x,y,w,h,fill,stroke,width});}
function box(t,x,y,w,h,fill=C.pale,size=23){rect(x,y,w,h,fill);text(t,x+6,y+6,w-12,h-12,size,C.data,true,'center');}
function wire(points,stroke=C.data,width=2,arrow=true,dashed=false){a.push({kind:'path',points,stroke,width,arrow,dashed});}
function dot(x,y,fill=C.fwd){a.push({kind:'circle',x:x-3,y:y-3,w:6,h:6,fill,stroke:'none',width:0});}
function finish(id,title){diagrams[id]={width:1280,height:720,title,objects:a};a=[];}

// 05: Complete responsibility hierarchy and connected datapath. FSM is global.
box('Mode FSM\nRUN / drain / stopped',52,149,276,67,C.pale,25);
box('Cross-stage hazard / event arbitration\nRAW readiness, age, redirect, halt, fault',351,149,606,67,C.mint,24);
box('ID decode\nopcode / use / CW',980,149,248,67,C.pale,24);
wire([[328,181],[351,181]],C.ctrl);wire([[980,181],[957,181]],C.ctrl);
const xs=[52,292,532,772,1012];
const roles=['IFCU\nfetch / PC enable','IDCU\nissue / hold / cancel','EXCU\nALU / redirect / stop','MEMCU\naccess / range','WBCU\nRF / flags enables'];
const dp=['pc16\nnext PC + PC state','regfile4x16\nimm_ext16','operand_forward\nalu16 / branch_target16\nZ candidate select','EA / store payload\nqualified memory bus','WB result select\nRF write / flags_reg'];
xs.forEach((x,i)=>{
 box(roles[i],x,282,216,64,C.pale,21);box(dp[i],x,399,216,88,C.white,19);
 wire([[x+75,245],[x+75,282]],C.ctrl);wire([[x+108,346],[x+108,399]],C.ctrl);
 if(i<4){rect(x+224,270,8,238,'#DBE9F5',C.grid,.7);wire([[x+216,434],[x+240,434]],C.data);}
});
wire([[700,216],[700,245],[127,245]],C.ctrl,2,false);wire([[700,245],[1087,245]],C.ctrl,2,false);
wire([[980,203],[962,203],[962,265],[400,265],[400,282]],C.ctrl);
for(let i=1;i<4;i++)wire([[xs[i]+216,316],[xs[i+1],316]],C.ctrl);
['CW_X18','CW_M7','CW_W5'].forEach((t,i)=>text(t,xs[i+2]+128,351,80,22,17,C.ctrl));
box('Sync IM / 256 x 16\nregistered dout = D boundary',52,536,300,66,C.pale,21);
box('Sync DM / 256 x 16\nregistered dout = W load',772,536,300,66,C.pale,21);
wire([[160,472],[160,536]],C.data);wire([[352,568],[370,568],[370,472]],C.data);
wire([[880,472],[880,536]],C.data);wire([[1072,570],[1120,570],[1120,472]],C.data);
wire([[640,472],[640,507],[1240,507],[1240,237],[920,237],[920,216]],C.fwd,2,true);
text('Feedback: src/dest + use\nvalid/fault + eq + EA range\nstop tags / drain state',420,536,340,81,22,C.fwd);
wire([[1120,399],[1120,376],[400,376],[400,399]],C.fwd);
text('CU names denote logical responsibilities inside datapath_core.',412,625,816,35,21,C.fwd,true);
text('Four boundaries preserve each instruction: data + PC/valid/fault + remaining CW',52,659,1176,26,20,C.ctrl);
finish('05','Complete CPU architecture');

// 06: Complete major module and mux network. RF, PC and flags each have one owner.
['IF','ID','EX','MEM','WB'].forEach((t,i)=>text(t,xs[i],144,216,35,27,C.ctrl,true,'center'));
[278,518,758,998].forEach((x,i)=>{rect(x,247,7,337,'#DBE9F5',C.grid,.6);text(['IF/ID','ID/EX','EX/MEM','MEM/WB'][i],x-37,588,85,25,18,C.ctrl,true,'center');});
box('pc16 / next-PC mux\nrst > redir > hold > +1',52,272,216,71,C.pale,20);
box('Sync IM\naddr16 / en / dout16',52,449,216,67,C.pale,22);
box('regfile4x16\n2R / 1W + WB bypass',292,272,216,71,C.pale,21);
box('imm_ext16\nzero / sign extend',292,449,216,67,C.pale,21);
box('operand_forward\nRd + Rs channels',532,247,216,69,C.mint,21);
box('alu16 + input mux\nPASS,+,-,AND,OR',532,351,216,69,C.pale,20);
box('Target + Z select\nJUMP abs / JZ rel',532,482,216,69,C.pale,21);
box('MEM eligibility\nEA16 / valid / fault',772,351,216,69,C.pale,21);
box('Sync DM\nread / write once',772,482,216,69,C.pale,22);
box('WB result mux\nexec16 / load16',1012,351,216,69,C.pale,22);
box('WB enables\nRF + flags_reg',1012,482,216,69,C.pale,22);
wire([[160,343],[160,449]]);wire([[268,482],[281,482],[281,306],[292,306]]);
wire([[508,306],[532,282]]);wire([[508,482],[520,482],[520,397],[532,397]]);
wire([[640,316],[640,351]]);wire([[748,385],[772,385]]);wire([[880,420],[880,482]]);
wire([[988,385],[1012,385]]);wire([[988,516],[1000,516],[1000,401],[1012,401]]);wire([[1120,420],[1120,482]]);
wire([[880,351],[880,210],[607,210],[607,247]],C.fwd);
wire([[1120,351],[1120,192],[680,192],[680,247]],C.fwd);
text('M ready, not load',766,183,230,26,19,C.fwd);text('W result',1045,168,173,25,19,C.fwd);
wire([[1120,551],[1120,631],[287,631],[287,330],[292,330]],C.fwd);
text('WB data / RF bypass',52,635,450,26,20,C.fwd);
wire([[734,282],[754,282],[754,568],[959,568],[959,551]],C.fwd,2,true,true);
text('STR data16',815,574,159,25,19,C.fwd);
wire([[730,420],[748,420],[748,452],[764,452]],C.fwd);text('eq to M/W candidate',530,435,210,25,18,C.fwd);
wire([[1110,551],[1110,644],[563,644],[563,551]],C.fwd,1.8,true);
wire([[868,420],[768,420],[768,618],[601,618],[601,551]],C.fwd,1.8,true);
wire([[532,518],[520,518],[520,227],[36,227],[36,305],[52,305]],C.kill,2,true,true);
text('qualified redirect / target16',52,198,412,26,20,C.kill);
text('D: inst/PC/valid/fault    X: sources/imm/CW18    M: exec/store/CW7    W: result/CW5',52,663,1176,20,16,C.ctrl);
finish('06','Complete five-stage datapath');

// 07: Detailed execute cone, including all independent result/branch/store paths.
box('Saved Rd16\nID/EX source',52,181,205,64,C.pale,24);box('Saved Rs16\nID/EX source',52,285,205,64,C.pale,24);
box('Rd forwarding\nM ready > W > saved',316,181,294,64,C.mint,24);box('Rs forwarding\nM ready > W > saved',316,285,294,64,C.mint,24);
wire([[257,213],[316,213]]);wire([[257,317],[316,317]]);
text('Producer gates: valid / reg_write / dest match / producer fault / load readiness',52,136,1176,30,24,C.fwd,true);
box('ALU A/B input muxes\nA = 0 / Rd / Rs\nB = 0 / Rs / imm',671,274,270,95,C.pale,22);
box('alu16\nresult16 + C/V',1002,285,226,64,C.pale,24);
wire([[610,317],[671,317]]);wire([[941,307],[1002,307]]);wire([[941,335],[1002,335]]);
text('A16',948,280,48,24,17,C.data);text('B16',948,340,48,24,17,C.data);
wire([[610,213],[638,213],[638,260],[806,260],[806,274]]);dot(638,213,C.fwd);
box('Immediate / x_pc\nCW_X function',52,421,205,73,C.pale,23);
wire([[257,438],[642,438],[642,335],[671,335]],C.ctrl);
box('Equality comparator\nforwarded Rd == Rs',671,181,270,64,C.pale,23);
wire([[610,213],[671,213]],C.fwd);wire([[610,317],[642,317],[642,234],[671,234]],C.fwd);
box('Z candidate mux\nM CMP > W CMP > flags.Z',316,528,335,64,C.mint,23);
box('branch_target16\nJUMP: ZExt(u8)\nJZ: x_pc + 1 + SExt(s8)',316,407,335,93,C.pale,23);
wire([[257,460],[316,460]]);box('Qualified EX decision\nCW / valid / mode / fault',738,440,362,79,C.pale,24);
wire([[651,451],[738,466]]);wire([[651,560],[710,560],[710,497],[738,497]],C.fwd);
text('eq to M/W (Z)',1000,179,228,31,22,C.fwd);wire([[941,213],[1000,213]],C.fwd);
text('MEM: exec / EA16\nWB: result / C/V',1002,377,226,67,23,C.data);wire([[1115,349],[1115,377]]);
wire([[610,196],[624,196],[624,260],[660,260],[660,654],[1210,654]],C.fwd,2,true,true);text('STR data = forwarded Rd16\npreserved separately from address',52,610,550,64,24,C.fwd,true);
text('Redirect carries target16 to PC. No instruction leaves the five-stage pipeline early.',52,666,1176,25,21,C.kill);
finish('07','Execute datapath detail');

// 08: Complete CU dependency graph, intention-to-action and stage update policy.
box('Global mode FSM\nFive operating modes',52,149,294,72,C.pale,24);
box('Cross-stage arbitration\nReset > MEM fault > EX stop > redirect > load-use',373,149,855,72,C.mint,25);
wire([[346,185],[373,185]],C.ctrl);
box('ID decoder\nopcode / sources / use',52,278,312,72,C.pale,24);
box('Hazard detection + forwarding\nX/M/W destinations, validity, faults and readiness',407,278,821,72,C.pale,24);
wire([[364,314],[407,314]],C.ctrl);
text('CW_X18 travels to X; remaining fields become CW_M7 and CW_W5',52,381,1176,35,25,C.ctrl,true);
const local=[['IF','PC / IM enable'],['ID','hold / issue / valid'],['EX','ALU / Z / redirect'],['MEM','dm_en / dm_we'],['WB','rf_we / z_we / cv_we']];
wire([[1228,314],[1242,314],[1242,185],[1228,185]],C.fwd);
wire([[1205,221],[1257,221],[1257,425],[160,425]],C.ctrl,2,false);
local.forEach(([h,b],i)=>{const x=52+i*240;box(h+' control\n'+b,x,447,216,70,C.pale,21);wire([[x+108,425],[x+108,447]],C.ctrl);});
for(let i=1;i<4;i++)wire([[52+i*240+216,482],[52+(i+1)*240,482]],C.ctrl);
text('Registered fields: CW_X18 / CW_M7 / CW_W5',532,525,696,25,21,C.ctrl,true);
text('Actual action = intention qualified by valid, fault, mode and reset',52,561,1176,38,26,C.data,true);
text('Advance: move token     Hold: keep front     Bubble: invalid X     Flush: cancel younger',52,610,1176,35,23,C.kill);
text('Local CU blocks denote responsibilities inside datapath_core.',52,655,1176,27,21,C.data);
finish('08','Complete pipeline CU');

// 09: Complete cpu_system boundary. Observers are not execution resources.
rect(38,224,690,402,C.white,C.grid,1.5);text('cpu_system',52,235,600,34,27,C.data,true);
box('IM_INIT_FILE / DM_INIT_FILE: full 256-word images',52,150,660,55,C.pale,22);
box('Sync IM\n256 x 16\nregistered D data',52,324,172,119,C.pale,21);
box('datapath_core\nCU + DP\n12 execution ports',274,324,220,119,C.mint,23);
box('Sync DM\n256 x 16\nregistered W load',544,324,168,119,C.pale,21);
wire([[274,351],[224,351]]);wire([[224,412],[274,412]]);
wire([[494,351],[544,351]]);wire([[544,412],[494,412]]);
text('request',225,322,50,24,15,C.data);text('return',225,414,49,24,15,C.data);
text('request',494,322,50,24,15,C.data);text('return',494,414,49,24,15,C.data);
text('clk / synchronous rst',52,279,660,29,23,C.ctrl);
wire([[384,309],[384,324]],C.ctrl);
box('RF writeback shadow / flags / stop state\nlast successful store / qualified MEM events',104,493,556,78,C.pale,22);
wire([[384,443],[384,493]],C.fwd);
text('Init once. Core reset keeps committed DM.',52,588,660,31,23,C.data);
finish('09','Complete core system and observers');

// 10: ees331_top and the exact application-side partitions, without an extra CPU stage.
box('M19 / 100 MHz\nLVCMOS33 input',52,160,250,70,C.pale,25);
box('BUFG',360,160,164,70,C.pale,27);wire([[302,195],[360,195]],C.ctrl);
box('JTAG debug access',1012,160,216,70,C.pale,23);
rect(38,309,956,331,C.white,C.grid,1.5);text('ees331_application',52,321,500,30,25,C.data,true);
box('Reset request synchronizer\n3 stages / 21-bit stable release\nregistered core_reset',52,402,450,108,C.pale,24);
box('cpu_system / default AC1\ncore + synchronous IM / DM',620,364,350,77,C.mint,24);
box('Counters / state packing\nRF shadow / flags / stop / ID',620,491,350,70,C.pale,22);
box('VIO\nin0: state256\nin1: counters160\nout0: reset request1',1012,355,216,166,C.pale,23);
box('S1 / L18\nactive-low request',52,554,250,65,C.pale,23);
wire([[302,586],[340,586],[340,510]],C.kill);
wire([[442,230],[442,274],[1120,274],[1120,355]],C.ctrl);
wire([[792,274],[792,364]],C.ctrl);dot(792,274,C.ctrl);
wire([[277,274],[277,402]],C.ctrl);wire([[442,274],[277,274]],C.ctrl,2,false);dot(442,274,C.ctrl);
wire([[502,449],[560,449],[560,419],[620,419]],C.kill);
wire([[560,449],[560,526],[620,526]],C.kill);dot(560,449,C.kill);text('core_reset',505,532,120,28,19,C.kill);
wire([[795,441],[795,491]],C.fwd);
wire([[970,386],[1012,386]],C.fwd);wire([[970,517],[1012,517]],C.fwd);
wire([[1228,195],[1250,195],[1250,387],[1228,387]],C.data);
wire([[1012,484],[1002,484],[1002,618],[475,618],[475,510]],C.kill,2,true,true);
text('debug reset request',589,584,390,27,22,C.kill);
text('LEDs: status / heartbeat. VIO reads stable results and counters.',52,655,1176,30,25,C.data,true);
finish('10','Complete EES331 board integration');

const esc=s=>String(s).replaceAll('&','&amp;').replaceAll('<','&lt;').replaceAll('>','&gt;').replaceAll('"','&quot;');
function svg(d){const out=[`<svg xmlns="http://www.w3.org/2000/svg" width="1280" height="720" viewBox="0 0 1280 720"><title>${esc(d.title)}</title><defs><marker id="arr" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="5" markerHeight="5" orient="auto-start-reverse"><path d="M0 0L10 5L0 10Z" fill="context-stroke"/></marker></defs><rect width="1280" height="720" fill="white"/>`];for(const o of d.objects){if(o.kind==='text'){const lines=o.text.split('\n');const xx=o.align==='center'?o.x+o.w/2:o.x;out.push(`<text x="${xx}" y="${o.y+o.size*.89}" fill="${o.fill}" font-family="Arial" font-size="${o.size}" font-weight="${o.bold?700:400}" text-anchor="${o.align==='center'?'middle':'start'}">${lines.map((t,i)=>`<tspan x="${xx}" dy="${i?o.size*1.12:0}">${esc(t)}</tspan>`).join('')}</text>`);}else if(o.kind==='path')out.push(`<path d="${o.points.map((p,i)=>(i?'L':'M')+p.join(' ')).join(' ')}" fill="none" stroke="${o.stroke}" stroke-width="${o.width}" ${o.arrow?'marker-end="url(#arr)"':''} ${o.dashed?'stroke-dasharray="6 4"':''}/>`);else if(o.kind==='circle')out.push(`<circle cx="${o.x+o.w/2}" cy="${o.y+o.h/2}" r="${o.w/2}" fill="${o.fill}"/>`);else out.push(`<rect x="${o.x}" y="${o.y}" width="${o.w}" height="${o.h}" fill="${o.fill}" stroke="${o.stroke}" stroke-width="${o.width}"/>`);}out.push('</svg>');return out.join('\n');}
const out=path.resolve(process.argv[2]);await fs.mkdir(out,{recursive:true});
for(const[id,d]of Object.entries(diagrams))await fs.writeFile(path.join(out,`${id}_${d.title.replaceAll(' ','_')}.svg`),svg(d));
await fs.writeFile(path.join(out,'presentation_diagrams.json'),JSON.stringify(diagrams,null,2));
console.log('PRESENTATION_DIAGRAMS_READY '+Object.keys(diagrams).join(','));
