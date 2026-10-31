"""Fresh, source-bound EES-331 simulation/implementation attempts. No automatic programming."""
from pathlib import Path
import argparse,datetime,hashlib,json,os,re,shutil,subprocess,sys,tempfile
B=Path(__file__).resolve().parent;P=B.parent;V=P/'Vivado';S=P/'系统'
sys.path.insert(0,str(V));sys.path.insert(0,str(S))
from tool_config import add_tool_arguments,resolve_tools
from run_system import validate_images
from verify_board_results import analyze_reports,require_tool_version,review_console_warnings
from benchmark_programs import PROGRAMS,prepare_selected
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def utc():return datetime.datetime.now(datetime.timezone.utc).isoformat()
def main():
 parser=argparse.ArgumentParser(description=__doc__);add_tool_arguments(parser)
 parser.add_argument('--mode',choices=['simulate','implement','all'],default='all')
 parser.add_argument('--program',choices=list(PROGRAMS),default='all_ops')
 a=parser.parse_args();tools=resolve_tools(a.vivado_bin,python=sys.executable,config=a.config)
 work=Path(tempfile.mkdtemp(prefix='cpu345_board_'));dest=P/'验证'/work.name
 result={'status':'RUNNING','stage':3,'mode':a.mode,'attempt':work.name,'started_at_utc':utc(),'scope':'EES-331 board design and simulation, physical validation separate','part':'xc7z020clg484-1','clock_period_ns':10,'tools':tools,'program':a.program,'steps':[],'board_validated':False}
 def native(tool,label,args,timeout=1200):
  cmd=work/(label+'.cmd');cmd.write_text('@echo off\ncall "'+str(Path(tools['vivado_bin'])/(tool+'.bat'))+'" '+args+'\nexit /b %errorlevel%\n',encoding='ascii')
  step={'label':label,'tool':tool,'command_sha256':sha(cmd),'started_at_utc':utc()};result['steps'].append(step)
  print('BOARD_NATIVE_START '+label,flush=True);proc=None;log=work/(label+'.console.log')
  with log.open('wb') as output:
   try:
    proc=subprocess.Popen([sys.executable,str(work/'desktop_launch.py'),r'C:\Windows\System32\cmd.exe','/d','/c',str(cmd)],cwd=work,env={**os.environ,'CPU_BOARD_ATTEMPT':work.name,'CPU_BOARD_BUILD_ID':result['build_id'],'PYTHONDONTWRITEBYTECODE':'1'},stdout=output,stderr=subprocess.STDOUT)
    step['launcher_pid']=proc.pid;step['exit']=proc.wait(timeout=timeout)
   except subprocess.TimeoutExpired:step['exit']='timeout'
   finally:
    if proc is not None and proc.poll() is None:proc.kill();proc.wait()
    step.update(ended_at_utc=utc(),console_sha256=sha(log))
  text=log.read_text(encoding='utf-8',errors='replace')
  if step.get('exit')!=0 or re.search(r'(?im)^ERROR:|^Fatal:|FATAL_ERROR|^CRITICAL WARNING:',text):raise RuntimeError('Board native failure: '+label)
  step['ordinary_warnings']=review_console_warnings(text)
  if tool=='xelab':
   version=re.search(r'^Vivado Simulator v([\d.]+)',text,re.M)
   if not version:raise ValueError('Native simulator version header missing')
   require_tool_version(version[1]);result['executed_simulator_version']=version[1]
  print('BOARD_NATIVE_EXIT_OK '+label,flush=True)
 try:
  validate_images(S)
  for name in ['rtl','tb','constraints']:
   if (B/name).exists():shutil.copytree(B/name,work/name)
   else:(work/name).mkdir()
  for source in list((V/'rtl').iterdir())+list((S/'rtl').iterdir()):
   if source.is_file():shutil.copy2(source,work/'rtl'/source.name)
  shutil.copytree(S/'programs',work/'programs')
  expected,gold=prepare_selected(work,S,a.program)
  c,n,stalls,redirects=PROGRAMS[a.program]
  result['selected_expectation']=expected;result['verification_revision']='board_benchmarks_v3'
  (work/'oracle_source').mkdir();shutil.copy2(V/'verification/isa_reference.py',work/'oracle_source/isa_reference.py')
  shutil.copy2(B/'benchmark_programs.py',work/'benchmark_programs.py')
  shutil.copy2(V/'desktop_launch.py',work/'desktop_launch.py');shutil.copy2(Path(__file__),work/'run_board.py')
  shutil.copy2(B/'verify_board_results.py',work/'verify_board_results.py')
  for name in ['build_board.tcl','probe_hardware.tcl']:shutil.copy2(B/name,work/name)
  result['input_sha256']={p.relative_to(work).as_posix():sha(p) for p in work.rglob('*') if p.is_file()}
  hardware={n:h for n,h in result['input_sha256'].items() if n.startswith(('rtl/','constraints/')) or n in ['programs/dut_im.mem','programs/dut_dm.mem','build_board.tcl']}
  result['hardware_input_sha256']=hardware
  result['build_id']=hashlib.sha256(json.dumps({'inputs':hardware,'part':result['part'],'period_ns':10,'program':a.program,'tool':'2025.2'},sort_keys=True).encode()).hexdigest()[:16]
  if a.mode in ['simulate','all']:
   sources=' '.join('rtl/'+p.name for p in sorted((work/'rtl').iterdir()) if p.suffix in ['.v','.sv'])
   benches=' '.join('tb/'+p.name for p in sorted((work/'tb').glob('*.sv')))
   native('xvlog','compile','--sv -i tb '+sources+' '+benches)
   native('xelab','elaborate','tb_board_application -s board_sim -debug typical')
   (work/'sim.tcl').write_text('puts "BOARD_ATTEMPT=$env(CPU_BOARD_ATTEMPT)"\nrun all\nquit\n',encoding='ascii')
   native('xsim','simulate','board_sim -tclbatch sim.tcl -log simulation.log -wdb simulation.wdb')
   log=(work/'simulation.log').read_text(encoding='utf-8',errors='replace')
   kinds=re.findall(r'^BOARD_CASE_PASS kind=(\d+)$',log,re.M)
   if kinds!=['0','1','2'] and (len(kinds)!=3 or set(kinds)!={'0','1','2'}):raise ValueError('Board reset/observation case coverage missing')
   if len(re.findall(r'^BOARD_APPLICATION_PASS cases=3 reset_paths=2 bounce=1$',log,re.M))!=1 or 'BOARD_ATTEMPT='+work.name not in log or '$finish called at time' not in log:raise ValueError('Board simulation terminal/attempt missing')
   result['simulation']='PASS'
   native('xelab','elaborate_selected','tb_selected_program -s selected_sim -debug typical')
   native('xsim','simulate_selected','selected_sim -tclbatch sim.tcl -log selected.log -wdb selected.wdb')
   log=(work/'selected.log').read_text(encoding='utf-8',errors='replace')
   terminal=f'BOARD_SELECTED_PASS program={a.program} cycles={c} completed={n} stalls={stalls} redirects={redirects} stores={len(gold["stores"])}'
   if log.splitlines().count(terminal)!=1 or '$finish called at time' not in log or 'BOARD_ATTEMPT='+work.name not in log:raise ValueError('Selected actual boot-image simulation missing')
   result['selected_simulation']='PASS';result['selected_result']={'rf':gold['rf'],'flags':gold['flags'],'stop_pc':gold['events'][-1]['pc'],'cycles':c,'completed':n,'stalls':stalls,'redirects':redirects,'stores':len(gold['stores']),'calculated_cpu_time_ns_at_implemented_clock':c*10,'measured_board_time_ns':None}
  if a.mode in ['implement','all']:
   native('vivado','implement','-mode batch -source build_board.tcl -log implementation.log -nojournal')
   log=(work/'implementation.log').read_text(encoding='utf-8',errors='replace')
   if 'BOARD_IMPLEMENTATION_COMPLETE attempt='+work.name not in log:raise ValueError('Board implementation terminal missing')
   result['implementation']=analyze_reports(work,result['build_id'])
  for name,digest in result['input_sha256'].items():
   if sha(work/name)!=digest:raise ValueError('Executed board input changed: '+name)
  result['output_sha256']={p.relative_to(work).as_posix():sha(p) for folder in ['reports','output'] for p in (work/folder).rglob('*') if p.is_file()}
  result['status']='PASS'
 except BaseException as error:result.update(status='FAIL',error=str(error));raise
 finally:
  result['ended_at_utc']=utc();(work/'result.json').write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding='utf-8')
  dest.parent.mkdir(exist_ok=True);shutil.copytree(work,dest,ignore=shutil.ignore_patterns('.Xil','xsim.dir','ip_user_files','__pycache__','.cache','webtalk'))
  print('BOARD_RECORD='+str(dest),flush=True)
 print('BOARD_ATTEMPT_PASS scope=selected_native_checks_not_physical_board',flush=True)
if __name__=='__main__':main()
