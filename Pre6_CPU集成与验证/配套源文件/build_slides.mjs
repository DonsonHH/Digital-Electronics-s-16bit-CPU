import fs from 'node:fs/promises';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
import {Presentation,PresentationFile} from '@oai/artifact-tool';
const ROOT=path.resolve(process.argv[2]), Q=path.resolve(process.argv[3]);
const revision=process.argv[4]??'r01';
process.env.RUNTIME_NODE_MODULES??='C:/Users/Donson/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules';
const SKILL='C:/Users/Donson/.codex/plugins/cache/openai-primary-runtime/presentations/26.1026.10807/skills/presentations';
const PY='C:/Users/Donson/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe';
const {finalizePresentation,applyPresentationChartFont}=await import(pathToFileURL(path.join(SKILL,'container_tools/artifact_tool_utils.mjs')).href);
const data=JSON.parse(await fs.readFile(path.join(ROOT,'配套源文件/evidence.json'),'utf8'));
const content=JSON.parse(await fs.readFile(path.join(ROOT,'配套源文件/content.json'),'utf8'));
const sources=JSON.parse(await fs.readFile(path.join(ROOT,'配套源文件/source_map.json'),'utf8'));
const P=Presentation.create({slideSize:{width:1280,height:720}});
const C={navy:'#14354B',teal:'#087F8C',ink:'#213746',muted:'#536B7A',grid:'#CFDCE4',pale:'#EAF3F7',mint:'#E5F4F1',orange:'#D78732',warm:'#FFF0DC',white:'#FFFFFF',grey:'#8FA4B2'};
let count=0,objects=[];
const none={fill:'none',width:0,style:'solid'};
function rect(s,x,y,w,h,fill=C.white,stroke=C.grid){return s.shapes.add({geometry:'rect',position:{left:x,top:y,width:w,height:h},fill,line:{fill:stroke,width:1.2,style:'solid'}});}
function text(s,t,x,y,w,h,size=28,color=C.ink,bold=false,align='left'){
 const z=s.shapes.add({geometry:'textbox',position:{left:x,top:y,width:w,height:h},fill:'none',line:none});z.text=String(t);z.text.style={fontSize:size,typeface:'Arial',color,bold,alignment:align,verticalAlignment:'top',wrap:'square',autoFit:'none',insets:0};
 objects.push({slide:count,text:String(t),x,y,w,h,size});return z;
}
function box(s,t,x,y,w,h,{fill=C.pale,stroke=C.grid,size=27,color=C.navy,bold=false}={}){const a=rect(s,x,y,w,h,fill,stroke);text(s,t,x+12,y+8,w-24,h-16,size,color,bold,'center');return a;}
function line(s,x1,y1,x2,y2,color=C.navy,width=2,arrow=false,dashed=false){
 return s.shapes.add({geometry:'connector',kind:'straight',position:{left:Math.min(x1,x2),top:Math.min(y1,y2),width:Math.abs(x2-x1),height:Math.abs(y2-y1),horizontalFlip:x2<x1,verticalFlip:y2<y1},line:{fill:color,width,style:dashed?'dashed':'solid'},tail:{type:arrow?'triangle':'none'}});
}
function pathline(s,points,color=C.teal,width=2,dashed=false){points.slice(1).forEach((p,i)=>line(s,...points[i],...p,color,width,i===points.length-2,dashed));}
function table(s,values,x,y,width,colWidths,rowH=50,size=25){
 const t=s.tables.add({rows:values.length,columns:values[0].length,left:x,top:y,width,height:values.length*rowH,columnWidths:colWidths,values:values.map(r=>r.map(String))});
 t.borders.assign({fill:C.grid,width:.8,style:'solid'});
 for(let r=0;r<values.length;r++){
  t.rows[r].height=rowH;
  for(let c=0;c<values[r].length;c++){
   const cell=t.getCell(r,c);cell.fill=r===0?C.navy:r%2?C.white:C.pale;
   cell.text.style={fontSize:size,typeface:'Arial',bold:r===0,color:r===0?C.white:C.ink,verticalAlignment:'middle',alignment:c===0?'left':'center',autoFit:'none',insets:6};
  }
 }
 return t;
}
function caption(s,t,y=620){text(s,t,64,y,1152,52,25,C.ink);}
function make(i){
 count=i+1;const cfg=i<12?content.main[i]:content.backup[i-12];const s=P.slides.add();s.background.fill=C.white;
 text(s,cfg.title,64,42,1140,62,44,C.navy,true);line(s,64,120,1216,120,C.teal,3);
 text(s,`${i<12?'Group 2 Pre6':'Q&A reference'}   ${String(i+1).padStart(2,'0')}`,64,686,1152,22,17,C.muted);
 const meta=sources[i];s.speakerNotes.text=[i<12?`Speaker ${cfg.speaker}. Target ${cfg.seconds} seconds.`:'Backup slide. Open when asked.',cfg.goal,'',i<12?cfg.speech:cfg.answer,'',`Chinese cue: ${cfg.cue}`,'','Evidence sources',...meta.sources.map(x=>`${x.relative}  SHA256 ${x.sha256}`),'',`CPU baseline ${data.baseline_commit}. ${data.tag}.`,meta.supports].join('\n');
 return s;
}
function stageTrace(s,ex,labels,y=218,rowH=62){
 const vals=[['Instruction',...ex.rows.map(r=>r[0])]];
 for(const [pc,label]of labels){
  vals.push([label,...ex.rows.map(r=>{
   if(r[1]===pc)return 'IF';
   for(const [idx,stage]of [[2,'ID'],[3,'EX'],[4,'MEM'],[5,'WB']])if(r[idx].startsWith(pc+':'))return stage+(stage==='ID'&&r[6].includes('保持')?'\nhold':'');
   return '–';
  })]);
 }
 const first=220,step=(1152-first)/ex.rows.length;const t=table(s,vals,64,y,1152,[first,...ex.rows.map(()=>step)],rowH,24);
 for(let r=1;r<vals.length;r++)for(let c=1;c<vals[r].length;c++){
  const v=vals[r][c],cell=t.getCell(r,c);cell.fill=v==='–'?C.white:v.includes('hold')?C.warm:v==='WB'?C.mint:C.pale;
  if(v.includes('hold'))cell.text.style={fontSize:24,typeface:'Arial',color:C.orange,verticalAlignment:'middle',alignment:'center',insets:6};
 }
 return t;
}
const examples=Object.fromEntries(data.examples.map(x=>[x.case,x]));
// 1: minimal cover with an actual pipeline motif, rather than a decorative photograph.
{
 const s=make(0);
 text(s,'A 16-bit five-stage CPU on EES-331',64,166,1110,62,42,C.ink);
 ['IF','ID','EX','MEM','WB'].forEach((name,i)=>{box(s,name,64+i*232,292,208,92,{fill:i===2?C.teal:C.pale,color:i===2?C.white:C.navy,size:36,bold:true});if(i<4)line(s,272+i*232,338,296+i*232,338,C.navy,2,true);});
 text(s,'CPU v1.6     ISA v1.5     Default AC1',64,444,1152,52,32,C.navy,true);
 text(s,'Frozen design, archived execution evidence, physical cycle counters',64,520,1100,70,29,C.muted);
 text(s,'Group 2',1040,614,176,36,28,C.teal,true,'right');
}
// 2: ISA fields and the behavior that drives resource allocation.
{
 const s=make(1);const widths=[280,180,180,512],names=['Opcode\n4 bits','Rd\n2 bits','Rs\n2 bits','Immediate / offset\n8 bits'];let x=64;
 names.forEach((n,i)=>{box(s,n,x,162,widths[i]-4,94,{fill:i===0?C.teal:C.pale,color:i===0?C.white:C.navy,size:28,bold:true});x+=widths[i];});
 table(s,[['Instruction group','Operand behavior','Architectural writes'],['MOV / AND / OR','Real sources vary by form','RF'],['ADD / SUB','Rd with Rs or zero-extended u8','RF and C/V'],['LDR / STR','Rs base + signed s8; separate STR data','RF or DM'],['CMP / JUMP / JZ / HALT','Compare, redirect or stop','Z or control flow']],64,300,1152,[320,510,322],54,26);
 caption(s,'R0–R3 are writable. CMP writes Z. SUB carry means no borrow.');
}
// 3: dependency flow with course milestones as historical context.
{
 const s=make(2);const steps=[['1','ISA and constraints'],['2','Resources and interfaces'],['3','Pipeline timing and payloads'],['4','Decode and coordination'],['5','System integration'],['6','Simulation, routing and board checks']];
 steps.forEach(([n,t],i)=>{const col=i%3,row=Math.floor(i/3),x=64+col*393,y=174+row*190;text(s,n,x,y,50,50,40,C.teal,true);text(s,t,x+66,y,260,120,30,C.navy,true);if(col<2)line(s,x+338,y+35,x+370,y+35,C.grey,2,true);});
 line(s,1190,304,1190,334,C.grey,2);line(s,1190,334,80,334,C.grey,2);line(s,80,334,80,364,C.grey,2,true);
 text(s,'Course milestones',64,568,300,40,28,C.teal,true);
 text(s,'Pre2 modules   /   Pre3 ISA and modules   /   Pre4 datapath   /   Pre5 control',64,614,1152,40,26,C.ink);
}
// 4: whole-system boundary and physical versus logical interface.
{
 const s=make(3);text(s,'Board-level integration',64,155,480,42,30,C.navy,true);
 rect(s,64,208,744,346,C.white,C.navy);
 box(s,'Clock / reset\n100 MHz, S1, synchronizers',88,234,696,75,{size:27});
 box(s,'Synchronous IM\n256 × 16',88,358,184,112,{size:25});box(s,'datapath_core\nCU + DP',302,346,266,136,{fill:C.mint,stroke:C.teal,size:30,bold:true});box(s,'Synchronous DM\n256 × 16',598,358,186,112,{size:25});
 line(s,272,414,302,414,C.navy,2,true);line(s,568,414,598,414,C.navy,2,true);
 box(s,'VIO and counters\nRead observations / request reset',850,214,366,132,{fill:C.mint,size:28});
 line(s,784,270,850,270,C.teal,2,true);text(s,'clk',792,237,55,28,22,C.teal);
 pathline(s,[[1032,214],[1032,198],[620,198],[620,234]],C.orange,2);
 text(s,'VIO reset request',772,159,400,30,24,C.orange);
 line(s,435,309,435,346,C.navy,2,true);
 line(s,302,390,272,390,C.navy,2,true);line(s,598,445,568,445,C.navy,2,true);
 pathline(s,[[570,480],[832,480],[832,280],[850,280]],C.teal,2);
 table(s,[['Interface','Examples'],['Core memory','addr/data 16b\nen/we 1b'],['Board pins','M19 clk / L18 S1\n8 LEDs'],['JTAG / VIO','RF shadow\nflags / stop / counts']],850,388,366,[138,228],62,22);
 text(s,'Core ports connect to memories.\nVIO observations do not feed operands.',64,612,744,66,25,C.ink);
}
// 5: simplified yet signal-faithful native vector datapath.
{
 const s=make(4);const xs=[64,296,528,760,992],stages=['IF','ID','EX','MEM','WB'];
 stages.forEach((v,i)=>{text(s,v,xs[i],153,208,40,32,C.teal,true,'center');if(i<4)line(s,xs[i]+220,220,xs[i]+220,504,C.grid,6);});
 ['IF/ID','ID/EX','EX/MEM','MEM/WB'].forEach((v,i)=>text(s,v,xs[i]+170,493,101,30,21,C.muted,false,'center'));
 const top=['PC / +1\nhold / redirect','Decode / RF\n2 reads, 1 write','Forwarding\nM > W > saved','EA check\nexecution pass','WB select\nexecution / load'];
 const low=['Sync IM\nregistered dout','Immediate\nzero / sign','ALU / compare\nbranch target','Sync DM\nread / store','Qualified writes\nRF / flags'];
 top.forEach((t,i)=>box(s,t,xs[i],236,208,90,{size:25}));low.forEach((t,i)=>box(s,t,xs[i],390,208,90,{fill:i===2?C.mint:C.pale,size:25}));
 line(s,168,326,168,390,C.navy,2,true);pathline(s,[[272,435],[284,435],[284,281],[296,281]],C.navy,2);
 line(s,504,281,528,281,C.navy,2,true);line(s,632,326,632,390,C.navy,2,true);line(s,504,435,528,435,C.navy,2,true);
 pathline(s,[[736,435],[748,435],[748,281],[760,281]],C.navy,2);line(s,864,326,864,390,C.navy,2,true);
 line(s,968,281,992,281,C.navy,2,true);pathline(s,[[968,435],[980,435],[980,302],[992,302]],C.navy,2);line(s,1096,326,1096,390,C.navy,2,true);
 pathline(s,[[864,236],[864,214],[650,214],[650,236]],C.teal,2);
 pathline(s,[[1096,236],[1096,202],[612,202],[612,236]],C.teal,2);
 pathline(s,[[1096,480],[1096,584],[290,584],[290,300],[296,300]],C.teal,2);
 pathline(s,[[726,302],[742,302],[742,526],[946,526],[946,480]],C.teal,2,true);
 text(s,'STR data: forwarded Rd',752,538,337,30,23,C.teal);
 pathline(s,[[528,445],[520,445],[520,558],[52,558],[52,260],[64,260]],C.orange,2,true);
 text(s,'Qualified EX redirect',64,525,360,30,23,C.orange);
 text(s,'Data, CW and tags stay aligned across four logical boundaries.\nRegistered IM/DM outputs supply the D/W data boundaries.',64,612,1152,66,27,C.ink);
}
// 6: three control layers plus an explicit intention-to-enable relation.
{
 const s=make(5);box(s,'Global operating mode\nRUN, DRAIN_HALT, DRAIN_FAULT, HALTED, FAULTED',64,164,1152,100,{fill:C.pale,size:30,bold:true});
 box(s,'Cross-stage coordination\nDependencies, readiness, instruction age, redirect and stop events',64,292,1152,90,{fill:C.mint,stroke:C.teal,size:29,bold:true});
 ['IF request','ID issue','EX action','MEM access','WB write'].forEach((t,i)=>{box(s,t,64+i*232,425,208,66,{size:27});line(s,168+i*232,382,168+i*232,425,C.teal,2,true);});
 text(s,'CW intention',64,542,250,42,30,C.navy,true);text(s,'valid + fault + mode + reset',370,542,510,42,30,C.teal,true);text(s,'actual action',940,542,276,42,30,C.navy,true);
 line(s,293,561,345,561,C.navy,2,true);line(s,876,561,926,561,C.navy,2,true);
 text(s,'reg_write in ID',64,594,280,36,27,C.ink);text(s,'qualified W slot',430,594,370,36,27,C.ink);text(s,'rf_we at WB',950,594,266,36,27,C.ink);
}
// 7: source-bound eight-cycle load-to-store example.
{
 const s=make(6),ex=examples.DOC_LOAD_STR;
 text(s,'Simulation initial state: R3=0020, R1=0021, DM[0020]=0007',64,155,1152,42,27,C.muted);
 const t=stageTrace(s,ex,[['00','LDR R0,[R3]'],['01','STR R0,[R1]'],['02','HALT']],216,61);
 text(s,'C3',64,506,100,44,32,C.orange,true);text(s,'Hold PC / ID\nInsert X bubble',64,555,310,75,28,C.ink);
 text(s,'C5',460,506,100,44,32,C.teal,true);text(s,'Forward ready W load\ninto store EX operands',460,555,360,75,28,C.ink);
 text(s,'C6 / C7',894,506,240,44,32,C.navy,true);text(s,'Write DM once\nKeep STR WB tag',894,555,322,75,28,C.ink);
 line(s,350,539,423,539,C.grey,2,true);line(s,790,539,858,539,C.grey,2,true);
 rect(s,64,642,1152,34,C.mint,C.mint);text(s,'ADD in M  →  ADD in EX: ready result forwarded, 0 data stalls',78,646,1124,28,23,C.teal,true);
}
// 8: branch, wrong-path store and target HALT from a separate real simulation case.
{
 const s=make(7),ex=examples.DOC_CMP_JZ;
 text(s,'Simulation: R0=R1=0001. JZ at pc1 targets pc3.',64,155,1152,42,28,C.muted);
 const t=stageTrace(s,ex,[['00','CMP R0,R1'],['01','JZ +1'],['02','STR (wrong path)'],['03','HALT (target)']],214,61);
 t.getCell(3,4).value='ID\nflush';t.getCell(3,4).fill=C.warm;t.getCell(3,4).text.style={fontSize:24,typeface:'Arial',color:C.orange,verticalAlignment:'middle',alignment:'center',insets:6};
 text(s,'C4: latest M-stage CMP Z selects the branch condition',64,548,1152,42,29,C.teal,true);
 text(s,'Wrong-path STR never writes DM. Target HALT completes at WB in C9.',64,604,1152,56,28,C.ink);
}
// 9: actual independent data and per-edge inspection, rather than a screenshot collage.
{
 const s=make(8);text(s,'Shared inputs and the ISA contract',64,150,1152,34,26,C.muted);
 box(s,'ISA model\nexpected instruction effects',64,194,450,88,{size:29,bold:true});
 box(s,'DUT / testbench\nactual per-edge events',766,194,450,88,{fill:C.mint,size:29,bold:true});
 box(s,'Automatic checks',480,302,320,64,{fill:C.mint,stroke:C.teal,size:28,bold:true});
 pathline(s,[[289,282],[289,334],[480,334]],C.teal,2);pathline(s,[[991,282],[991,334],[800,334]],C.teal,2);
 table(s,[['Archived trace check','Expected','Observed'],['Load-use hold','1 front-end stall','1'],['Store side effect','1 qualified MEM write','1'],['End of program','HALT at C8','C8']],64,392,1152,[522,390,240],55,27);
 caption(s,'External-ISA archive: 48 cases, 10 reset witnesses. Internal timing evidence is simulation.');
}
// 10: decoded physical captures. No fabricated GUI or board photograph.
{
 const s=make(9);text(s,'Decoded archived VIO snapshots',64,155,1152,44,28,C.teal,true);
 table(s,[['Program','Cycles','N','S','R'],...data.programs.map(r=>[r.program,r.C,r.N,r.S,r.R])],64,221,670,[274,124,90,90,92],52,27);
 text(s,'copy_checksum',786,223,430,40,31,C.navy,true);text(s,'RF writeback shadow',786,280,430,36,27,C.muted);
 text(s,'R0  0000     R1  1232\nR2  0000     R3  0020',786,330,430,92,28,C.ink,true);
 text(s,'Z/C/V = 0/0/0\nstop_pc = 0022\nHALTED = 1, fault = 0',786,447,430,110,27,C.ink);
 ['Before: stopped\n55 cycles','S1 held: reset\n0 cycles','Released: stopped\n55 cycles'].forEach((v,i)=>{box(s,v,64+i*393,583,364,74,{fill:i===1?C.warm:C.mint,size:26});if(i<2)line(s,428+i*393,620,452+i*393,620,C.teal,2,true);});
}
// 11: editable native chart and an exact data table.
{
 const s=make(10);text(s,'C = N + 4 + S + 2R',64,151,730,56,40,C.navy,true);text(s,'CPI = C / N',881,157,335,44,32,C.teal,true);
 const chart=s.charts.add('bar',{position:{left:55,top:240,width:676,height:320},categories:data.programs.map(r=>r.program),series:[{name:'N instructions',values:data.programs.map(r=>r.N),fill:C.navy},{name:'Fill / finish',values:data.programs.map(()=>4),fill:C.grey},{name:'S stalls',values:data.programs.map(r=>r.S),fill:C.orange},{name:'2R redirects',values:data.programs.map(r=>2*r.R),fill:C.teal}],barOptions:{direction:'bar',grouping:'stacked',overlap:100,gapWidth:90},hasLegend:true,legend:{position:'bottom',textStyle:{fontSize:21,typeface:'Arial'}},xAxis:{textStyle:{fontSize:22,typeface:'Arial'}},yAxis:{minimumScale:0,maximumScale:60,majorUnit:20,textStyle:{fontSize:21,typeface:'Arial'},majorGridlines:{fill:C.grid,width:1,style:'solid'}},dataLabels:{showValue:false,textStyle:{fontSize:20,typeface:'Arial'}},chartFill:C.white,plotAreaFill:C.white});
 applyPresentationChartFont(chart,{fontFamily:'Arial'});
 table(s,[['Program','C','CPI'],...data.programs.map(r=>[r.program,r.C,(r.C/r.N).toFixed(2)])],768,241,448,[248,80,120],49,25);
 text(s,'baseline: 10 + 4 + 1 + 2 = 17\nchecksum: 35 + 4 + 16 + 0 = 55',64,580,1152,66,28,C.ink);
 text(s,'Normal-HALT cases only. N includes HALT. Board cycles; time conversion assumes 100 MHz.',64,653,1152,25,20,C.muted);
}
// 12: direct alignment with the assignment.
{
 const s=make(11);const items=[['ISA design','Defined encoding, operands and state updates'],['Design process','Contracts guide resources, timing and integration'],['CPU architecture','Connected datapath, control and board interfaces'],['Verification','Simulation timing, physical results and cycle explanation']];
 items.forEach(([a,b],i)=>{text(s,String(i+1),64,175+i*102,70,60,42,C.teal,true);text(s,a,148,173+i*102,390,45,32,C.navy,true);text(s,b,545,176+i*102,671,76,28,C.ink);if(i<3)line(s,148,255+i*102,1216,255+i*102,C.grid,1);});
 text(s,'Default AC1 is the accepted baseline. Candidate experiments remain separate.',64,611,1152,48,28,C.teal,true);
}
// 13: complete ISA in two side-by-side native tables.
{
 const s=make(12);const left=[['Op','Instruction','Flags'],['0','MOV Rd,Rs','hold'],['1','MOV Rd,#u8','hold'],['2','AND Rd,Rs','hold'],['3','OR Rd,Rs','hold'],['4','ADD Rd,Rs','C/V'],['5','ADD Rd,#u8','C/V'],['6','SUB Rd,Rs','C/V'],['7','SUB Rd,#u8','C/V']];
 const right=[['Op','Instruction','Flags'],['8','LDR Rd,[Rs+s8]','hold'],['9','STR Rd,[Rs+s8]','hold'],['A','CMP Rd,Rs','Z'],['B','Reserved','hold'],['C','JUMP #u8','hold'],['D','JZ #s8','hold'],['E','HALT','hold'],['F','Reserved','hold']];
 table(s,left,64,167,550,[70,340,140],49,25);table(s,right,666,167,550,[70,350,130],49,25);
 caption(s,'JUMP = ZExt(u8). Taken JZ = pc + 1 + SExt(s8). B/F fault on the accepted path.');
}
// 14: complete original execution-port contract, plus observation/board scope.
{
 const s=make(13);table(s,[['Core port','Direction','Bits','Purpose'],['clk / rst','in','1 each','Clock / synchronous reset'],['im_addr / im_en','out','16 / 1','Fetch word address / request'],['im_dout','in','16','Synchronous instruction return'],['dm_addr / dm_en / dm_we','out','16 / 1 / 1','Full EA / qualified access'],['dm_din','out','16','Forwarded store data'],['dm_dout','in','16','Synchronous load return'],['halted / fault','out','1 each','Final stopped mode']],64,166,1152,[390,130,162,470],51,24);
 text(s,'Original execution interface: 12 ports, 87 bits. Diagnostic outputs are additional.',64,606,1152,40,25,C.ink);
 text(s,'Board top: clk100 M19, S1 L18, 8 LEDs. VIO: state256, counters160, reset1.',64,647,1152,32,23,C.teal);
}
// 15: mode graph and qualified event order.
{
 const s=make(14);box(s,'RUN',85,300,160,80,{fill:C.mint,size:30,bold:true});box(s,'DRAIN_HALT',316,198,230,80,{size:27});box(s,'HALTED',612,198,170,80,{size:29});box(s,'DRAIN_FAULT',316,416,230,80,{size:27});box(s,'FAULTED',612,416,170,80,{size:29});
 pathline(s,[[245,320],[279,320],[279,238],[316,238]],C.teal);pathline(s,[[245,360],[279,360],[279,456],[316,456]],C.orange);
 line(s,546,238,612,238,C.teal,2,true);line(s,546,456,612,456,C.orange,2,true);
 text(s,'HALT',261,170,130,31,23,C.teal);text(s,'fault',259,498,130,31,23,C.orange);
 text(s,'WB token + empty next pipeline',305,328,495,70,25,C.ink,true);
 table(s,[['Priority','Qualified event'],['1','Synchronous reset'],['2','Older MEM fault'],['3','EX fault / HALT'],['4','EX redirect'],['5','Load-use hold'],['6','Normal progress']],844,169,372,[110,262],57,24);
 caption(s,'Stopped modes hold until reset. CW_X/M/W are existing field groups: 18 / 7 / 5 bits.');
}
// 16: representative dependencies and age-related simulation witnesses.
{
 const s=make(15);table(s,[['Producer / consumer','Mechanism','Extra data stall'],['ALU / MOV to next true source','Ready M result to EX','0'],['LDR to next true source','Front hold, X bubble, then W to EX','1'],['LDR to STR data or base','Check both source roles in default AC1','1'],['WB and ID same address','Explicit RF read bypass','0'],['CMP to JZ','M / W / saved Z selection','0'],['Multiple writers, same register','Nearest producer wins; unready M load blocks old W','As required'],['Older MEM fault / younger EX','Cancel younger actions, preserve older WB','Simulation witness']],64,165,1152,[352,630,170],57,24);
 text(s,'R0 is ordinary. Use masks exclude false dependencies. Store writes only once in MEM.',64,646,1152,30,23,C.ink);
}
// 17: reference behavior and bounded coverage.
{
 const s=make(16);table(s,[['Evidence layer','What it checks','Scope'],['ISA reference','Expected instruction effects and explicit vectors','Independent behavior model'],['Simulation trace','Writes, held stages, bubbles, flush and drain','48 cases + 10 reset witnesses'],['Physical board','RF shadow, flags, stopping state, last store, counters','5 normal-HALT programs'],['Physical S1','Reset-state clear and restart after stopping','Checksum program'],['Host / document gates','Capture, decode, lifecycle and evidence binding','21 archived offline checks']],64,176,1152,[280,550,322],73,25);
 caption(s,'A passing finite set is not a full CPU proof or exhaustive arithmetic verification.');
}
// 18: literal raw sample plus decoded physical button sequence.
{
 const s=make(17);const primary=data.button[0].decoded;
 table(s,[['S1 sample','reset','R1 shadow','Cycles','HALTED'],...data.button.map(r=>[r.label,r.decoded.core_reset,r.decoded.rf[1].toString(16).padStart(4,'0').toUpperCase(),r.decoded.cycles,r.decoded.halted])],64,172,1152,[350,150,252,200,200],57,26);
 const raw=data.raw_button.find(r=>Object.values(r).includes('after_0'));
 text(s,'Raw TSV excerpt: after_0',64,493,1152,38,28,C.navy,true);
 text(s,`state256: ${raw.state256_hex}\nperf160:  ${raw.perf160_hex}`,64,540,1152,74,22,C.ink);
 text(s,'The physical observer reads VIO. It does not assert the VIO reset output during S1 testing.',64,650,1152,28,21,C.teal);
}
// 19: one top-level scope and exact archived P&R numbers.
{
 const s=make(18);table(s,[['Program','LUT total','FF','BRAM18','WNS (ns)','WHS (ns)'],...data.routed.map(r=>{const m=r.implementation;return[r.program,m.resources.lut_total,m.resources.ff,m.resources.bram18,m.timing.wns_ns.toFixed(3),m.timing.whs_ns.toFixed(3)];})],64,190,1152,[314,170,150,160,180,178],64,27);
 text(s,'Complete ees331_top includes memory, reset, counters, VIO and observation logic.',64,604,1152,40,27,C.ink);
 text(s,'Vivado 2025.2   /   xc7z020clg484-1   /   10 ns constraint   /   archived routed reports',64,648,1152,32,23,C.muted);
}
// 20: compare only paired offline builds, keeping default hardware identity explicit.
{
 const s=make(19);const selected=data.candidate.filter(r=>['memory_copy','copy_checksum'].includes(r.program));
 table(s,[['Program','AC1 cycles','WB-to-MEM','LUT delta','FF delta'],...selected.map(r=>[r.program,r.baseline_cycles,r.candidate_cycles,r.LUT_delta,r.FF_delta])],64,191,1152,[360,190,222,190,190],88,29);
 text(s,'Store base is consumed in EX. Candidate store data can arrive later in MEM.',64,511,1152,68,30,C.navy,true);
 text(s,'Default AC1 remains the physically accepted design. Candidate results are offline tests and routing.',64,606,1152,60,28,C.teal);
}

await fs.mkdir(Q,{recursive:true});await fs.mkdir(path.join(Q,'previews'),{recursive:true});await fs.mkdir(path.join(Q,'output'),{recursive:true});
for(let i=0;i<P.slides.items.length;i++){
 const s=P.slides.items[i];const png=await P.export({slide:s,format:'png',scale:1.5});await fs.writeFile(path.join(Q,'previews',`slide-${String(i+1).padStart(2,'0')}.png`),new Uint8Array(await png.arrayBuffer()));
}
const candidatePath=path.join(Q,`draft-${revision}.pptx`);await(await PresentationFile.exportPptx(P)).save(candidatePath);
await fs.writeFile(path.join(Q,'object_geometry.json'),JSON.stringify(objects,null,2));
const owners=[2,4,7,8,9,10,11,13,14,15,16,17,18,19,20];
const result=await finalizePresentation({workspaceDir:Q,candidatePath,finalPath:path.join(Q,'output',`Pre6_Group2_CPU_Integration_EN_${revision}.pptx`),pythonExecutable:PY,integrityValidatorPath:path.join(SKILL,'container_tools/inspect_presentation_package_integrity.py'),layoutValidatorPath:path.join(SKILL,'container_tools/inspect_presentation_layout_geometry.py'),layoutArgs:['--expected-slide-size-emu','12192000,6858000','--validate-heading-fit',...owners.flatMap(x=>['--require-native-table-slide',String(x)])],explicitTotalSlideCount:20,requiredNativeTableOwnerSlides:owners,requiredNativeChartOwnerSlides:[11],nativeChartTargetApplication:'portable',materializeLiteralChartWorkbooks:true,fontPolicy:{basis:'design',families:['Arial']},verifyArtifactToolImport:true,receiptPath:path.join(Q,`validation-${revision}.json`)});
console.log(JSON.stringify({status:'PPTX_FINALIZED',slides:P.slides.items.length,result}));
