"""Chapter-numbered Pre6 story; Chinese verified figures, English presentation."""
from copy import deepcopy
from narrative_v2 import SLIDES as PREVIOUS, QUESTIONS

CHAPTERS={
 '1':'ISA Design','2':'Design Process','3':'Architecture and Execution',
 '4':'Functional Verification','5':'Performance and Trade-offs','6':'Delivery'
}
TOPICS={
 2:('1.1','Instruction encoding'),3:('1.2','Operands and state updates'),
 4:('2.1','Constraints, decisions and design order'),5:('3.1','Overall CPU architecture'),
 6:('3.1.1','Five-stage datapath'),7:('3.1.2','Forwarding and branch paths'),
 8:('3.2','System integration and interfaces'),9:('3.2.1','EES-331 board integration'),
 10:('3.3','Pipeline control'),11:('3.3.1','Operating modes and priority'),
 12:('3.3.2','Dependencies and resolution'),13:('3.3.3','Load-to-store execution'),
 14:('3.3.4','Branch and cancellation'),15:('3.3.5','Precise HALT and fault handling'),
 16:('4.1','Verification strategy'),17:('4.2','Baseline: program to waveform'),
 18:('4.3','Checksum: model to board'),19:('5.1','Counters and cycle model'),
 20:('5.2','Measured cycles and CPI'),21:('5.3','FPGA mapping and timing'),
 22:('5.4','Optimization trade-offs'),23:('6.1','Deliverables')
}
SPEECH={
1:"We present a sixteen-bit, five-stage CPU integrated and verified on EES-331.",
2:"Every instruction occupies sixteen bits. The fields contain a four-bit opcode, two register fields, and an eight-bit immediate or displacement. This is the complete ISA encoding, including the reserved opcodes. AND and OR use two and three; loads and stores use eight and nine. Each instruction defines how its register fields are used. All four registers are writable.",
3:"These rules determine our datapath. Register arithmetic reads both fields. Immediate MOV uses an extended constant. A store reads its base from Rs and its data from Rd. Constants and absolute jumps use zero extension; memory and relative-branch offsets use sign extension. ADD and SUB update carry and overflow, while CMP updates Z. The remaining instructions preserve these flags.",
4:"This table links constraints to engineering decisions. Synchronous memories led us to align their registered outputs with the decode and writeback boundaries. Register dependencies led to forwarding and bypass. Load latency required a one-cycle interlock. Branches and stopping events required age-based arbitration. The design order runs from ISA and interfaces through timing, control, integration, and verification. B will now show how these decisions form the hardware.",
5:"The complete architecture has control above the five-stage datapath, with synchronous instruction and data memories outside the core. Control combines global mode, traveling instruction intentions, and cross-stage decisions. The lower feedback paths return the information needed for those decisions.",
6:"The four pipeline boundaries keep instruction data, control, and valid tags aligned. Notice the two memory outputs. Registered IM data supplies the decode boundary, and registered DM data supplies the load value in writeback. This arrangement implements the one-cycle memory contract within five pipeline stages. Each stage carries the same instruction's remaining information forward.",
7:"Follow the forwarding paths first. Execute selects the newest ready Rd and Rs values before the ALU input multiplexers choose the operands. Loads and stores use Rs plus the signed displacement; store data follows its separate Rd path. The comparison and branch-target paths are also separate. A JZ selects the newest qualified CMP result, and an accepted redirect returns its target to the PC.",
8:"The system connects the core to separate instruction and data memories. Each holds two hundred and fifty-six sixteen-bit words. The interface table shows the requests, returned data, and access qualifiers. The core checks the full effective address before selecting a physical memory location. File initialization supplies the starting program and data; committed data memory is retained across a core reset.",
9:"The EES-331 layer adds clock buffering, synchronized reset release, counters, LEDs, and VIO. The clock enters at M19; S1 is the active-low request at L18. VIO observes a register writeback shadow and the state and performance probes. Its reset output controls program startup. C will now explain how the controller coordinates execution.",
10:"Control operates at three levels. Global mode handles running, draining, and stopping. Cross-stage logic evaluates dependencies, readiness, and instruction age. Local stage logic combines the traveling instruction intention with its current eligibility. For example, decode creates a register-write intention. That intention travels with the instruction; at writeback, a valid, fault-free slot produces the actual rf_we enable. This is how control stays attached to the correct data and token.",
11:"The five modes describe global operation. During RUN, different instructions occupy IF through WB concurrently. An accepted HALT or instruction fault starts the corresponding drain mode. The stop token reaches writeback before the final stopped mode. Reset restarts operation. Event arbitration follows instruction age: an older MEM fault suppresses a younger EX event while eligible older writeback completes.",
12:"Readiness determines the mechanism. Ready M and W values forward to execute, and WB-to-ID bypass handles a simultaneous read and write. A matching unready load blocks the older same-register value. The true consumer therefore waits one cycle, then receives the new value. The network checks both source roles independently, including store base and data. JZ uses its separate newest-Z selection path.",
13:"This case checks one load-use hold and one memory write. In cycle three, the load executes while the store waits in decode. Cycle four contains the execute bubble. Writeback forwards the loaded seven in cycle five. The store writes memory in six and keeps its writeback tag in seven. HALT completes in eight. A ready ALU result instead forwards without this hold. D will now explain branch and stopping behavior.",
14:"When JZ enters execute, the preceding CMP is in MEM and supplies its equality candidate. Cycle four redirects to PC three and cancels the younger store. The branch continues through the pipeline, and the target HALT completes in cycle nine. The trace checks the branch decision and confirms that the wrong-path store produces no memory write.",
15:"These two cases check completion by instruction age. Above, the older store writes in cycle four and retires before HALT stops the CPU at six. Below, cycle six combines an older ADD writeback, a memory-stage address fault, and a younger jump. The ADD completes, while the invalid access and jump are suppressed. The fault token reaches writeback and the CPU reports FAULTED at seven.",
16:"The ISA model supplies expected register, flag, store, and stopping behavior. Directed vectors check boundary values. Testbenches compare each qualified event and the final state. Module, independent, and integration suites exercise complementary layers. The next two pages follow actual programs through those checks, linking expected results to simulation and board observations.",
17:"In baseline, PCs five to seven form a store, load, and dependent compare. Cycle nine shows the older store proceeding while the front end holds. CMP sets Z, so JZ skips the next MOV. We expect R0 and R2 to equal eight, R1 to remain two, and seventeen cycles. The actual XSim trace and checker match these predictions.",
18:"The five board programs reached their expected stopping states and counts. For checksum, the model predicts R1 equal to hexadecimal one two three two, zero flags, HALT at PC zero zero two two, and fifty-five cycles. VIO reports the same values. The physical S1 sequence clears the state and then restarts the program to the same result. E will explain the performance costs.",
19:"We count completed instructions N, load-use stalls S, and accepted redirects R. For these normal-HALT programs, total cycles equal N plus four plus S plus twice R. N includes HALT. Four accounts for pipeline filling and completion, and every accepted redirect adds two cycles. CPI is the total cycles divided by N.",
20:"The bars separate instructions from overhead. Baseline is ten plus four plus one plus two: seventeen cycles. Loop's four redirects add eight cycles. Checksum is thirty-five plus four plus sixteen: fifty-five. Its CPI is one point five seven, below baseline's one point seven zero, because more instructions spread the fixed overhead. These bars explain each workload. Comparing the same program under matched conditions measures a design improvement.",
21:"All five routed board implementations achieve positive setup and hold slack under the ten-nanosecond constraint. Each uses two BRAM18 blocks. The table gives complete board-top resources, including memories and VIO. These results confirm the timing target for the integrated design.",
22:"WB-to-MEM forwarding cuts checksum from fifty-five to forty-seven cycles: fourteen point five percent fewer cycles, at eighty-six extra LUTs and two flip-flops. It removes store-data dependencies; a load feeding the store base still requires a hold. AC1 is our board-verified release, and the candidate is a quantified upgrade. The separate forwarding-MUX experiment provided no cycle benefit.",
23:"We delivered the ISA, integrated datapath and control, functional evidence, and performance analysis. The course folder contains the specification, presentation, group script, and two ready-to-use Vivado project entries. Thank you."
}
SECONDS={1:10,5:20,6:40,7:40,14:30,15:40,16:25,17:40,18:35,20:60,22:30}
SLIDES=[]
for old,cfg0 in enumerate(PREVIOUS,1):
 cfg=deepcopy(cfg0);cfg['reference_page']=old;cfg['speech']=SPEECH[old];cfg['seconds']=SECONDS.get(old,cfg['seconds'])
 if old==1:
  cfg.update(title='CPU Integration and Verification',code='',chapter='Project',section='Project',parent='')
 else:
  code,label=TOPICS[old];chapter=CHAPTERS[code.split('.')[0]]
  cfg.update(title=code+' '+label,short_title=label,code=code,chapter=chapter,section=chapter,parent=code.rsplit('.',1)[0])
 SLIDES.append(cfg)
 if old==1:
  SLIDES.append(dict(title='Contents',short_title='Contents',code='',chapter='Contents',parent='',section='Contents',speaker='A',seconds=10,
     speech='We will cover the ISA, design process, architecture and execution, functional evidence, and performance trade-offs.',
     cue='按六章目录指明主线；目录页只讲路线，不提前展开模块。',goal='Provide the numbered chapter structure and page ranges.',refs=['SPEC'],reference_page=0))

# Scope statements appear once in figure notes/footnotes; the spoken story advances the evidence.
SLIDES[4]['cue']='按约束—决策—结果讲两三个关键取舍，底部指设计先后顺序，末句交接B。'
SLIDES[15]['cue']='上下两个真实案例。CaseA: C4 store/C5 STR WB/C6 HALT。CaseB: C6老ADD写回与M.LDR越界同拍，年轻JUMP取消；C7 FAULTED。不是下一拍才让老WB完成。'
SLIDES[17]['cue']='左侧baseline实际指令05–07对应C9同时stall/store，08 JZ对应C12 redirect；右侧期望与实际RF/flags/C=17对齐。'
SLIDES[18]['cue']='先讲checksum预期与VIO实测对账，再指S1重启；raw state256/perf160仅在备注。平台图若使用手册图片，明确它是平台示意而非本次测试照片。'
SLIDES[22]['cue']='checksum 55→47为减少14.5%周期、同频1.17倍；不是14.5%速度提升。+86 LUT为含VIO整机增量，不能叫核心逻辑增加7.8%。'
BACKUPS=[]
assert len(SLIDES)==24 and sum(s['seconds']for s in SLIDES)==840
