"""Read the frozen baseline and generate presentation data. No hardware or simulation launch."""
from pathlib import Path
import csv,hashlib,json,re,subprocess,sys
B=Path(__file__).resolve().parent;OUT=B.parent;ROOT=OUT.parent;P=ROOT/'CPU核心设计'
sys.path.insert(0,str(P/'文档源'))
from source_validation import read,check_rtl_contract,extract_examples,verify_board_validation
from presentation_content import SLIDES,BACKUPS,QUESTIONS
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def write(p,v):Path(p).write_text(json.dumps(v,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
def main():
 baseline='9475f210c7e567cb41f3856ff3bcebc6611ac991'
 assert subprocess.check_output(['git','rev-parse','cpu-v1.6-ac1-ees331-verified^{}'],cwd=ROOT,text=True).strip()==baseline
 arch=read(P/'文档源/architecture.json');rtl=check_rtl_contract(arch);board=verify_board_validation(arch)
 trace_dir=P/'验证记录/cpu_ac1_independent_lh6jb16m';examples=extract_examples(arch,trace_dir)
 primary=P/'验证/hardware_ac1_20261102_3dw9zgb5/result.json';hardware=read(primary)
 perf=read(P/'实验/性能基线.json');matrix=P/perf['matrix_relative'];assert sha(matrix)==perf['matrix_sha256'];routed=read(matrix)
 programs=[]
 for row in hardware['verified_programs']:
  actual=row['actual'];n=actual['completed'];s=actual['stalls'];r=actual['redirects'];c=actual['cycles'];assert c==n+4+s+2*r
  programs.append(dict(program=row['program'],N=n,S=s,R=r,C=c,CPI=round(c/n,3),rf_shadow=[f'{v:04X}'for v in actual['rf']],flags=actual['flags'],stop_pc=f"{actual['stop_pc']:04X}",last_store_addr=f"{actual['last_store_addr']:04X}",last_store_data=f"{actual['last_store_data']:04X}",stores=actual['stores'],record=row['record']))
 source={'SPEC':['CPU核心设计/文档源/architecture.json','CPU核心设计/文档源/content.json','CPU核心设计/文档源/sections.json'],'ISA':['CPU核心设计/Vivado/rtl/isa_decode.v','CPU核心设计/文档源/sections.json'],'RTL':['CPU核心设计/Vivado/rtl/datapath_core.sv'],'FLOW':['CPU核心设计/文档源/content.json'],'SYSTEM':['CPU核心设计/系统/rtl/cpu_system.sv','CPU核心设计/板级/rtl/ees331_top.sv','CPU核心设计/板级/rtl/ees331_application.sv'],'DIAGRAMS':['CPU核心设计/架构图/01_CPU整体架构.svg','CPU核心设计/架构图/02_五级Datapath.svg','CPU核心设计/架构图/03_文件启动系统与停止观测.svg','CPU核心设计/架构图/04_EES331板级系统.svg'],'CW':['CPU核心设计/文档源/architecture.json'],'INDEPENDENT':[str((trace_dir/'independent_result.json').relative_to(ROOT)),str((trace_dir/'independent_results.csv').relative_to(ROOT))],'BOARD':[str(primary.relative_to(ROOT))],'BUTTON':[str(primary.relative_to(ROOT)),str((primary.parent/'button_snapshots.tsv').relative_to(ROOT)),str((primary.parent/'button_session_long.log').relative_to(ROOT))],'PERFORMANCE':[str(primary.relative_to(ROOT))],'PPA':[str(matrix.relative_to(ROOT))],'CANDIDATE':['CPU核心设计/实验/WB_MEM候选比较.json'],'HOST_CHECKS':['CPU核心设计/验证/final_baseline_20261102_p824cngb/final_qa.json']}
 for code,case in [('SIM_LOAD','DOC_LOAD_STR'),('SIM_ADD','DOC_ADD_ADD'),('SIM_BRANCH','DOC_CMP_JZ'),('SIM_STORE_HALT','DOC_STR_HALT'),('SIM_FAULT','MEM_FAULT_OVER_BRANCH')]:source[code]=[str((trace_dir/'independent_cycles.csv').relative_to(ROOT)),str((trace_dir/'cases.json').relative_to(ROOT))]
 for row in routed['rows']:
  source['PPA'].extend('CPU核心设计/'+row['attempt_relative']+'/'+name for name in ['result.json','reports/timing.rpt','reports/utilization.rpt'])
 inputs={name:sha(ROOT/name)for paths in source.values()for name in paths}
 for record in hardware['program_records'].values():
  for name in ['result.json','snapshots.tsv','hardware.log']:inputs['CPU核心设计/'+record+'/'+name]=sha(P/record/name)
 for name,digest in inputs.items():
  git_name=Path(name).as_posix()
  frozen=subprocess.check_output(['git','show',f'{baseline}:{git_name}'],cwd=ROOT)
  assert hashlib.sha256(frozen).hexdigest()==digest,f'Frozen baseline input changed: {name}'
 docs=read(P/'文档源/sections.json')['sections'];tables={}
 for k in ['指令编码与完整语义','外部接口']:
  tables[k]=[node['rows']for node in docs[k]['children']if node.get('kind')=='table']
 data={'baseline_commit':baseline,'tag':'cpu-v1.6-ac1-ees331-verified','CPU':'v1.6','ISA':'v1.5','implementation':'AC1','production_RTL_sha256':rtl,'programs':programs,'examples':examples['examples'],'button':hardware['button_samples'],'routed':routed['rows'],'candidate':read(P/'实验/WB_MEM候选比较.json')['rows'],'tables':tables,'source_groups':source,'input_sha256':inputs,'board_evidence_status':board['status'],'new_hardware_or_XSim_execution':False}
 with (primary.parent/'button_snapshots.tsv').open(encoding='utf-8-sig',newline='') as f:
  data['raw_button']=list(csv.DictReader(f,fieldnames=['label','timestamp_ms','state256_hex','perf160_hex'],delimiter='\t'))
 write(B/'evidence.json',data)
 content={'main':SLIDES,'backup':BACKUPS,'questions':QUESTIONS,'main_seconds':sum(s['seconds']for s in SLIDES),'buffer_seconds':60,'spoken_words':sum(len(re.findall(r"[A-Za-z0-9]+(?:['.-][A-Za-z0-9]+)*",s['speech']))for s in SLIDES)}
 assert len(SLIDES)==12 and len(BACKUPS)==8 and content['main_seconds']==840
 write(B/'content.json',content)
 mapping=[]
 design_actual={1:{'CPU':'v1.6','ISA':'v1.5','implementation':'AC1','baseline_commit':baseline},2:{'field_bits':[4,2,2,8],'ISA_semantics':tables['指令编码与完整语义'][0]},3:read(P/'文档源/content.json')['DESIGN_FLOW'],4:{'original_execution_ports':tables['外部接口'][0],'logical_memories':'256x16words each, synchronous','physical_board':'EES-331, M19clock,L18S1,8LED'},5:arch['payload'],6:{'ownership':arch['ownership'],'CW':arch['control_groups']},9:{'simulation_case':'DOC_LOAD_STR','actual':next(x['result']for x in examples['examples']if x['case']=='DOC_LOAD_STR'),'external_ISA_case_count':48,'reset_witnesses':10},12:{'accepted_scope':board['status'],'requirement_to_pages':{'ISA':[2,13],'process':[3],'structure_interfaces':[4,5,6,14,15],'functional':[7,8,9,10,17,18],'performance':[11,19,20]}},13:tables['指令编码与完整语义'][0],14:tables['外部接口'][0],15:{'CW':arch['control_groups'],'priority_source':'RTL datapath_core mode_next/qualified events'},16:[{'case':x['case'],'result':x['result']}for x in examples['examples']],17:{'external_ISA_cases':48,'reset_witnesses':10,'physical_programs':5,'archived_host_document_checks':21}}
 for i,s in enumerate(SLIDES+BACKUPS,1):
  mapping.append({'slide':i,'title':s['title'],'claim':s['goal'],'source_groups':s['refs'],'sources':[{'relative':name,'sha256':inputs[name]}for code in s['refs']for name in source[code]],'expected':'ISA v1.5 and frozen AC1 control/memory contract; exact values in evidence.json','actual':'Decoded archived board samples or source-bound simulation rows, according to source group','supports':'Finite physical5program/S1 scope for BOARD/BUTTON; simulation timing for SIM_*; routed estimates for PPA/CANDIDATE'})
  m=mapping[-1]
  if i in design_actual:m['actual']=design_actual[i]
  if i in [7,8]:
   case='DOC_LOAD_STR'if i==7 else'DOC_CMP_JZ';ex=next(x for x in examples['examples']if x['case']==case)
   m.update(case=case,initial_RF=ex['initial_rf'],instructions=ex['instructions'],expected={'cycles':8,'stores':1,'stalls':1,'redirects':0}if i==7 else{'cycles':9,'stores':0,'stalls':0,'redirects':1},actual={k:int(ex['result'][k])for k in ['cycles','stores','stalls','redirects']},actual_timing_rows=ex['rows'])
  elif i in [10,18]:m.update(expected='Two normal-stop snapshots perprogram; pressed S1 clears publicCPUstate andcounters, release restartschecksum',actual={'programs':programs,'S1_frames':hardware['button_samples']})
  elif i==11:m.update(expected='For these normal-HALT cases C=N+4+S+2R and CPI=C/N',actual=[{k:r[k]for k in ['program','N','S','R','C','CPI']}for r in programs])
  elif i==19:m.update(expected='Same selected program/device/clock/recipe per routed result; positive setup/hold',actual=[{'program':r['program'],'resources':r['implementation']['resources'],'timing':r['implementation']['timing']}for r in routed['rows']])
  elif i==20:m.update(expected='WBtoMEM candidate comparison is offline only;defaultAC1 physical scope retained',actual=[r for r in data['candidate']if r['program']in ['memory_copy','copy_checksum']])
 write(B/'source_map.json',mapping)
 print(json.dumps({'slides':20,'seconds':content['main_seconds'],'spoken_words':content['spoken_words'],'sources_hashed':len(inputs),'new_hardware_or_simulation':False},ensure_ascii=False))
if __name__=='__main__':main()
