"""vtools-r1 authoritative fresh execution/publishing boundary.

Refuses any pre-existing output. Captures 19 actual native subprocesses and
their output hashes. Historical CLI verification cannot enter this publisher.
These are recoverable workflow receipts, not a defense against arbitrary code
or filesystem forgery by a malicious actor on this computer.
"""
from pathlib import Path
import argparse,hashlib,json,subprocess,sys,uuid,os,re,time
from datetime import datetime,timezone
from verify_results import validate_evidence,DRIVER_NAMES,VERIFICATION_REVISION

SUITES=[('tb_isa_contract','contract','contract_v16_sim','run_all.tcl'),
 ('tb_datapath','datapath','datapath_v16_sim','sim.tcl'),('tb_units','units','units_v16_sim','run_all.tcl'),
 ('tb_stress','stress','stress_v16_sim','run_all.tcl'),('tb_audit3','audit','audit_v16_sim','run_all.tcl'),
 ('tb_uniform_smoke','uniform','uniform_v16_sim','run_all.tcl'),('tb_forward_contract','forward','forward_v16_sim','run_all.tcl'),
 ('tb_trace','trace','trace_v16_sim','trace.tcl'),('tb_hazards','hazards','hazards_v16_sim','run_all.tcl')]
def utc():return datetime.now(timezone.utc).isoformat()
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def require(c,m):
 if not c:raise ValueError(m)
def inputs(run):
 files=[p for g in ('rtl','tb','programs') for p in (run/g).iterdir() if p.is_file()]
 files += [run/n for n in DRIVER_NAMES]
 return {p.relative_to(run).as_posix():sha(p) for p in sorted(files)}
def check_package(run,package):
 for g in ('rtl','tb'):
  require({p.name for p in (run/g).iterdir() if p.is_file()}=={p.name for p in (package/g).iterdir() if p.is_file()},'Input inventory differs: '+g)
  for p in (run/g).iterdir():require(p.read_bytes()==(package/g/p.name).read_bytes(),'Input/package drift: '+g+'/'+p.name)
 for n in DRIVER_NAMES:require((run/n).read_bytes()==(package/n).read_bytes(),'Driver/package drift: '+n)
 for p in (package/'程序镜像').iterdir():require(p.read_bytes()==(run/'programs'/p.name).read_bytes(),'Program/package drift')
def main():
 p=argparse.ArgumentParser();p.add_argument('--run',type=Path,required=True);p.add_argument('--package',type=Path,required=True)
 p.add_argument('--vivado-bin',type=Path,default=Path(r'C:\AMDDesignTools\2025.2\Vivado\bin'));p.add_argument('--attempt-id',required=True)
 a=p.parse_args();run=a.run.resolve();package=a.package.resolve();attempt=str(uuid.UUID(a.attempt_id))
 ledger=dict(attempt_id=attempt,status='RUNNING',result_kind='actual_native_execution',started_at_utc=utc(),verification_revision=VERIFICATION_REVISION,steps=[])
 ledger_path=run/'execution_ledger.json';manifest_path=run/'attempt_manifest.json'
 try:
  require(not ledger_path.exists() and not manifest_path.exists() and not (run/'verification_results.json').exists(),'Fresh runtime required; output already exists')
  require(not any(run.glob('*.log')) and not any(run.glob('*.csv')) and not (run/'xsim.dir').exists(),'Previously executed/copied runtime is not fresh')
  check_package(run,package)
  frozen=inputs(run);manifest=dict(attempt_id=attempt,started_at_utc=ledger['started_at_utc'],runtime=str(run),package=str(package),input_sha256=frozen,verification_revision=VERIFICATION_REVISION)
  manifest_path.write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding='utf-8');manifest_sha=sha(manifest_path)
  ledger['manifest_sha256']=manifest_sha
  env=dict(os.environ,CPU_VERIFY_ATTEMPT_ID=attempt,CPU_VERIFY_INPUT_SHA256=manifest_sha)
  cmd_dir=run/'tool_commands';cmd_dir.mkdir()
  def native(kind,label,arguments):
   idx=len(ledger['steps']);cmd=cmd_dir/f'{idx:02d}_{label}.cmd';console=run/f'tool_{idx:02d}_{label}.console.log'
   command='call "'+str(a.vivado_bin/(kind+'.bat'))+'" '+arguments
   cmd.write_text('@echo off\n'+command+'\nexit /b %errorlevel%\n',encoding='ascii')
   record=dict(index=idx,tool=kind,label=label,command=command,command_file_sha256=sha(cmd),started_at_utc=utc())
   print('NATIVE_STEP_START '+str(idx)+' '+kind+' '+label,flush=True)
   with console.open('wb') as f:
    process=subprocess.Popen([sys.executable,str(run/'desktop_launch.py'),r'C:\Windows\System32\cmd.exe','/d','/c',str(cmd)],cwd=run,env=env,stdout=f,stderr=subprocess.STDOUT)
    record['launcher_pid']=process.pid
    try:record['exit_code']=process.wait(timeout=180)
    except subprocess.TimeoutExpired:
     process.kill();process.wait();record['exit_code']='timeout'
   record.update(ended_at_utc=utc(),console_file=console.name,console_sha256=sha(console))
   raw=console.read_text(encoding='utf-8',errors='replace');pid=re.search(r'DESKTOP_WRAPPER_PID (\d+)',raw)
   record['desktop_shell_pid']=int(pid[1]) if pid else None
   ledger['steps'].append(record);ledger_path.write_text(json.dumps(ledger,ensure_ascii=False,indent=2),encoding='utf-8')
   require(record['exit_code']==0,kind+' failed: '+label)
   require(not re.search(r'(?im)^Fatal:|^ERROR:|FATAL_ERROR',raw),'Native failure, even if tool exit was zero: '+label)
   if kind=='xsim':
    native_log=run/(label+'.log');text=native_log.read_text(encoding='utf-8',errors='replace')
    require(not re.search(r'(?im)^Fatal:|^ERROR:|FATAL_ERROR',text),'Native simulation Fatal: '+label)
    marker='CPU_VERIFY_ATTEMPT id='+attempt+' input_sha256='+manifest_sha
    require(text.splitlines().count(marker)==1,'Simulation not bound to current execution: '+label)
    directory=re.search(r'^# Current directory\s+: (.+)$',text,re.M)
    require(directory is not None and Path(directory[1].strip()).resolve()==run,'Native runtime directory differs')
    require('$finish called at time' in text,'Simulation did not reach finish: '+label)
    record['native_log_sha256']=sha(native_log)
   print('NATIVE_STEP_END '+str(idx)+' '+label+' exit=0',flush=True)
  rtl_order=['cla4_pg.v','cla16.v','addsub16_cla.v','alu16.v','flags_reg.v','isa_decode.v','regfile4x16.v','pc16.v','imm_ext16.v','branch_target16.v','operand_forward.v','datapath_core.sv','sync_memories.v']
  native('xvlog','compile','--sv -i tb '+' '.join('rtl/'+x for x in rtl_order)+' '+' '.join('tb/'+x[0]+'.sv' for x in SUITES))
  for top,label,snapshot,tcl in SUITES:
   native('xelab','elab_'+label,top+' -s '+snapshot+' -debug typical')
   native('xsim',label,snapshot+' -tclbatch '+tcl+' -log '+label+'.log -wdb '+label+'.wdb')
  require(len(ledger['steps'])==19,'Actual native tool sequence incomplete')
  require(inputs(run)==frozen,'Executed inputs changed during run');check_package(run,package)
  report=validate_evidence(run,package)
  ledger.update(status='COMPLETED',ended_at_utc=utc(),input_sha256_after=inputs(run),native_execution_complete=True)
  ledger_path.write_text(json.dumps(ledger,ensure_ascii=False,indent=2),encoding='utf-8')
  report.update(status='PASS',result_kind='fresh_execution',new_xsim_execution=True,attempt_id=attempt,
   started_at_utc=ledger['started_at_utc'],completed_at_utc=ledger['ended_at_utc'],
   execution_binding={'publisher':'execute_regression.py','native_subprocesses':19,'attempt_manifest_sha256':manifest_sha,'execution_ledger_sha256':sha(ledger_path),'input_sha256':frozen},verification_revision=VERIFICATION_REVISION)
  report['evidence_sha256'].update({p.name:sha(p) for p in run.iterdir() if p.is_file() and (p.name.endswith('.console.log') or p.name in ('execution_ledger.json','attempt_manifest.json'))})
  (run/'verification_results.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8')
  print('CPU_V16_FRESH_EXECUTION_PASS attempt_id='+attempt+' native_subprocesses=19 verification_revision='+VERIFICATION_REVISION)
  return 0
 except Exception as exc:
  ledger.update(status='FAILED',ended_at_utc=utc(),error=str(exc),native_execution_complete=False)
  # Refusal of an existing runtime never overwrites its original ledger.
  failure=ledger_path if not ledger_path.exists() or ledger.get('manifest_sha256') else run/('refused_attempt_'+attempt+'.json')
  failure.write_text(json.dumps(ledger,ensure_ascii=False,indent=2),encoding='utf-8')
  print('CPU_V16_EXECUTION_FAILED '+str(exc));return 1
if __name__=='__main__':raise SystemExit(main())
