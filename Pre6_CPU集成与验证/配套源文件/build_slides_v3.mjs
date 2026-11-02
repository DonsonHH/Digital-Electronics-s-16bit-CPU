import fs from 'node:fs/promises';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
import {Presentation,PresentationFile} from '@oai/artifact-tool';
const ROOT=path.resolve(process.argv[2]),Q=path.resolve(process.argv[3]),REV=process.argv[4]??'r3a';
const SKILL='C:/Users/Donson/.codex/plugins/cache/openai-primary-runtime/presentations/26.1026.10807/skills/presentations';
const PY='C:/Users/Donson/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe';
process.env.RUNTIME_NODE_MODULES??='C:/Users/Donson/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules';
const {finalizePresentation,applyPresentationChartFont}=await import(pathToFileURL(path.join(SKILL,'container_tools/artifact_tool_utils.mjs')).href);
const load=async n=>JSON.parse(await fs.readFile(path.join(ROOT,'配套源文件',n),'utf8'));
const[E,CONTENT,MAP]=await Promise.all(['evidence.json','content.json','source_map.json'].map(load));
const P=Presentation.create({slideSize:{width:1280,height:720}});
const C={navy:'#14354B',teal:'#087F8C',ink:'#213746',muted:'#536B7A',grid:'#CFDCE4',pale:'#EAF3F7',mint:'#E5F4F1',orange:'#D78732',warm:'#FFF0DC',white:'#FFFFFF',grey:'#8FA4B2'};
const none={fill:'none',width:0,style:'solid'};let physical=0;
function rect(s,x,y,w,h,fill=C.white,stroke=C.grid){return s.shapes.add({geometry:'rect',position:{left:x,top:y,width:w,height:h},fill,line:{fill:stroke,width:1,style:'solid'}});}
function text(s,t,x,y,w,h,size=27,color=C.ink,bold=false,align='left'){
 const a=s.shapes.add({geometry:'textbox',position:{left:x,top:y,width:w,height:h},fill:'none',line:none});a.text=String(t);a.text.style={typeface:'Arial',fontSize:size,color,bold,alignment:align,verticalAlignment:'top',autoFit:'none',wrap:'square',insets:0};return a;
}
function line(s,a,b,color=C.navy,width=2,arrow=false){if(Math.hypot(a[0]-b[0],a[1]-b[1])<.001)return;return s.shapes.add({geometry:'connector',kind:'straight',position:{left:Math.min(a[0],b[0]),top:Math.min(a[1],b[1]),width:Math.abs(b[0]-a[0]),height:Math.abs(b[1]-a[1]),horizontalFlip:b[0]<a[0],verticalFlip:b[1]<a[1]},line:{fill:color,width,style:'solid'},tail:{type:arrow?'triangle':'none'}});}
function route(s,pts,color=C.teal){pts.slice(1).forEach((p,i)=>line(s,pts[i],p,color,2,i===pts.length-2));}
function box(s,t,x,y,w,h,fill=C.pale,size=27){rect(s,x,y,w,h,fill);text(s,t,x+10,y+8,w-20,h-16,size,C.navy,true,'center');}
function table(s,rows,x,y,w,widths,rh=52,size=25){
 const t=s.tables.add({rows:rows.length,columns:rows[0].length,left:x,top:y,width:w,height:rows.length*rh,columnWidths:widths,values:rows.map(r=>r.map(String))});t.borders.assign({fill:C.grid,width:.8,style:'solid'});
 rows.forEach((r,i)=>{t.rows[i].height=rh;r.forEach((_,j)=>{const z=t.getCell(i,j);z.fill=i===0?C.navy:i%2?C.white:C.pale;z.text.style={typeface:'Arial',fontSize:size,bold:i===0,color:i===0?C.white:C.ink,alignment:j===0?'left':'center',verticalAlignment:'middle',insets:5,autoFit:'none'};});});return t;
}
async function picture(s,name,x,y,w,h,alt){const bytes=new Uint8Array(await fs.readFile(path.join(ROOT,'配套源文件/图源/r3',name)));s.images.add({blob:bytes,contentType:'image/png',alt,fit:'contain',position:{left:x,top:y,width:w,height:h}});}
function make(ref){
 const i=CONTENT.main.findIndex(x=>x.reference_page===ref);physical=i+1;const cfg=CONTENT.main[i],s=P.slides.add();s.background.fill=C.white;
 const chapter=cfg.code?cfg.code.split('.')[0]+' '+cfg.chapter:cfg.chapter;
 text(s,chapter,52,18,1176,25,18,C.muted);text(s,cfg.title,52,48,1176,56,41,C.navy,true);line(s,[52,119],[1228,119],C.teal,3);
 text(s,`Group 2 Pre6   ${String(physical).padStart(2,'0')} / 24`,52,687,700,22,16,C.muted);
 text(s,cfg.code?cfg.code+' / '+cfg.chapter:'Project overview',790,687,438,22,16,C.muted,false,'right');
 const meta=MAP[i];const raw=meta.raw_S1_notes?['','Raw archived VIO (state256 = 256 bits / 64 hex digits):',...meta.raw_S1_notes.map(r=>`${r.label}\t${r.state256_hex}\t${r.perf160_hex}`)]:[];
 s.speakerNotes.text=[`Speaker ${cfg.speaker}; ${cfg.seconds} seconds. Section ${cfg.code||'front matter'}.`,cfg.speech,'',`Chinese cue: ${cfg.cue}`,'',...meta.sources.map(r=>`${r.relative} SHA256 ${r.sha256}`),...raw,'',`CPU ${E.CPU}, ISA ${E.ISA}, default ${E.implementation}; ${E.tag}.`].join('\n');return s;
}
const EX=Object.fromEntries(E.examples.map(x=>[x.case,x]));
function trace(s,name,labels,y=220,rh=60){
 const ex=EX[name],rows=[['Instruction',...ex.rows.map(r=>r[0])]];
 for(const[pc,label]of labels)rows.push([label,...ex.rows.map(r=>{if(r[1]===pc)return'IF';for(const[j,st]of[[2,'ID'],[3,'EX'],[4,'MEM'],[5,'WB']])if(r[j].startsWith(pc+':'))return st+(st==='ID'&&r[6].includes('保持')?'\nhold':'');return'–';})]);
 const first=232,t=table(s,rows,52,y,1176,[first,...ex.rows.map(()=>(1176-first)/ex.rows.length)],rh,24);
 rows.forEach((r,i)=>r.forEach((v,j)=>{if(i&&j)t.getCell(i,j).fill=v==='–'?C.white:v.includes('hold')?C.warm:v==='WB'?C.mint:C.pale;}));return t;
}
function checkStrip(s,t){rect(s,52,143,1176,45,C.mint,C.mint);text(s,t,64,150,1152,34,27,C.teal,true);}
// Cover and dedicated, page-numbered directory.
{
 const s=make(1);text(s,'16-bit five-stage CPU',52,184,1176,78,52,C.ink,true);
 text(s,'ISA v1.5   /   CPU v1.6   /   AC1',52,304,1176,55,34,C.teal,true);
 text(s,'EES-331 integration, functional evidence and performance',52,410,1176,95,36,C.ink);
 text(s,'Group 2',1030,600,198,46,31,C.teal,true,'right');
}
{
 const s=make(0);const rows=[['1','ISA Design','3–4'],['2','Design Process','5'],['3','Architecture and Execution','6–16'],['4','Functional Verification','17–19'],['5','Performance and Trade-offs','20–23'],['6','Delivery','24']];
 rows.forEach(([n,t,p],i)=>{const y=156+i*80;text(s,n,52,y,70,50,37,C.teal,true);text(s,t,160,y+2,800,46,33,C.navy,true);text(s,'p. '+p,980,y+6,248,42,28,C.muted,false,'right');if(i<5)line(s,[160,y+64],[1228,y+64],C.grid,1);});
}
{
 const s=make(2);await picture(s,'ISA_官网编码表.png',30,141,1220,526,'Verified ISA v1.5 encoding table from lab.donson.top/isa');
}
{
 const s=make(3);table(s,[['Form','True register sources','Architectural update'],['MOV register / immediate','Rs / none','Rd'],['AND / OR','Rd and Rs','Rd; flags hold'],['ADD / SUB','Rd and Rs, or Rd with u8','Rd and C/V'],['LDR / STR','Rs base / Rs base + Rd data','Rd from DM / store to DM'],['CMP','Rd and Rs','Z'],['JUMP / JZ / HALT','JZ reads Z','PC redirect or stop']],52,156,1176,[355,440,381],60,25);
 text(s,'u8 constants and JUMP / s8 memory and JZ offsets',52,605,1176,36,27,C.teal,true);
 text(s,'C = unsigned carry / no borrow. V = signed overflow.',52,651,1176,29,24,C.ink);
}
{
 const s=make(4);table(s,[['Constraint','Decision','Architectural effect'],['16-bit ISA / 4 writable registers','Compact fields; explicit source-use masks','R0 participates normally; false stalls excluded'],['One-cycle synchronous IM / DM','Registered memory outputs supply D / W boundaries','Five aligned pipeline stages'],['In-flight register dependencies','Ready M > W > saved; WB-to-ID bypass','Adjacent arithmetic proceeds without a data hold'],['Load value arrives after MEM','One front-end hold + X bubble, then W-to-EX','Correct load value reaches the consumer'],['Branch / HALT / fault events','Instruction-age arbitration + global mode FSM','Cancel younger slots; complete eligible older work']],52,157,1176,[300,445,431],72,23);
 text(s,'Order: ISA -> interfaces -> pipeline timing -> control -> integration -> verification',52,608,1176,34,24,C.teal,true);
 text(s,'Pre2 modules   /   Pre3 ISA and modules   /   Pre4 datapath   /   Pre5 CU   /   Pre6 integration',52,649,1176,28,21,C.muted);
}
// The verified Chinese figures retain the original circuitry and labels.
{
 const s=make(5);await picture(s,'CPU_整体架构_中文.png',12,132,1256,547,'Verified r4 Chinese complete CPU architecture');
}
{
 const s=make(6);await picture(s,'CPU_五级Datapath_中文.png',12,130,1256,549,'Verified r4 Chinese complete five-stage datapath');
}
{
 const s=make(7);await picture(s,'CPU_EX_WB路径_中文.png',16,139,958,525,'EX to WB detail cropped from the verified Chinese datapath');
 text(s,'Forwarding',1002,178,226,42,29,C.teal,true);text(s,'M ready\nthen W\nthen saved',1002,235,226,142,28,C.ink);
 text(s,'Branch paths',1002,410,226,44,29,C.teal,true);text(s,'Newest CMP Z\n+ target16\n+ EX eligibility',1002,470,226,146,26,C.ink);
}
{
 const s=make(8);await picture(s,'CPU_系统集成_中文.png',28,151,684,478,'Verified Chinese file-boot system and observers');
 table(s,[['Signal group','I/O','Width'],['clk / rst','in','1 / 1'],['im_addr / im_en','out','16 / 1'],['im_dout','in','16'],['dm_addr / en / we','out','16 / 1 / 1'],['dm_din / dout','out / in','16 / 16'],['halted / fault','out','1 / 1']],744,157,484,[285,89,110],61,22);
 text(s,'Logical memory ports connect the core to the system memories.',52,641,1176,37,27,C.teal,true);
}
{
 const s=make(9);await picture(s,'CPU_EES331集成_中文.png',44,142,1192,520,'Verified Chinese EES-331 clock, reset and VIO integration');
}
{
 const s=make(10);await picture(s,'CPU_控制区_中文.png',28,153,1224,394,'Complete CU region cropped from the verified Chinese architecture');
 text(s,'ID intention',52,576,250,44,31,C.navy,true);text(s,'traveling CW',392,576,300,44,31,C.teal,true);text(s,'eligible WB action',836,576,392,44,31,C.navy,true);
 line(s,[270,596],[360,596],C.teal,2,true);line(s,[691,596],[801,596],C.teal,2,true);
 text(s,'reg_write',52,631,250,35,26,C.ink);text(s,'data + PC/valid/fault + CW',375,631,430,35,26,C.ink);text(s,'rf_we',880,631,348,35,26,C.ink);
}
{
 const s=make(11);box(s,'RUN',68,323,168,78,C.mint,30);box(s,'DRAIN_HALT',330,190,248,72,C.pale,27);box(s,'HALTED',666,190,180,72,C.pale,29);box(s,'DRAIN_FAULT',330,453,248,72,C.pale,27);box(s,'FAULTED',666,453,180,72,C.pale,29);
 route(s,[[236,344],[285,344],[285,226],[330,226]],C.teal);route(s,[[236,382],[285,382],[285,489],[330,489]],C.orange);
 line(s,[578,226],[666,226],C.teal,2,true);line(s,[578,489],[666,489],C.orange,2,true);
 text(s,'HALT',250,177,90,30,23,C.teal);text(s,'fault',247,505,100,30,23,C.orange);
 text(s,'WB stop token\n+ empty next pipeline',345,326,490,90,27,C.ink,true);
 route(s,[[756,190],[756,157],[152,157],[152,323]],C.grey);route(s,[[756,525],[756,577],[152,577],[152,401]],C.grey);
 text(s,'Reset from every mode',308,595,545,35,25,C.muted);
 table(s,[['#','Qualified event'],['1','Reset'],['2','Older MEM fault'],['3','EX fault / HALT'],['4','EX redirect'],['5','Load-use hold'],['6','Normal progress']],914,157,314,[62,252],62,23);
 text(s,'Illegal mode encoding enters the fail-safe FAULTED state.',52,650,800,30,23,C.ink);
}
{
 const s=make(12);const t=table(s,[['Dependency / resource','Resolution','Data hold'],['ALU / MOV -> true source','Ready M/W result to EX','0'],['LDR -> true source (base or data)','Front hold + X bubble; W-to-EX','1'],['WB and ID: same register','Explicit RF read bypass','0'],['CMP -> JZ','M > W > saved Z','0'],['Multiple producers','Nearest match; unready M load blocks old W','0 or 1'],['STR -> LDR / consecutive DM access','Ordered synchronous MEM edges','0'],['IF + MEM / RF capacity','Harvard IM/DM; RF 2R1W','0'],['WAR / WAW / immediate false RAW','In-order stages / actual-source masks','Excluded']],52,151,1176,[440,606,130],54,24);
 for(let j=0;j<3;j++)t.getCell(2,j).fill=C.warm;
 text(s,'R0 is writable. STR checks base and data independently.',52,650,1176,28,25,C.teal,true);
}
{
 const s=make(13);checkStrip(s,'Check: one load-use hold and exactly one memory write');
 text(s,'Initial state: R3=0020, R1=0021, DM[0020]=0007',52,199,1176,35,26,C.muted);
 trace(s,'DOC_LOAD_STR',[['00','LDR R0,[R3]'],['01','STR R0,[R1]'],['02','HALT']],250,62);
 text(s,'C3 hold / C4 bubble',52,524,450,40,29,C.orange,true);text(s,'C5 W-to-EX = 0007',684,524,544,40,29,C.teal,true);
 text(s,'C6: DM write     C7: STR WB tag     C8: HALT completes',52,599,1176,55,30,C.navy,true);
}
{
 const s=make(14);checkStrip(s,'Check: newest Z, accepted redirect and wrong-path store cancellation');
 text(s,'R0=R1=0001. JZ at pc1 targets pc3.',52,199,1176,35,27,C.muted);
 const t=trace(s,'DOC_CMP_JZ',[['00','CMP R0,R1'],['01','JZ +1'],['02','STR (cancelled)'],['03','HALT (target)']],245,61);t.getCell(3,4).value='ID\nflush';t.getCell(3,4).fill=C.warm;
 text(s,'C4: M.CMP -> X.JZ     /     target HALT completes at C9',52,590,1176,56,30,C.teal,true);
}
{
 const s=make(15);text(s,'Case A: older STR completes before HALT',52,147,1176,36,29,C.teal,true);
 trace(s,'DOC_STR_HALT',[['00','STR R0,[R1]'],['01','HALT']],196,43);
 text(s,'C4: unique store   /   C5: STR WB   /   C6: HALTED',52,339,1176,32,25,C.ink);
 text(s,'Case B: older MEM fault wins over the younger jump',52,386,1176,36,29,C.orange,true);
 table(s,[['Cycle','WB (oldest)','MEM','EX (younger)','Observed effect'],['C5','MOV R1=00FF','ADD','LDR: EA=0100','Normal advance'],['C6','ADD R0=0001','LDR fault','JUMP cancelled','dm_en=0; redirect=0'],['C7','LDR fault token','–','–','FAULTED']],52,436,1176,[90,250,245,245,346],54,23);
}
{
 const s=make(16);table(s,[['Evidence layer','Checks'],['Module / pipeline','9 suites: datapath, hazards, flags, controls'],['Independent ISA','48 cases + 10 reset witnesses'],['Integrated projects','5 programs; system reset/fault cases'],['EES-331 samples','5 program outcomes + physical S1'],['Tool / evidence integrity','21 archived workflow checks']],52,160,586,[220,366],75,23);
 table(s,[['Expected','Observed'],['ISA register values','XSim writes / VIO shadow'],['Explicit flag vectors','Qualified Z/C/V writes'],['Memory/store behavior','XSim events / VIO last store'],['Stop and cycle model','XSim / VIO counters']],681,160,547,[246,301],88,23);
}
{
 const s=make(17);text(s,'baseline program',52,147,427,35,28,C.navy,true);
 E.baseline_assembly.forEach((r,i)=>{text(s,`${r.pc}  ${r.asm}`,52,194+i*30,427,29,22,[5,6,7].includes(i)?C.orange:i===8?C.teal:C.ink,[5,6,7,8].includes(i));});
 await picture(s,'baseline_waveform.png',498,165,730,285,'Actual R3 XSim rising-edge VCD samples, baseline C6 to C13');
 text(s,'C9: older store + front-end hold',510,460,718,35,27,C.teal,true);
 table(s,[['Check','Expected = observed'],['RF (hex)','0008 / 0002 / 0008 / 0020'],['Z/C/V; stop','1/1/0; HALT at 000A'],['N / S / R / C','10 / 1 / 1 / 17']],510,507,718,[210,508],33,21);
 text(s,'Reproduce: Vivado/run_tests.ps1 -Program baseline',52,649,1176,29,24,C.navy,true);
}
{
 const s=make(18);text(s,'EES-331 / decoded archived VIO results',52,146,1176,36,27,C.teal,true);
 table(s,[['Program','C','N','S','R'],...E.programs.map(r=>[r.program,r.C,r.N,r.S,r.R])],52,202,627,[299,82,82,82,82],39,23);
 await picture(s,'EES331_平台图_手册.png',711,190,292,232,'EES-331 platform photo from the user manual; test evidence is the archived VIO data');
 text(s,'Platform photo:\nEES-331 manual',1012,227,216,66,22,C.muted);
 text(s,'S1 restart:\n55 -> 0 -> 55',1012,337,216,80,27,C.teal,true);
 table(s,[['Checksum item','Model expected','VIO observed','Result'],['RF / ZCV','0000,1232,0000,0020 / 000','Same values','PASS'],['Stop','HALT at PC0022','halted=1; fault=0; PC0022','PASS'],['Counters','N35 + 4 + S16 = C55','N35 / S16 / R0 / C55','PASS'],['S1 hold / release','Clear, then restart','R1:1232 -> 0000 -> 1232','PASS']],52,453,1176,[220,420,420,116],39,21);
 text(s,'VIO RF uses a writeback shadow. S1 was tested after HALT; internal cycle checks use XSim.',52,659,1176,22,18,C.muted);
}
{
 const s=make(19);text(s,'C = N + 4 + S + 2R',52,158,1176,70,48,C.navy,true);
 table(s,[['Term','Meaning'],['N','Completed instructions, including HALT'],['4','Pipeline filling and completion'],['S','Load-use hold cycles'],['R','Accepted redirects; two extra cycles each'],['CPI','C / N']],52,263,1176,[235,941],60,28);
 text(s,'Cycle-to-time conversion uses the 100 MHz design clock.',52,649,1176,28,23,C.muted);
}
{
 const s=make(20);const chart=s.charts.add('bar',{position:{left:34,top:178,width:710,height:374},categories:E.programs.map(r=>r.program),series:[{name:'N instructions',values:E.programs.map(r=>r.N),fill:C.navy},{name:'Fill / finish',values:E.programs.map(()=>4),fill:C.grey},{name:'S holds',values:E.programs.map(r=>r.S),fill:C.orange},{name:'2R redirects',values:E.programs.map(r=>2*r.R),fill:C.teal}],barOptions:{direction:'bar',grouping:'stacked',overlap:100,gapWidth:90},hasLegend:true,legend:{position:'bottom',textStyle:{fontSize:21,typeface:'Arial'}},xAxis:{textStyle:{fontSize:22,typeface:'Arial'}},yAxis:{minimumScale:0,maximumScale:60,majorUnit:20,textStyle:{fontSize:21,typeface:'Arial'},majorGridlines:{fill:C.grid,width:1,style:'solid'}},chartFill:C.white,plotAreaFill:C.white});applyPresentationChartFont(chart,{fontFamily:'Arial'});
 table(s,[['Program','C','CPI'],...E.programs.map(r=>[r.program,r.C,(r.C/r.N).toFixed(2)])],784,184,444,[244,80,120],56,25);
 text(s,'baseline: 10 + 4 + 1 + 2 = 17',52,580,1176,39,29,C.ink);text(s,'checksum: 35 + 4 + 16 + 0 = 55',52,627,1176,40,29,C.ink);
}
{
 const s=make(21);table(s,[['Program','LUT total','FF','BRAM18','WNS ns','WHS ns'],...E.routed.map(r=>{const m=r.implementation;return[r.program,m.resources.lut_total,m.resources.ff,m.resources.bram18,m.timing.wns_ns.toFixed(3),m.timing.whs_ns.toFixed(3)];})],52,185,1176,[314,180,150,172,180,180],64,27);
 text(s,'Complete EES-331 board top: CPU, memories, VIO and observation logic',52,600,1176,40,27,C.teal,true);
 text(s,'Vivado 2025.2 / xc7z020clg484-1 / 10 ns / archived routed reports',52,649,1176,28,23,C.muted);
}
{
 const s=make(22);const selected=E.candidate.filter(r=>['memory_copy','copy_checksum'].includes(r.program));
 const chart=s.charts.add('bar',{position:{left:44,top:178,width:666,height:292},categories:selected.map(r=>r.program),series:[{name:'AC1',values:selected.map(r=>r.baseline_cycles),fill:C.navy},{name:'WB-to-MEM',values:selected.map(r=>r.candidate_cycles),fill:C.teal}],barOptions:{direction:'bar',grouping:'clustered',gapWidth:90},hasLegend:true,legend:{position:'bottom',textStyle:{fontSize:23,typeface:'Arial'}},xAxis:{textStyle:{fontSize:23,typeface:'Arial'}},yAxis:{minimumScale:0,maximumScale:60,majorUnit:20,textStyle:{fontSize:22,typeface:'Arial'}},dataLabels:{showValue:true,textStyle:{fontSize:23,typeface:'Arial'}},chartFill:C.white,plotAreaFill:C.white});applyPresentationChartFont(chart,{fontFamily:'Arial'});
 text(s,'55 -> 47 cycles',770,181,458,58,40,C.teal,true);text(s,'14.5% fewer cycles\nCPI 1.57 -> 1.34\n+86 LUT / +2 FF',770,263,458,150,30,C.ink);
 table(s,[['Experiment / condition','Engineering result'],['Store-data dependency','Removes store-data hold; base dependencies still hold'],['memory_copy','15 -> 14 cycles (-6.7%); +84 LUT / +2 FF'],['Forwarding-MUX rewrite','No cycle benefit; timing margin declined overall']],52,480,1176,[395,781],39,22);
 text(s,'AC1: board-verified release. WB-to-MEM: quantified offline upgrade.',52,653,1176,28,24,C.teal,true);
}
{
 const s=make(23);const items=[['ISA and design process','Complete encoding and documented engineering decisions'],['Architecture and interfaces','Connected datapath, CU, memories and EES-331 integration'],['Functional verification','Program -> expected state -> XSim -> board observations'],['Performance and trade-offs','Cycle breakdown, CPI, routed timing and quantified candidates']];
 items.forEach(([a,b],i)=>{text(s,a,52,164+i*98,440,65,30,C.navy,true);text(s,b,535,165+i*98,693,75,29,C.ink);if(i<3)line(s,[52,245+i*98],[1228,245+i*98],C.grid,1);});
 text(s,'Open_CPU_Project.cmd / Open_EES331_Project.cmd',52,605,1176,39,28,C.teal,true);text(s,'Specification + PPT + English script + source and verification records',52,650,1176,29,25,C.ink);
}
await fs.mkdir(Q,{recursive:true});await fs.mkdir(path.join(Q,'previews'),{recursive:true});await fs.mkdir(path.join(Q,'output'),{recursive:true});
for(let i=0;i<P.slides.items.length;i++){const png=await P.export({slide:P.slides.items[i],format:'png',scale:1.5});await fs.writeFile(path.join(Q,'previews',`slide-${String(i+1).padStart(2,'0')}.png`),new Uint8Array(await png.arrayBuffer()));}
const draft=path.join(Q,`draft-${REV}.pptx`);await(await PresentationFile.exportPptx(P)).save(draft);
const owners=[4,5,9,12,13,14,15,16,17,18,19,20,21,22,23];
const result=await finalizePresentation({workspaceDir:Q,candidatePath:draft,finalPath:path.join(Q,'output',`Pre6_Group2_CPU_Integration_EN_${REV}.pptx`),pythonExecutable:PY,integrityValidatorPath:path.join(SKILL,'container_tools/inspect_presentation_package_integrity.py'),layoutValidatorPath:path.join(SKILL,'container_tools/inspect_presentation_layout_geometry.py'),layoutArgs:['--expected-slide-size-emu','12192000,6858000',...owners.flatMap(x=>['--require-native-table-slide',String(x)])],explicitTotalSlideCount:24,requiredNativeTableOwnerSlides:owners,requiredNativeChartOwnerSlides:[21,23],nativeChartTargetApplication:'portable',materializeLiteralChartWorkbooks:true,fontPolicy:{basis:'design',families:['Arial']},verifyArtifactToolImport:true,receiptPath:path.join(Q,`validation-${REV}.json`)});
console.log(JSON.stringify({status:'PRE6_R3_READY',slides:24,result}));
