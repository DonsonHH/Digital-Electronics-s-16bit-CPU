"""Explicit EES-331-only capture/run. Never invoked automatically while the board is disconnected."""
from pathlib import Path
import argparse,datetime,hashlib,json,os,re,shutil,subprocess,sys,tempfile
B=Path(__file__).resolve().parent;P=B.parent;sys.path.insert(0,str(P/'Vivado'))
from tool_config import add_tool_arguments,resolve_tools
from verify_board_results import verify_attempt,require
from probe_codec import decode
from verification.isa_reference import oracle
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def archive_host_context(work,tools):
 # Snapshot host decision rules before any device access; no environment secrets.
 sources=['板级/run_hardware.py','板级/probe_codec.py','板级/verify_board_results.py','Vivado/tool_config.py','Vivado/verification/isa_reference.py']
 archive=work/'host_sources';archive.mkdir()
 fingerprints={}
 for name in sources:
  target=archive/name;target.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(P/name,target);fingerprints[name]=sha(target)
 git={'available':False,'commit':None,'tracked_sources_dirty':None}
 try:
  options=dict(cwd=P,stdout=subprocess.PIPE,stderr=subprocess.PIPE,text=True,encoding='utf-8',timeout=10,creationflags=getattr(subprocess,'CREATE_NO_WINDOW',0))
  head=subprocess.run(['git','rev-parse','HEAD'],check=True,**options).stdout.strip()
  require(re.fullmatch(r'(?:[0-9a-f]{40}|[0-9a-f]{64})',head),'Invalid Git commit')
  state=subprocess.run(['git','diff','--quiet','HEAD','--',*sources],**options)
  require(state.returncode in [0,1],'Git source-state inspection failed')
  git={'available':True,'commit':head,'tracked_sources_dirty':state.returncode==1}
 except (OSError,subprocess.SubprocessError,ValueError) as error:git['unavailable_reason']=type(error).__name__
 context={'schema':1,'scope':'Host sources at pre-device preflight; native versions are recorded separately after execution','python_version':sys.version,'python_executable':sys.executable,'vivado_bin':tools['vivado_bin'],'expected_vivado_version':'2025.2','git':git,'source_sha256':fingerprints}
 (work/'host_context.json').write_text(json.dumps(context,ensure_ascii=False,indent=2),encoding='utf-8')
 return context

def native_versions_from_log(text):
 versions={}
 for key,prefix in [('vivado','HARDWARE_VIVADO_VERSION='),('tcl','HARDWARE_TCL_VERSION=')]:
  values=[line[len(prefix):].strip() for line in text.splitlines() if line.startswith(prefix)]
  require(len(values)==1 and values[0],'One native runtime version required: '+key);versions[key]=values[0]
 require(versions['vivado']=='2025.2' and re.fullmatch(r'\d+\.\d+(?:\.\d+)?',versions['tcl']),'Unexpected native runtime version')
 return versions

def expected_before_device_access(data,implementation,run_requested):
 if not run_requested:return None,None
 expected=data.get('selected_result')
 keys={'rf','flags','stop_pc','cycles','completed','stalls','redirects','stores'}
 require(isinstance(expected,dict) and keys<=set(expected),'A complete selected_result is required before device access; legacy attempts are read-only')
 require(len(expected['rf'])==4 and all(type(v)is int and 0<=v<65536 for v in expected['rf']),'Invalid expected register profile')
 require(len(expected['flags'])==3 and all(type(v)is int and v in [0,1] for v in expected['flags']),'Invalid expected flags')
 require(all(type(expected[k])is int and 0<=expected[k]<2**32 for k in keys-{'rf','flags'}),'Invalid expected counters/PC')
 root=Path(implementation)
 image=[int(x,16) for x in (root/'programs/dut_im.mem').read_text().splitlines()];memory=[int(x,16) for x in (root/'programs/dut_dm.mem').read_text().splitlines()]
 require(len(image)==256 and len(memory)==256,'Boot image shape differs')
 gold=oracle(image,memory)
 require(gold['halt'] and not gold['fault'],'Hardware run entry requires a reviewed normal-HALT program')
 for k,v in {'rf':gold['rf'],'flags':gold['flags'],'stop_pc':gold['events'][-1]['pc'],'completed':len(gold['events']),'stores':len(gold['stores'])}.items():require(expected[k]==v,'Expected architecture profile differs: '+k)
 require(expected['cycles']>=expected['completed']+4 and expected['stop_pc']<256,'Invalid expected execution profile')
 packets=(root/'programs/selected_stores.mem').read_text().splitlines()
 require(len(packets)==max(1,expected['stores']),'Expected store file count differs')
 last_store=int(packets[-1],16) if expected['stores'] else None
 return expected,last_store
def verify_stopped_captures(captures,expected,last_store):
 require(len(captures)==2,'Two hardware snapshots required')
 for c in captures:
  require(c['core_reset']==0 and c['stop_valid']==1 and c['stop_pc_valid']==1 and c['halted']==1 and c['fault']==0 and c['stop_reason']==1,'Hardware did not halt normally')
  for key in ['rf','flags','stop_pc','cycles','completed','stalls','redirects','stores']:require(c[key]==expected[key],'Hardware differs: '+key)
  require(c['last_completed_valid']==1 and c['last_completed_pc']==expected['stop_pc'] and c['reserved']==0,'Hardware completion/layout differs')
  require(c['last_store_valid']==int(expected['stores']>0),'Hardware store-valid differs')
  if last_store is not None:require(c['last_store_addr']==((last_store>>47)&0xffff) and c['last_store_data']==((last_store>>22)&0xffff),'Hardware last-store differs')

def main():
 p=argparse.ArgumentParser(description=__doc__);add_tool_arguments(p)
 p.add_argument('--implementation',type=Path,required=True);p.add_argument('--target',required=True)
 p.add_argument('--confirmed-board',choices=['EES-331'],required=True)
 p.add_argument('--program-device',action='store_true');p.add_argument('--run-program',action='store_true')
 a=p.parse_args();implementation=verify_attempt(a.implementation);data=json.loads((a.implementation/'result.json').read_text(encoding='utf-8'))
 require(data.get('selected_simulation')=='PASS','Selected image must have simulated successfully')
 expected,last_store=expected_before_device_access(data,a.implementation,a.run_program)
 tools=resolve_tools(a.vivado_bin,python=sys.executable,config=a.config)
 work=Path(tempfile.mkdtemp(prefix='cpu345_hardware_'));dest=P/'验证'/work.name
 r={'status':'RUNNING','physical_board_confirmation':a.confirmed_board,'target':a.target,'source_implementation':str(a.implementation.resolve()),'source_receipt_sha256':sha(a.implementation/'result.json'),'programming_requested':a.program_device,'controlled_run_requested':a.run_program,'programmed':None if a.program_device else False,'reset_asserted':None if a.run_program else False,'reset_released':None if a.run_program else False,'board_validated':False,'started_at_utc':datetime.datetime.now(datetime.timezone.utc).isoformat()}
 process=None
 try:
  r['record_schema']=2;r['host_context']=archive_host_context(work,tools);r['native_versions']=None
  shutil.copy2(B/'hardware_session.tcl',work/'hardware_session.tcl');shutil.copy2(P/'Vivado/desktop_launch.py',work/'desktop_launch.py')
  for src,name in [('ees331.bit','program.bit'),('debug.ltx','probes.ltx')]:shutil.copy2(a.implementation/'output'/src,work/name)
  ltx=json.loads((work/'probes.ltx').read_text());vio=next(c for d in ltx['ltx_root']['ltx_data'] for c in d['debug_cores'] if c['type']=='VIO_V2')
  nets={pin['name']:pin['nets'][0]['name'] for pin in vio['pins']}
  env={**os.environ,'CPU_CONFIRMED_BOARD':a.confirmed_board,'CPU_HW_TARGET':a.target,'CPU_HW_BIT':str(work/'program.bit'),'CPU_HW_LTX':str(work/'probes.ltx'),'CPU_HW_PROGRAM':str(int(a.program_device)),'CPU_HW_RUN':str(int(a.run_program)),'CPU_HW_BUILD_ID':implementation['build_id'],'CPU_HW_ATTEMPT':work.name,'CPU_HW_STATE_NET':nets['probe_in0'],'CPU_HW_PERF_NET':nets['probe_in1'],'CPU_HW_RESET_NET':nets['probe_out0']}
  (work/'run.cmd').write_text('@echo off\ncall "'+str(Path(tools['vivado_bin'])/'vivado.bat')+'" -mode batch -source hardware_session.tcl -log hardware.log -nojournal\nexit /b %errorlevel%\n',encoding='ascii')
  r['input_sha256']={f.relative_to(work).as_posix():sha(f) for f in work.rglob('*') if f.is_file()}
  with (work/'console.log').open('wb') as output:
   try:
    process=subprocess.Popen([sys.executable,str(work/'desktop_launch.py'),r'C:\Windows\System32\cmd.exe','/d','/c','run.cmd'],cwd=work,env=env,stdout=output,stderr=subprocess.STDOUT);r['native_exit']=process.wait(timeout=120)
   finally:
    if process is not None and process.poll() is None:process.kill();process.wait()
  text=(work/'hardware.log').read_text(encoding='utf-8',errors='replace')
  r['native_versions']=native_versions_from_log(text)
  require(r['native_exit']==0 and not re.search(r'(?im)^ERROR:|^CRITICAL WARNING:|^HARDWARE_SESSION_FAILED=',text) and text.splitlines().count('HARDWARE_CAPTURE_COMPLETE attempt='+work.name)==1,'Hardware capture did not finish')
  captures=[decode(s,t) for _,s,t in (line.split('\t') for line in (work/'snapshots.tsv').read_text().splitlines())];require(len(captures)==2,'Two hardware snapshots required')
  require(all(c['build_id']==implementation['build_id'] for c in captures),'Hardware build identity mismatch');r['snapshots']=captures;r['programmed']=a.program_device
  if a.run_program:
   verify_stopped_captures(captures,expected,last_store)
   require(not re.search(r'(?im)^WARNING:',text),'Hardware warnings require review before acceptance')
   r.update(status='FUNCTIONAL_BOARD_PASS',measured_board_time_ns=None,clock_basis='EES331100MHz oscillator via BUFG; frequency not independently measured')
  else:r['status']='PROGRAMMED_AND_OBSERVED_NOT_FUNCTIONAL_ACCEPTANCE' if a.program_device else 'READ_ONLY_OBSERVATION_NOT_FUNCTIONAL_ACCEPTANCE'
  for name,h in r['input_sha256'].items():require(sha(work/name)==h,'Hardware input changed')
  if a.run_program:r['board_validated']=True
 except BaseException as error:r.update(status='FAIL',board_validated=False,error=str(error));raise
 finally:
  log=work/'hardware.log'
  if log.exists():
   lines=log.read_text(encoding='utf-8',errors='replace').splitlines()
   if 'HARDWARE_DEVICE_PROGRAMMED' in lines:r['programmed']=True
   r['reset_asserted']=True if 'HARDWARE_RESET_ASSERTED' in lines else None if a.run_program else False
   r['reset_released']=True if 'HARDWARE_RESET_RELEASED' in lines else None if a.run_program else False
  r['ended_at_utc']=datetime.datetime.now(datetime.timezone.utc).isoformat();(work/'result.json').write_text(json.dumps(r,ensure_ascii=False,indent=2),encoding='utf-8');shutil.copytree(work,dest);print('HARDWARE_RECORD='+str(dest),flush=True)
if __name__=='__main__':main()
