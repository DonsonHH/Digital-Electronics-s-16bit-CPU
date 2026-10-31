"""vtools-r1: content validation API; CLI is HISTORICAL revalidation only.

Fresh execution PASS can only be published by execute_regression.py after its
actual native subprocess sequence. No CLI --fresh flag or receipt-absence gate.
"""
from pathlib import Path
import argparse,csv,hashlib,json,re,sys,uuid,shutil,tempfile
from datetime import datetime,timezone
VERIFICATION_REVISION='1.6-vtools-r1'
DRIVER_NAMES=('run_all.cmd','run_all.tcl','sim.tcl','trace.tcl','desktop_launch.py','verify_results.py','run_verify.ps1','execute_regression.py')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def require(condition,detail):
 if not condition:raise ValueError(detail)
def validate_evidence(run,package):
 run=Path(run).resolve();package=Path(package).resolve()
 expected={
  'contract':'ISA_CONTRACT_PASS words=65536 mismatches=0',
  'datapath':'DATAPATH_PASS cases=128 reset_probes=16 retired=3380 failures=0 legal_opcode_coverage=14/14',
  'units':'UNITS_PASS CLA4=512 CLA16=564300 ADD_SUB=564300 ALU=2257200 DECODE=65536 IMM=512 FLAGS=512 RF=262161 PC=65539 TARGET=3584',
  'stress':'STRESS_PASS cases=4696 memory_offset_boundary=3584 loops=100 random_control_flow=500 branch_offset_edges=512 completed=33134 fault_tokens=1408 taken=3636 not_taken=2155 legal_opcodes=14/14 failures=0 seed=A9D41009',
  'audit':'AUDIT3_PASS directed=12 reset_restart=4 total=16 failures=0',
  'uniform':'UNIFORM_SMOKE_PASS retired=5 stores=1 store_wb=1 branch_wb=1',
  'forward':'FORWARD_CONTRACT_PASS controls=131072 failures=0 scope=control_index_not_full_data',
  'trace':'INTERLOCK_TRACE_PASS cycles=12 retired=5 stalls=1 redirects=1 store_wb=1',
  'hazards':'HAZARDS_PASS raw=2376 false=68 flags=84 cross=22 total=2550 reset=16 failures=0',
 }
 tool_versions=set()
 for suite,line in expected.items():
  raw=(run/f'{suite}.log').read_text(encoding='utf-8',errors='replace')
  require(not re.search(r'(?im)Fatal:|FATAL_ERROR|ERROR:',raw),f'{suite} has an error')
  require(raw.splitlines().count(line)==1,f'{suite} must contain exactly one terminal PASS')
  if suite=='contract':require(raw.splitlines().count('ALU_BOUNDARY_PASS checks=14 scope=directed_not_exhaustive')==1,'Directed ALU completion is missing')
  version=re.search(r'(?m)^#\s+xsim v([\d.]+)\s+\(64-bit\)',raw)
  require(version is not None,f'{suite} tool version missing')
  tool_versions.add(version[1])
 require(len(tool_versions)==1,'Mixed simulator versions in one run')
 contract=json.loads((run/'isa_contract_results.json').read_text())
 unit=json.loads((run/'unit_results.json').read_text())
 stress=json.loads((run/'stress_results.json').read_text())
 for receipt in (contract,unit,stress):require(receipt['status']=='PASS' and receipt['spec_version']=='1.6','Receipt status or ISA version differs')
 require((contract['decode_words_checked'],contract['compatible'],contract['incompatible'],contract['alu_directed_checks'])==(65536,65536,0,14),'Decoder or directed ALU count differs')
 unit_counts={'cla4_exhaustive':512,'cla16_cases':564300,'addsub_cases':564300,'alu_cases':2257200,'decode_exhaustive':65536,'immediate_exhaustive':512,'flags_transitions_exhaustive':512,'rf_transactions':262161,'pc_transitions':65539,'branch_target_cases':3584}
 require(unit['failures']==0 and all(unit[k]==v for k,v in unit_counts.items()),'Unit failure or count differs')
 stress_counts={'cases':4696,'memory_offset_boundary':3584,'loops':100,'random_control_flow':500,'branch_offset_edges':512,'completed':33134,'fault_tokens':1408,'taken':3636,'not_taken':2155,'initial_flag_states':8,'legal_opcode_coverage':14}
 require(stress['failures']==0 and stress['seed']=='A9D41009' and all(stress[k]==v for k,v in stress_counts.items()),'Stress failure, seed or count differs')
 with (run/'case_results.csv').open(newline='') as handle:cases=list(csv.DictReader(handle))
 require(len(cases)==128 and len({r['case'] for r in cases})==128,'Missing or duplicate program cases')
 require(sum(int(r['retired']) for r in cases)==3380,'Retired total differs')
 require(all(r['witness_seen']==r['witness_required'] for r in cases),'Required timing witness is missing')
 require(all(int(r['halted'])+int(r['fault'])==1 for r in cases),'Program has an invalid stop result')
 # CSV and native case lines must describe the same execution, not just totals.
 native_cases=re.findall(r'(?m)^CASE_PASS (\S+) cycles=(\d+) retired=(\d+) stalls=(\d+) redirects=(\d+) RF=([\da-fA-F/]+) ZCV=([01]{3}) halt=([01]) fault=([01])$',(run/'datapath.log').read_text(encoding='utf-8',errors='replace'))
 require(len(native_cases)==128 and len({r[0] for r in native_cases})==128,'Native case completion records differ')
 native_by_name={r[0]:r for r in native_cases}
 for r in cases:
  require(r['case'] in native_by_name,'CSV case is absent from native log')
  n=native_by_name[r['case']]
  require([int(r[k]) for k in ('cycles','retired','stalls','redirects','halted','fault')]==[int(n[i]) for i in (1,2,3,4,7,8)],'CSV case differs from native execution')
 baseline=[r for r in cases if r['case']=='BASELINE']
 require(len(baseline)==1,'Baseline missing or duplicated')
 require([int(baseline[0][k]) for k in ('cycles','retired','stalls','redirects','halted','fault')]==[17,10,1,1,1,0],'Baseline execution differs')
 with (run/'baseline_trace.csv').open(newline='') as handle:trace=list(csv.DictReader(handle))
 require([int(r['cycle']) for r in trace]==list(range(1,18)),'Baseline trace cycle range differs')
 require(sum(int(r['stall']) for r in trace)==1 and sum(int(r['redirect']) for r in trace)==1,'Baseline trace events differ')
 rtl_hashes={};tb_hashes={}
 for group,collection in [('rtl',rtl_hashes),('tb',tb_hashes)]:
  for p in sorted((package/'Vivado'/group).iterdir()):
   if p.is_file():
    require(p.read_bytes()==(run/group/p.name).read_bytes(),f'Source snapshot drift: {p.name}')
    collection[p.name]=sha(p)
 require(len(rtl_hashes)==13 and len(tb_hashes) in (10,11),'Unexpected source inventory')
 driver_hashes={}
 for name in DRIVER_NAMES:
  if not (package/'Vivado'/name).exists(): continue
  p=package/'Vivado'/name
  require(p.read_bytes()==(run/name).read_bytes(),f'Driver snapshot drift: {name}')
  driver_hashes[name]=sha(p)
 program_hashes={}
 for p in sorted((package/'程序镜像').iterdir()):
  if p.is_file():
   require(p.read_bytes()==(run/'programs'/p.name).read_bytes(),f'Program snapshot drift: {p.name}')
   program_hashes[p.name]=sha(p)
 memory={};address=0
 for token in (run/'programs'/'baseline_im.mem').read_text().split():
  if token.startswith('@'):address=int(token[1:],16)
  else:
   require(0<=address<256 and address not in memory,'Invalid/duplicate image address')
   require(0<=int(token,16)<=0xffff,'Program image word exceeds 16 bits')
   memory[address]=int(token,16);address+=1
 expected_baseline=[0x1005,0x1403,0x4100,0x7401,0x1c20,0x9300,0x8b00,0xa200,0xd001,0x14ff,0xe000]
 require(len(memory)==256 and [memory[i] for i in range(11)]==expected_baseline,'Baseline program image differs')
 require(all(memory[i]==0xb000 for i in range(11,256)),'Unused IM words must be B000')
 tb_text=(run/'tb'/'tb_datapath.sv').read_text()
 baseline_block=tb_text.split('clear_case("BASELINE");',1)[1].split('run_program(17,1);',1)[0]
 tb_words=[int(v,16) for v in re.findall(r"load\(\d+,\s*'h([0-9a-f]{4})\)",baseline_block,re.I)]
 require(tb_words==expected_baseline,'Baseline program file differs from tested TB fixture')
 evidence_names=['contract.log','isa_contract_results.json','datapath.log','case_results.csv','case_timings.csv','baseline_trace.csv','datapath.vcd','datapath.wdb','units.log','unit_results.json','stress.log','stress_results.json','audit.log','uniform.log','forward.log','trace.log','hazards.log','interlock.vcd','hazard_case_results.csv','hazard_case_timings.csv','trace_case_results.csv','trace_case_timings.csv']
 for name in evidence_names:
  require((run/name).is_file() and (run/name).stat().st_size>0,f'Missing or empty evidence: {name}')
 def check_timings(name,case_rows):
  with (run/name).open(newline='',encoding='utf-8-sig') as h:rows=list(csv.DictReader(h))
  require([r.get('case') for r in rows]==[r['case'] for r in case_rows],f'{name} case ordering/count differs')
  starts=[int(r['start_ps']) for r in rows]
  require(starts and starts[0]>=0 and all(a<b for a,b in zip(starts,starts[1:])),f'{name} start times are not strictly increasing')
 check_timings('case_timings.csv',cases)
 report={
  'status':'PASS','spec_version':'1.6','isa_version':'1.5','completed_at_utc':datetime.now(timezone.utc).isoformat(),
  'tool':'Vivado XSim '+next(iter(tool_versions)),'part':'xc7z020clg484-1','runtime':str(run),
  'archived_run_relative':'验证记录/'+run.name,
  'scope':'uniform five-stage completion and bounded hazard regression; not exhaustive CPU state, timing closure or board validation',
  'decoder_contract':contract,'units':unit,'datapath':{'cases':128,'reset_probes':16,'retired':3380,'legal_opcodes':14,'failures':0},
  'baseline':baseline[0],'stress':stress,'independent_directed_audit':{'directed':12,'reset_restart':4,'total':16,'failures':0},
  'rtl_sha256':rtl_hashes,'tb_sha256':tb_hashes,'driver_sha256':driver_hashes,
  'program_images_sha256':program_hashes,'program_check':'baseline image statically matched to executed TB fixture; not read directly by XSim',
  'hazards':{'raw':2376,'false_dependencies':68,'flag_dependencies':84,'cross_events':22,'total':2550,'reset_probes':16,'failures':0},
  'forward_control_index_space':{'cases':131072,'data_sentinels':4,'full_data_space':False},
  'evidence_sha256':{name:sha(run/name) for name in evidence_names},
  'cpu_input_exhaustive':False,'timing_closed':False,'board_validated':False,
 }
 with (run/'hazard_case_results.csv').open(newline='') as h:hazards=list(csv.DictReader(h))
 check_timings('hazard_case_timings.csv',hazards)
 require(len(hazards)==2550 and len({r['case'] for r in hazards})==2550,'Hazard matrix cases missing or duplicated')
 source_roles={0:[1],2:[0,1,2],3:[0,1,2],4:[0,1,2],5:[0],6:[0,1,2],7:[0],8:[1],9:[0,1,2],10:[0,1,2]}
 expected_raw={f'RAW_P{p:x}_C{c:x}_R{r}_S{s}_G{g}' for p in range(9) for c,roles in source_roles.items() for s in roles for r in range(4) for g in range(3)}
 require({r['case'] for r in hazards if r['case'].startswith('RAW_')}==expected_raw,'Missing producer/consumer/source/register/distance combinations')
 native_hazards=re.findall(r'(?m)^CASE_PASS (\S+) cycles=(\d+) retired=(\d+) stalls=(\d+) redirects=(\d+) RF=([\da-fA-F/]+) ZCV=([01]{3}) halt=([01]) fault=([01])$',(run/'hazards.log').read_text(encoding='utf-8',errors='replace'))
 require(len(native_hazards)==2550 and len({r[0] for r in native_hazards})==2550,'Native hazard completions missing or duplicated')
 native_hazard_by_name={r[0]:r for r in native_hazards}
 require(all(r['witness_seen']==r['witness_required'] for r in hazards),'Hazard stop witness absent')
 for prefix,count in [('RAW_',2376),('FALSE_',68),('FLAG_',84)]:
  require(sum(r['case'].startswith(prefix) for r in hazards)==count,'Hazard category count differs')
 for r in hazards:
  require(r['case'] in native_hazard_by_name,'Hazard CSV case absent from native log')
  n=native_hazard_by_name[r['case']]
  require([int(r[k]) for k in ('cycles','retired','stalls','redirects','halted','fault')]==[int(n[i]) for i in (1,2,3,4,7,8)],'Hazard CSV differs from native execution')
  if r['case'].startswith('RAW_'):
   m=re.fullmatch(r'RAW_P([0-8])_C([0-9aA])_R([0-3])_S([0-2])_G([0-2])',r['case'])
   require(m is not None,'Hazard case label invalid')
   require(int(r['stalls'])==(1 if m[1]=='8' and m[5]=='0' else 0),'Load-use count differs from producer/distance contract')
  require(int(r['halted'])+int(r['fault'])==1,'Hazard stop result invalid')
 require((run/'interlock.vcd').is_file() and (run/'interlock.vcd').stat().st_size>0,'Interlock VCD missing')
 with (run/'trace_case_results.csv').open(newline='') as h:trace_case=list(csv.DictReader(h))
 check_timings('trace_case_timings.csv',trace_case)
 require(len(trace_case)==1 and trace_case[0]['case']=='TRACE_LOAD_STR','Trace case receipt differs')
 require([int(trace_case[0][k]) for k in ('cycles','retired','stalls','redirects','halted','fault')]==[12,5,1,1,1,0],'Trace functional metrics differ')
 report['verification_revision']=VERIFICATION_REVISION
 return report

def historical_main():
 parser=argparse.ArgumentParser(description='Historical evidence integrity revalidation; never a new XSim execution PASS')
 parser.add_argument('--run',type=Path,required=True)
 parser.add_argument('--package',type=Path,help='Optional CURRENT package compatibility check; omitted for historical snapshots')
 parser.add_argument('--receipt',type=Path,help='Original receipt; defaults to run/verification_results.json')
 parser.add_argument('--output',type=Path,help='New historical validation report; must not already exist')
 args=parser.parse_args();run=args.run.resolve()
 output=args.output or run/('historical_validation_'+uuid.uuid4().hex+'.json')
 require(not output.exists(),'Do not overwrite any historical receipt')
 result={'status':'FAIL','result_kind':'historical_revalidation','new_xsim_execution':False,'new_execution_pass':False,
         'verification_revision':VERIFICATION_REVISION,'revalidated_at_utc':datetime.now(timezone.utc).isoformat(),'run':str(run)}
 code=1
 try:
  receipt_path=args.receipt or run/'verification_results.json'
  if not receipt_path.exists():
   result.update(status='PENDING_VERIFICATION',reason='Original receipt and evidence hashes missing; copied logs do not prove execution')
   code=2
  else:
   previous=json.loads(receipt_path.read_text(encoding='utf-8-sig'))
   require(previous.get('status')=='PASS','Original receipt did not record a successful execution')
   for name,digest in previous['evidence_sha256'].items():require(sha(run/name)==digest,'Historical evidence missing or changed: '+name)
   for group,key in [('rtl','rtl_sha256'),('tb','tb_sha256'),('', 'driver_sha256'),('programs','program_images_sha256')]:
    for name,digest in previous[key].items():require(sha(run/group/name)==digest,'Historical input missing or changed: '+name)
   with tempfile.TemporaryDirectory(prefix='cpu_hist_check_') as tmp:
    reference=Path(tmp);(reference/'Vivado').mkdir()
    for group in ('rtl','tb'):shutil.copytree(run/group,reference/'Vivado'/group)
    shutil.copytree(run/'programs',reference/'程序镜像')
    for name in DRIVER_NAMES:
     if (run/name).exists():shutil.copy2(run/name,reference/'Vivado'/name)
    contents=validate_evidence(run,args.package if args.package else reference)
   result.update(status='HISTORICAL_REVALIDATION_PASS',original_attempt_id=previous.get('attempt_id'),
     original_completed_at_utc=previous.get('completed_at_utc'),original_receipt_sha256=sha(receipt_path),
     evidence_integrity_verified=True,current_package_compatible=bool(args.package),
     scope=contents['scope'],note='Only the recorded evidence was revalidated; no xvlog/xelab/xsim was executed here')
   code=0
 except Exception as exc:result['error']=str(exc)
 output.write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding='utf-8')
 print(result['status']+' kind=historical_revalidation new_xsim_execution=false output='+str(output))
 return code
if __name__=='__main__':raise SystemExit(historical_main())
