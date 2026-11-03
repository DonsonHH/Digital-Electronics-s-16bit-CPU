"""Read the frozen baseline and generate presentation data. No hardware or simulation launch."""
from pathlib import Path
import csv,hashlib,json,re,subprocess,sys
B=Path(__file__).resolve().parent;OUT=B.parent;ROOT=OUT.parent;P=ROOT/'CPU核心设计'
sys.path.insert(0,str(P/'文档源'))
from source_validation import read,check_rtl_contract,extract_examples,verify_board_validation
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def write(p,v):Path(p).write_text(json.dumps(v,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
FROZEN_BASELINE='9475f210c7e567cb41f3856ff3bcebc6611ac991'
FROZEN_DOCUMENT_SOURCES={f'CPU核心设计/文档源/{name}.json'for name in ['architecture','content','sections']}
def source_bytes(relative,baseline=FROZEN_BASELINE):
 """Pre6 cites r4 authoring sources; later editorial editions may coexist on main."""
 relative=Path(relative).as_posix()
 if relative in FROZEN_DOCUMENT_SOURCES:
  return subprocess.check_output(['git','show',f'{baseline}:{relative}'],cwd=ROOT)
 return (ROOT/relative).read_bytes()
def collect_frozen():
 baseline=FROZEN_BASELINE
 assert subprocess.check_output(['git','rev-parse','cpu-v1.6-ac1-ees331-verified^{}'],cwd=ROOT,text=True).strip()==baseline
 arch=json.loads(source_bytes('CPU核心设计/文档源/architecture.json'));rtl=check_rtl_contract(arch);board=verify_board_validation(arch)
 trace_dir=P/'验证记录/cpu_ac1_independent_lh6jb16m';examples=extract_examples(arch,trace_dir)
 primary=P/'验证/hardware_ac1_20261102_3dw9zgb5/result.json';hardware=read(primary)
 perf=read(P/'实验/性能基线.json');matrix=P/perf['matrix_relative'];assert sha(matrix)==perf['matrix_sha256'];routed=read(matrix)
 programs=[]
 for row in hardware['verified_programs']:
  actual=row['actual'];n=actual['completed'];s=actual['stalls'];r=actual['redirects'];c=actual['cycles'];assert c==n+4+s+2*r
  programs.append(dict(program=row['program'],N=n,S=s,R=r,C=c,CPI=round(c/n,3),rf_shadow=[f'{v:04X}'for v in actual['rf']],flags=actual['flags'],stop_pc=f"{actual['stop_pc']:04X}",last_store_addr=f"{actual['last_store_addr']:04X}",last_store_data=f"{actual['last_store_data']:04X}",stores=actual['stores'],record=row['record']))
 source={'SPEC':['CPU核心设计/文档源/architecture.json','CPU核心设计/文档源/content.json','CPU核心设计/文档源/sections.json'],'ISA':['CPU核心设计/Vivado/rtl/isa_decode.v','CPU核心设计/文档源/sections.json'],'RTL':['CPU核心设计/Vivado/rtl/datapath_core.sv'],'FLOW':['CPU核心设计/文档源/content.json'],'SYSTEM':['CPU核心设计/系统/rtl/cpu_system.sv','CPU核心设计/板级/rtl/ees331_top.sv','CPU核心设计/板级/rtl/ees331_application.sv'],'DIAGRAMS':['CPU核心设计/架构图/01_CPU整体架构.svg','CPU核心设计/架构图/02_五级Datapath.svg','CPU核心设计/架构图/03_文件启动系统与停止观测.svg','CPU核心设计/架构图/04_EES331板级系统.svg'],'CW':['CPU核心设计/文档源/architecture.json'],'INDEPENDENT':[str((trace_dir/'independent_result.json').relative_to(ROOT)),str((trace_dir/'independent_results.csv').relative_to(ROOT))],'BOARD':[str(primary.relative_to(ROOT))],'BUTTON':[str(primary.relative_to(ROOT)),str((primary.parent/'button_snapshots.tsv').relative_to(ROOT)),str((primary.parent/'button_session_long.log').relative_to(ROOT))],'PERFORMANCE':[str(primary.relative_to(ROOT))],'PPA':[str(matrix.relative_to(ROOT))],'CANDIDATE':['CPU核心设计/实验/WB_MEM候选比较.json'],'HOST_CHECKS':['CPU核心设计/验证/final_baseline_20261102_p824cngb/final_qa.json']}
 source['FORWARD_CANDIDATE']=['CPU核心设计/实验/前递候选比较.json']
 for code,case in [('SIM_LOAD','DOC_LOAD_STR'),('SIM_ADD','DOC_ADD_ADD'),('SIM_BRANCH','DOC_CMP_JZ'),('SIM_STORE_HALT','DOC_STR_HALT'),('SIM_FAULT','MEM_FAULT_OVER_BRANCH')]:source[code]=[str((trace_dir/'independent_cycles.csv').relative_to(ROOT)),str((trace_dir/'cases.json').relative_to(ROOT))]
 for row in routed['rows']:
  source['PPA'].extend('CPU核心设计/'+row['attempt_relative']+'/'+name for name in ['result.json','reports/timing.rpt','reports/utilization.rpt'])
 inputs={name:hashlib.sha256(source_bytes(name)).hexdigest()for paths in source.values()for name in paths}
 for record in hardware['program_records'].values():
  for name in ['result.json','snapshots.tsv','hardware.log']:inputs['CPU核心设计/'+record+'/'+name]=sha(P/record/name)
 for name,digest in inputs.items():
  git_name=Path(name).as_posix()
  frozen=subprocess.check_output(['git','show',f'{baseline}:{git_name}'],cwd=ROOT)
  assert hashlib.sha256(frozen).hexdigest()==digest,f'Frozen baseline input changed: {name}'
 docs=json.loads(source_bytes('CPU核心设计/文档源/sections.json'))['sections'];tables={}
 for k in ['指令编码与完整语义','外部接口']:
  tables[k]=[node['rows']for node in docs[k]['children']if node.get('kind')=='table']
 data={'baseline_commit':baseline,'tag':'cpu-v1.6-ac1-ees331-verified','CPU':'v1.6','ISA':'v1.5','implementation':'AC1','production_RTL_sha256':rtl,'programs':programs,'examples':examples['examples'],'button':hardware['button_samples'],'routed':routed['rows'],'candidate':read(P/'实验/WB_MEM候选比较.json')['rows'],'tables':tables,'source_groups':source,'input_sha256':inputs,'board_evidence_status':board['status'],'new_hardware_or_XSim_execution':False}
 with (primary.parent/'button_snapshots.tsv').open(encoding='utf-8-sig',newline='') as f:
  data['raw_button']=list(csv.DictReader(f,fieldnames=['label','timestamp_ms','state256_hex','perf160_hex'],delimiter='\t'))
 return data
