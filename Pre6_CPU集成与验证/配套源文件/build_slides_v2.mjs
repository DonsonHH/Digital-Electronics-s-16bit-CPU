import fs from 'node:fs/promises';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
import {Presentation,PresentationFile} from '@oai/artifact-tool';
const ROOT=path.resolve(process.argv[2]),Q=path.resolve(process.argv[3]),REV=process.argv[4]??'r2a';
const SKILL='C:/Users/Donson/.codex/plugins/cache/openai-primary-runtime/presentations/26.1026.10807/skills/presentations';
const PY='C:/Users/Donson/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe';
process.env.RUNTIME_NODE_MODULES??='C:/Users/Donson/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules';
const {finalizePresentation,applyPresentationChartFont}=await import(pathToFileURL(path.join(SKILL,'container_tools/artifact_tool_utils.mjs')).href);
const read=async n=>JSON.parse(await fs.readFile(path.join(ROOT,'配套源文件',n),'utf8'));
const [E,CONTENT,MAP,DIAGRAMS]=await Promise.all(['evidence.json','content.json','source_map.json','图源/presentation_diagrams.json'].map(read));
const P=Presentation.create({slideSize:{width:1280,height:720}});
const C={navy:'#14354B',teal:'#087F8C',ink:'#213746',muted:'#536B7A',grid:'#CFDCE4',pale:'#EAF3F7',mint:'#E5F4F1',orange:'#D78732',warm:'#FFF0DC',white:'#FFFFFF',grey:'#8FA4B2'};
let number=0;
const noLine={fill:'none',width:0,style:'solid'};
function rect(s,x,y,w,h,fill=C.white,stroke=C.grid,width=1){return s.shapes.add({geometry:'rect',position:{left:x,top:y,width:w,height:h},fill,line:stroke==='none'?noLine:{fill:stroke,width,style:'solid'}});}
function text(s,t,x,y,w,h,size=27,color=C.ink,bold=false,align='left',nowrap=false){
 const z=s.shapes.add({geometry:'textbox',position:{left:x,top:y,width:w,height:h},fill:'none',line:noLine});z.text=String(t);z.text.style={typeface:'Arial',fontSize:size,color,bold,alignment:align,verticalAlignment:'top',autoFit:'none',wrap:nowrap?'none':'square',insets:0};return z;
}
function line(s,a,b,color=C.navy,width=2,arrow=false,dash=false){if(Math.hypot(b[0]-a[0],b[1]-a[1])<0.001)return;return s.shapes.add({geometry:'connector',kind:'straight',position:{left:Math.min(a[0],b[0]),top:Math.min(a[1],b[1]),width:Math.abs(b[0]-a[0]),height:Math.abs(b[1]-a[1]),horizontalFlip:b[0]<a[0],verticalFlip:b[1]<a[1]},line:{fill:color,width,style:dash?'dashed':'solid'},tail:{type:arrow?'triangle':'none'}});}
function route(s,pts,color=C.teal,width=2,dash=false){pts.slice(1).forEach((b,i)=>line(s,pts[i],b,color,width,i===pts.length-2,dash));}
function box(s,t,x,y,w,h,fill=C.pale,size=27){rect(s,x,y,w,h,fill);text(s,t,x+10,y+8,w-20,h-16,size,C.navy,true,'center');}
function table(s,rows,x,y,width,widths,rowH=49,size=25){
 const t=s.tables.add({rows:rows.length,columns:rows[0].length,left:x,top:y,width,height:rows.length*rowH,columnWidths:widths,values:rows.map(r=>r.map(String))});
 t.borders.assign({fill:C.grid,width:.8,style:'solid'});
 rows.forEach((r,i)=>{t.rows[i].height=rowH;r.forEach((_,j)=>{const c=t.getCell(i,j);c.fill=i===0?C.navy:i%2?C.white:C.pale;c.text.style={typeface:'Arial',fontSize:size,bold:i===0,color:i===0?C.white:C.ink,alignment:j===0?'left':'center',verticalAlignment:'middle',insets:5,autoFit:'none'};});});return t;
}
function make(i){
 number=i;const cfg=CONTENT.main[i-1],s=P.slides.add();s.background.fill=C.white;
 text(s,cfg.title,52,35,1176,65,43,C.navy,true);line(s,[52,112],[1228,112],C.teal,3);
 text(s,`Group 2 Pre6   ${String(i).padStart(2,'0')} / 23`,52,686,700,24,17,C.muted);
 text(s,cfg.section,820,686,408,24,17,C.muted,false,'right');
 s.speakerNotes.text=[`Speaker ${cfg.speaker}; ${cfg.seconds} seconds. Main presentation.`,cfg.speech,'',`Chinese cue: ${cfg.cue}`,'',...MAP[i-1].sources.map(r=>`${r.relative} SHA256 ${r.sha256}`),'',`CPU v1.6 / ISA v1.5 / AC1. ${E.tag}.`,MAP[i-1].supports].join('\n');return s;
}
function clipLine(a,b,v){
 let t0=0,t1=1;const dx=b[0]-a[0],dy=b[1]-a[1],ps=[-dx,dx,-dy,dy],qs=[a[0]-v[0],v[0]+v[2]-a[0],a[1]-v[1],v[1]+v[3]-a[1]];
 for(let i=0;i<4;i++){if(ps[i]===0){if(qs[i]<0)return null;}else{const r=qs[i]/ps[i];if(ps[i]<0)t0=Math.max(t0,r);else t1=Math.min(t1,r);if(t0>t1)return null;}}
 return [[a[0]+t0*dx,a[1]+t0*dy],[a[0]+t1*dx,a[1]+t1*dy],t1===1];
}
function diagram(s,id,frame,view){
 const d=DIAGRAMS[id],v=view??[0,0,d.width,d.height];const k=Math.min(frame[2]/v[2],frame[3]/v[3]);
 const ox=frame[0]+(frame[2]-v[2]*k)/2,oy=frame[1]+(frame[3]-v[3]*k)/2,point=a=>[ox+(a[0]-v[0])*k,oy+(a[1]-v[1])*k];
 for(const o of d.objects){
  if(o.kind==='path'){
   o.points.slice(1).forEach((b,i)=>{const cut=clipLine(o.points[i],b,v);if(cut){const[a0,b0,full]=cut;line(s,point(a0),point(b0),o.stroke,o.width*k,o.arrow&&full&&i===o.points.length-2,o.dashed);}});continue;
  }
  if(o.x+o.w<v[0]||o.x>v[0]+v[2]||o.y+o.h<v[1]||o.y>v[1]+v[3])continue;
  if(o.kind==='text'){
   if(view&&(o.x<v[0]||o.y<v[1]||o.x+o.w>v[0]+v[2]||o.y+o.h>v[1]+v[3]))continue;
   const p=point([o.x,o.y]);text(s,o.text,p[0],p[1],o.w*k+2,o.h*k+2,o.size*k,o.fill,o.bold,o.align??'left',true);continue;
  }
  const x=Math.max(o.x,v[0]),y=Math.max(o.y,v[1]),w=Math.min(o.x+o.w,v[0]+v[2])-x,h=Math.min(o.y+o.h,v[1]+v[3])-y;
  const p=point([x,y]);if(o.kind==='circle')s.shapes.add({geometry:'ellipse',position:{left:p[0],top:p[1],width:w*k,height:h*k},fill:o.fill,line:o.stroke==='none'?noLine:{fill:o.stroke,width:o.width*k,style:'solid'}});else rect(s,p[0],p[1],w*k,h*k,o.fill,o.stroke,o.width*k);
 }
}
const EX=Object.fromEntries(E.examples.map(x=>[x.case,x]));
function trace(s,name,labels,y=210,h=62){
 const ex=EX[name],rows=[['Instruction',...ex.rows.map(r=>r[0])]];
 for(const[pc,label]of labels)rows.push([label,...ex.rows.map(r=>{if(r[1]===pc)return'IF';for(const[i,stage]of[[2,'ID'],[3,'EX'],[4,'MEM'],[5,'WB']])if(r[i].startsWith(pc+':'))return stage+(stage==='ID'&&r[6].includes('保持')?'\nhold':'');return'–';})]);
 const first=228,step=(1176-first)/ex.rows.length,t=table(s,rows,52,y,1176,[first,...ex.rows.map(()=>step)],h,24);
 rows.forEach((r,i)=>r.forEach((v,j)=>{if(i&&j)t.getCell(i,j).fill=v==='–'?C.white:v.includes('hold')?C.warm:v==='WB'?C.mint:C.pale;}));return t;
}
// 1: the assignment provides the deck's reading order.
{
 const s=make(1);text(s,'16-bit CPU on EES-331',52,164,1176,64,46,C.ink,true);
 text(s,'CPU v1.6   /   ISA v1.5   /   Default AC1',52,260,1176,48,32,C.teal,true);
 ['ISA design','Design process','CPU structure and interfaces','Functional verification','Performance verification'].forEach((v,i)=>text(s,`${i+1}   ${v}`,52,352+i*54,1176,46,30,C.ink));
}
// 3: complete coding table; no backup-only encoding material.
{
 const s=make(2);const labels=['15:12\nOpcode (4 bits)','11:10\nRd (2 bits)','9:8\nRs (2 bits)','7:0\nimm / offset (8 bits)'],ws=[294,147,147,588];let x=52;
 labels.forEach((v,i)=>{box(s,v,x,142,ws[i]-3,74,i===0?C.mint:C.pale,24);x+=ws[i];});
 const a=[['Op','Instruction','Flags'],['0','MOV Rd,Rs','hold'],['1','MOV Rd,#u8','hold'],['2','AND Rd,Rs','hold'],['3','OR Rd,Rs','hold'],['4','ADD Rd,Rs','C/V'],['5','ADD Rd,#u8','C/V'],['6','SUB Rd,Rs','C/V'],['7','SUB Rd,#u8','C/V']];
 const b=[['Op','Instruction','Flags'],['8','LDR Rd,[Rs+s8]','hold'],['9','STR Rd,[Rs+s8]','hold'],['A','CMP Rd,Rs','Z'],['B','Reserved / fault','hold'],['C','JUMP #u8','hold'],['D','JZ #s8','hold'],['E','HALT','hold'],['F','Reserved / fault','hold']];
 table(s,a,52,219,566,[66,350,150],45,25);table(s,b,662,219,566,[66,350,150],45,25);
 text(s,'Field roles depend on the form. R0–R3 are writable. Reserved opcodes have no normal writes.',52,642,1176,34,24,C.ink);
}
// 4: operand roles and write permissions, including memory address arithmetic.
{
 const s=make(3);table(s,[['Form','True register sources','State update'],['MOV register / immediate','Rs / none','Rd'],['AND / OR','Rd and Rs','Rd; flags hold'],['ADD / SUB','Rd and Rs, or Rd with u8','Rd and C/V'],['LDR / STR','Rs base / Rs base + Rd data','Rd from DM / DM store'],['CMP','Rd and Rs','Z only'],['JUMP / JZ / HALT','No RF source; JZ reads Z','Redirect or stop; flags hold']],52,150,1176,[360,450,366],61,26);
 text(s,'u8: constants and JUMP.  s8: memory displacement and JZ.',52,607,1176,34,27,C.teal,true);
 text(s,'C = carry / no borrow. V = signed overflow. Memory address ADD preserves flags.',52,650,1176,30,24,C.ink);
}
// 2: dependencies first, then the actual course iteration.
{
 const s=make(4),items=[['ISA behavior + constraints','What must be observable?'],['Resources + interfaces','What values and ports are required?'],['Memory + pipeline boundaries','When are values available?'],['Control + hazards','Who may act this cycle?'],['Integration + simulation','Does the connected CPU follow the ISA?'],['FPGA implementation + board','Does the selected system work on EES-331?']];
 items.forEach(([a,b],i)=>{const y=146+i*76;text(s,String(i+1),52,y,60,50,36,C.teal,true);text(s,a,124,y,490,56,28,C.navy,true);text(s,b,654,y+4,574,56,26,C.ink);if(i<5)line(s,[124,y+63],[1228,y+63],C.grid,1);});
 text(s,'Pre2: modules    Pre3: ISA / modules    Pre4: datapath    Pre5: CU    Pre6: integrated evidence',52,626,1176,40,24,C.muted);
}
// 5–6: full reviewed diagrams as editable geometry, followed by detailed views.
{
 const s=make(5);diagram(s,'05',[0,0,1280,720]);
}
{
 const s=make(6);diagram(s,'06',[0,0,1280,720]);
}
{
 const s=make(7);diagram(s,'07',[0,0,1280,720]);
}
// 8: full system + every original execution-port group, observation ports separate.
{
 const s=make(8);diagram(s,'09',[0,0,1280,720]);
 table(s,[['Core ports','I/O','Bits'],['clk / rst','in','1 / 1'],['im_addr / im_en','out','16 / 1'],['im_dout','in','16'],['dm_addr / en / we','out','16 / 1 / 1'],['dm_din / dm_dout','out / in','16 / 16'],['halted / fault','out','1 / 1']],760,150,468,[278,80,110],63,23);
 text(s,'12 execution ports / 87 bits. Observation outputs are additional.',52,644,1176,34,26,C.teal,true);
}
{
 const s=make(9);diagram(s,'10',[0,0,1280,720]);
}
// 10: full CU region of the same reviewed overall architecture, not a newly invented CU.
{
 const s=make(10);diagram(s,'08',[0,0,1280,720]);
}
// 11: complete actual mode graph, resets, fail-safe and event priorities.
{
 const s=make(11);box(s,'RUN',78,315,180,80,C.mint,30);box(s,'DRAIN_HALT',362,184,248,72,C.pale,27);box(s,'HALTED',694,184,180,72,C.pale,29);box(s,'DRAIN_FAULT',362,452,248,72,C.pale,27);box(s,'FAULTED',694,452,180,72,C.pale,29);
 route(s,[[258,336],[308,336],[308,220],[362,220]],C.teal);route(s,[[258,376],[308,376],[308,488],[362,488]],C.orange);
 line(s,[610,220],[694,220],C.teal,2,true);line(s,[610,488],[694,488],C.orange,2,true);
 text(s,'HALT',272,173,100,32,23,C.teal);text(s,'fault',267,500,100,32,23,C.orange);
 text(s,'WB stop token\n+ empty next pipeline',374,307,470,86,27,C.ink,true);
 route(s,[[782,184],[782,150],[166,150],[166,315]],C.grey,1.8,true);
 route(s,[[782,524],[782,571],[166,571],[166,395]],C.grey,1.8,true);
 text(s,'Reset from every mode',332,588,540,35,25,C.muted);
 table(s,[['#','Qualified event'],['1','Reset'],['2','Older MEM fault'],['3','EX fault / HALT'],['4','EX redirect'],['5','Load-use hold'],['6','Normal progress']],928,150,300,[77,223],62,23);
 text(s,'Illegal mode encoding: fail-safe FAULTED. No silent restart.',52,644,816,34,24,C.ink);
}
// 12: full representative hazard / resource matrix, with an explicit forwarding network.
{
 const s=make(12);table(s,[['Dependency / conflict','Resolution','Data stall'],['ALU / MOV to true Rd or Rs source','Ready M result to EX','0'],['LDR to ALU / CMP / load / store base or data','Hold front; X bubble; W-to-EX','1'],['Multiple producers / WB and ID same register','Nearest eligible producer / explicit RF bypass','0 or 1'],['CMP to JZ / taken branch','M > W > saved Z / cancel younger slots','0 / flush'],['STR to LDR / consecutive DM operations','In-order MEM edges, fixed synchronous DM','0'],['IF and MEM / RF port capacity','Separate IM/DM; RF 2 reads + 1 write','0'],['WAR / WAW / immediate false dependency','In-order pipeline / actual-source use masks','Excluded']],52,144,1176,[505,531,140],56,24);
 text(s,'Forwarding: ready M > W > saved operand. Unready matching M load blocks older W.',52,616,1176,34,26,C.teal,true);
 text(s,'R0 participates normally. STR checks base and store-data sources independently.',52,651,1176,30,24,C.ink);
}
// 13–15: exact existing cycle traces, including valid non-writing stages.
{
 const s=make(13);text(s,'Simulation initial state: R3=0020, R1=0021, DM[0020]=0007',52,148,1176,42,27,C.muted);
 trace(s,'DOC_LOAD_STR',[['00','LDR R0,[R3]'],['01','STR R0,[R1]'],['02','HALT']],208,63);
 [['C3 / C4','Hold front / insert X bubble'],['C5','W-to-EX: ready load value 0007'],['C6 / C7','Unique DM write / valid STR WB'],['C8','HALT completes']].forEach(([a,b],i)=>{text(s,a,52,494+i*43,190,38,27,i===0?C.orange:C.teal,true);text(s,b,260,494+i*43,968,38,27,C.ink);});
}
{
 const s=make(14);text(s,'Simulation: R0=R1=0001. JZ at pc1 targets pc3.',52,147,1176,42,28,C.muted);
 const t=trace(s,'DOC_CMP_JZ',[['00','CMP R0,R1'],['01','JZ +1'],['02','STR (wrong path)'],['03','HALT (target)']],209,62);
 t.getCell(3,4).value='ID\nflush';t.getCell(3,4).fill=C.warm;
 text(s,'C4: M.CMP supplies Z to X.JZ. Younger STR is cancelled.',52,550,1176,42,29,C.teal,true);
 text(s,'JZ continues through MEM/WB. Target HALT completes at C9.',52,608,1176,48,28,C.ink);
}
{
 const s=make(15);trace(s,'DOC_STR_HALT',[['00','STR R0,[R1]'],['01','HALT']],151,62);
 table(s,[['Slot or event','Meaning / permitted effect'],['Valid pass-through','Keep tags; disable writes not required by the instruction'],['Bubble / flush / hold','No valid token / cancel younger / retain current token'],['Older MEM fault + younger EX event','Block invalid memory access and younger action; preserve older WB'],['Reset','Disable writes, clear in-flight state and observations; preserve DM']],52,371,1176,[370,806],56,24);
}
// 16: bounded test layers and actual fresh runs, with no tool-check inflation.
{
 const s=make(16);table(s,[['Verification layer','Evidence / checks','Role'],['Module + pipeline regressions','Existing 9 HDL suites, hazards and negative checks','Components / per-edge control'],['Independent ISA cases','48 cases + 10 reset witnesses','ISA effects and cycle events'],['Fresh delivered Vivado projects','5 programs + 11-case system suite / 12 epochs','Runnable integration checks'],['Archived EES-331 samples','5 programs, 2 stable samples each; physical S1','Stable state and counters'],['Host / document checks','21 offline gates','Tool and evidence integrity']],52,151,1176,[310,572,294],76,25);
 text(s,'Expected ISA behavior and explicit vectors are checked against actual DUT events.',52,633,1176,40,26,C.teal,true);
}
// 17: actual trace-derived waveform, portable source package and an exact rerun command.
{
 const s=make(17);s.images.add({blob:new Uint8Array(await fs.readFile(path.join(ROOT,'配套源文件/图源/baseline_waveform.png'))),contentType:'image/png',alt:'Actual baseline XSim samples cross-checked against VCD; editable SVG and WaveJSON supplied',fit:'contain',position:{left:40,top:148,width:1200,height:336}});
 text(s,'C9: a front-end stall coexists with an older MEM store.',52,502,1176,35,28,C.teal,true);
 text(s,'Vivado package: 13 core RTL + system + application, TB, MEM, XPR, WDB, VCD',52,550,1176,64,27,C.ink);
 text(s,'Vivado/run_tests.ps1 -Program all',52,626,1176,40,28,C.navy,true);
}
// 18: all physical results, four raw S1 samples and the checksum endpoint in the main story.
{
 const s=make(18);text(s,'Decoded archived VIO snapshots',52,143,1176,38,27,C.teal,true);
 table(s,[['Program','C','N','S','R'],...E.programs.map(r=>[r.program,r.C,r.N,r.S,r.R])],52,199,650,[290,90,90,90,90],51,25);
 table(s,[['S1 frame','reset','C','R1'],...E.button.map(r=>[r.label,r.decoded.core_reset,r.decoded.cycles,r.decoded.rf[1].toString(16).padStart(4,'0').toUpperCase()])],744,199,484,[196,96,96,96],55,24);
 text(s,'Checksum: RF shadow [0000,1232,0000,0020], Z/C/V=0/0/0, stop_pc=0022',52,538,1176,45,27,C.navy,true);
 const raw=E.raw_button.find(r=>r.label==='after_0');text(s,`after_0 state256: ${raw.state256_hex}`,52,592,1176,30,21,C.ink);
 text(s,'Physical S1 test: reset and restart after CPU stop. Internal timing remains simulation evidence.',52,642,1176,35,24,C.teal);
}
// 19–22: physical cycle model, chart, implementation and the two completed experiments.
{
 const s=make(19);text(s,'C = N + 4 + S + 2R',52,155,1176,70,48,C.navy,true);
 table(s,[['Term','Meaning in these normal-HALT programs'],['N','Completed instruction tokens, including HALT'],['4','Pipeline filling and completion'],['S','Load-use stall cycles'],['R','Accepted redirects; two extra cycles each'],['CPI','C / N']],52,259,1176,[235,941],61,28);
 text(s,'Counters are physical VIO observations. Time conversion assumes the designed 100 MHz clock.',52,641,1176,38,25,C.teal);
}
{
 const s=make(20);const chart=s.charts.add('bar',{position:{left:34,top:170,width:710,height:380},categories:E.programs.map(r=>r.program),series:[{name:'N instructions',values:E.programs.map(r=>r.N),fill:C.navy},{name:'Fill / finish',values:E.programs.map(()=>4),fill:C.grey},{name:'S stalls',values:E.programs.map(r=>r.S),fill:C.orange},{name:'2R redirects',values:E.programs.map(r=>2*r.R),fill:C.teal}],barOptions:{direction:'bar',grouping:'stacked',overlap:100,gapWidth:90},hasLegend:true,legend:{position:'bottom',textStyle:{fontSize:21,typeface:'Arial'}},xAxis:{textStyle:{fontSize:22,typeface:'Arial'}},yAxis:{minimumScale:0,maximumScale:60,majorUnit:20,textStyle:{fontSize:21,typeface:'Arial'},majorGridlines:{fill:C.grid,width:1,style:'solid'}},chartFill:C.white,plotAreaFill:C.white});applyPresentationChartFont(chart,{fontFamily:'Arial'});
 table(s,[['Program','C','CPI'],...E.programs.map(r=>[r.program,r.C,(r.C/r.N).toFixed(2)])],784,178,444,[244,80,120],57,25);
 text(s,'baseline: 10 + 4 + 1 + 2 = 17',52,573,1176,40,29,C.ink);
 text(s,'checksum: 35 + 4 + 16 + 0 = 55',52,621,1176,40,29,C.ink);
}
{
 const s=make(21);table(s,[['Program','LUT total','FF','BRAM18','WNS ns','WHS ns'],...E.routed.map(r=>{const m=r.implementation;return[r.program,m.resources.lut_total,m.resources.ff,m.resources.bram18,m.timing.wns_ns.toFixed(3),m.timing.whs_ns.toFixed(3)];})],52,183,1176,[314,180,150,172,180,180],65,27);
 text(s,'Complete ees331_top: core, memories, reset, VIO, counters and observation logic.',52,602,1176,43,27,C.ink);
 text(s,'xc7z020clg484-1 / Vivado 2025.2 / 10 ns constraint / archived routed reports',52,649,1176,30,24,C.teal);
}
{
 const s=make(22);table(s,[['Experiment','Cycle result','Decision / scope'],['Forwarding-MUX rewrite','No cycle reduction','Routed slack did not improve overall; not adopted'],['WB-to-MEM: memory_copy','15 → 14','Offline candidate; +84 LUT / +2 FF'],['WB-to-MEM: copy_checksum','55 → 47','Offline candidate; +86 LUT / +2 FF']],52,184,1176,[402,230,544],91,27);
 text(s,'Candidate removes STR data-only load-use stalls. STR base dependencies still stall.',52,588,1176,56,28,C.navy,true);
 text(s,'Default AC1 remains the physically accepted CPU.',52,650,1176,31,27,C.teal,true);
}
{
 const s=make(23);const rows=[['ISA + design process','Complete encoding and engineering dependencies'],['CPU structure + interfaces','Complete datapath, CU, system and board connections'],['Functional verification','Executable Vivado package, per-edge checks and physical samples'],['Performance verification','Physical cycle explanation and routed timing/resources']];
 rows.forEach(([a,b],i)=>{text(s,a,52,166+i*96,440,62,31,C.navy,true);text(s,b,535,166+i*96,693,72,29,C.ink);if(i<3)line(s,[52,246+i*96],[1228,246+i*96],C.grid,1);});
 text(s,'Course folder: Pre6 materials and the current core specification',52,596,1176,40,27,C.teal,true);
 text(s,'PPT + English script + core specification + runnable Vivado project',52,646,1176,32,26,C.ink);
}
await fs.mkdir(Q,{recursive:true});await fs.mkdir(path.join(Q,'previews'),{recursive:true});await fs.mkdir(path.join(Q,'output'),{recursive:true});
for(let i=0;i<P.slides.items.length;i++){const png=await P.export({slide:P.slides.items[i],format:'png',scale:1.5});await fs.writeFile(path.join(Q,'previews',`slide-${String(i+1).padStart(2,'0')}.png`),new Uint8Array(await png.arrayBuffer()));}
const draft=path.join(Q,`draft-${REV}.pptx`);await(await PresentationFile.exportPptx(P)).save(draft);
const owners=[2,3,8,11,12,13,14,15,16,18,19,20,21,22];
const result=await finalizePresentation({workspaceDir:Q,candidatePath:draft,finalPath:path.join(Q,'output',`Pre6_Group2_CPU_Integration_EN_${REV}.pptx`),pythonExecutable:PY,integrityValidatorPath:path.join(SKILL,'container_tools/inspect_presentation_package_integrity.py'),layoutValidatorPath:path.join(SKILL,'container_tools/inspect_presentation_layout_geometry.py'),layoutArgs:['--expected-slide-size-emu','12192000,6858000',...owners.flatMap(x=>['--require-native-table-slide',String(x)])],explicitTotalSlideCount:23,requiredNativeTableOwnerSlides:owners,requiredNativeChartOwnerSlides:[20],nativeChartTargetApplication:'portable',materializeLiteralChartWorkbooks:true,fontPolicy:{basis:'design',families:['Arial']},verifyArtifactToolImport:true,receiptPath:path.join(Q,`validation-${REV}.json`)});
console.log(JSON.stringify({status:'PRE6_R2_PPTX_READY',slides:23,backup:0,result}));
