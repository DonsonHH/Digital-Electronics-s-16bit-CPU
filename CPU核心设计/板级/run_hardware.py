"""Explicit EES-331-only capture/run. Never invoked automatically while the board is disconnected."""
from pathlib import Path
import argparse,datetime,hashlib,json,os,re,shutil,subprocess,sys,tempfile
B=Path(__file__).resolve().parent;P=B.parent;sys.path.insert(0,str(P/'Vivado'))
from tool_config import add_tool_arguments,resolve_tools
from verify_board_results import verify_attempt,require
from probe_codec import decode
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def main():
 p=argparse.ArgumentParser(description=__doc__);add_tool_arguments(p)
 p.add_argument('--implementation',type=Path,required=True);p.add_argument('--target',required=True)
 p.add_argument('--confirmed-board',choices=['EES-331'],required=True)
 p.add_argument('--program-device',action='store_true');p.add_argument('--run-program',action='store_true')
 a=p.parse_args();implementation=verify_attempt(a.implementation);data=json.loads((a.implementation/'result.json').read_text(encoding='utf-8'))
 require(data.get('selected_simulation')=='PASS','Selected image must have simulated successfully')
 tools=resolve_tools(a.vivado_bin,python=sys.executable,config=a.config)
 work=Path(tempfile.mkdtemp(prefix='cpu345_hardware_'));dest=P/'验证'/work.name
 r={'status':'RUNNING','physical_board_confirmation':a.confirmed_board,'target':a.target,'source_implementation':str(a.implementation.resolve()),'source_receipt_sha256':sha(a.implementation/'result.json'),'programming_requested':a.program_device,'controlled_run_requested':a.run_program,'programmed':None if a.program_device else False,'board_validated':False,'started_at_utc':datetime.datetime.now(datetime.timezone.utc).isoformat()}
 process=None
 try:
  shutil.copy2(B/'hardware_session.tcl',work/'hardware_session.tcl');shutil.copy2(P/'Vivado/desktop_launch.py',work/'desktop_launch.py')
  for src,name in [('ees331.bit','program.bit'),('debug.ltx','probes.ltx')]:shutil.copy2(a.implementation/'output'/src,work/name)
  ltx=json.loads((work/'probes.ltx').read_text());vio=next(c for d in ltx['ltx_root']['ltx_data'] for c in d['debug_cores'] if c['type']=='VIO_V2')
  nets={pin['name']:pin['nets'][0]['name'] for pin in vio['pins']}
  env={**os.environ,'CPU_CONFIRMED_BOARD':a.confirmed_board,'CPU_HW_TARGET':a.target,'CPU_HW_BIT':str(work/'program.bit'),'CPU_HW_LTX':str(work/'probes.ltx'),'CPU_HW_PROGRAM':str(int(a.program_device)),'CPU_HW_RUN':str(int(a.run_program)),'CPU_HW_BUILD_ID':implementation['build_id'],'CPU_HW_ATTEMPT':work.name,'CPU_HW_STATE_NET':nets['probe_in0'],'CPU_HW_PERF_NET':nets['probe_in1'],'CPU_HW_RESET_NET':nets['probe_out0']}
  (work/'run.cmd').write_text('@echo off\ncall "'+str(Path(tools['vivado_bin'])/'vivado.bat')+'" -mode batch -source hardware_session.tcl -log hardware.log -nojournal\nexit /b %errorlevel%\n',encoding='ascii')
  r['input_sha256']={f.name:sha(f) for f in work.iterdir() if f.is_file()}
  with (work/'console.log').open('wb') as output:
   try:
    process=subprocess.Popen([sys.executable,str(work/'desktop_launch.py'),r'C:\Windows\System32\cmd.exe','/d','/c','run.cmd'],cwd=work,env=env,stdout=output,stderr=subprocess.STDOUT);r['native_exit']=process.wait(timeout=120)
   finally:
    if process is not None and process.poll() is None:process.kill();process.wait()
  text=(work/'hardware.log').read_text(encoding='utf-8',errors='replace')
  require(r['native_exit']==0 and not re.search(r'(?im)^ERROR:|^CRITICAL WARNING:|^HARDWARE_SESSION_FAILED=',text) and text.splitlines().count('HARDWARE_CAPTURE_COMPLETE attempt='+work.name)==1,'Hardware capture did not finish')
  captures=[decode(s,t) for _,s,t in (line.split('\t') for line in (work/'snapshots.tsv').read_text().splitlines())];require(len(captures)==2,'Two hardware snapshots required')
  require(all(c['build_id']==implementation['build_id'] for c in captures),'Hardware build identity mismatch');r['snapshots']=captures;r['programmed']=a.program_device
  if a.run_program:
   expected=data['selected_result']
   store_packets=(a.implementation/'programs/selected_stores.mem').read_text().splitlines()
   last_store=int(store_packets[-1],16) if expected['stores'] else None
   for c in captures:
    require(c['core_reset']==0 and c['stop_valid']==1 and c['stop_pc_valid']==1 and c['halted']==1 and c['fault']==0 and c['stop_reason']==1,'Hardware did not halt normally')
    for key in ['rf','flags','stop_pc','cycles','completed','stalls','redirects','stores']:require(c[key]==expected[key],'Hardware differs: '+key)
    require(c['last_completed_valid']==1 and c['last_completed_pc']==expected['stop_pc'] and c['reserved']==0,'Hardware completion/layout differs')
    require(c['last_store_valid']==int(expected['stores']>0),'Hardware store-valid differs')
    if last_store is not None:require(c['last_store_addr']==((last_store>>47)&0xffff) and c['last_store_data']==((last_store>>22)&0xffff),'Hardware last-store differs')
   require(not re.search(r'(?im)^WARNING:',text),'Hardware warnings require review before acceptance')
   r.update(status='FUNCTIONAL_BOARD_PASS',board_validated=True,measured_board_time_ns=None,clock_basis='EES331100MHz oscillator via BUFG; frequency not independently measured')
  else:r['status']='PROGRAMMED_AND_OBSERVED_NOT_FUNCTIONAL_ACCEPTANCE' if a.program_device else 'READ_ONLY_OBSERVATION_NOT_FUNCTIONAL_ACCEPTANCE'
  for name,h in r['input_sha256'].items():require(sha(work/name)==h,'Hardware input changed')
 except BaseException as error:r.update(status='FAIL',error=str(error));raise
 finally:
  log=work/'hardware.log'
  if log.exists():
   lines=log.read_text(encoding='utf-8',errors='replace').splitlines()
   if 'HARDWARE_DEVICE_PROGRAMMED' in lines:r['programmed']=True
   r['reset_asserted']='HARDWARE_RESET_ASSERTED' in lines;r['reset_released']='HARDWARE_RESET_RELEASED' in lines
  r['ended_at_utc']=datetime.datetime.now(datetime.timezone.utc).isoformat();(work/'result.json').write_text(json.dumps(r,ensure_ascii=False,indent=2),encoding='utf-8');shutil.copytree(work,dest);print('HARDWARE_RECORD='+str(dest),flush=True)
if __name__=='__main__':main()
