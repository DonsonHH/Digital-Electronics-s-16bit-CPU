from pathlib import Path
import sys,shutil,tempfile,subprocess,json,hashlib,re,datetime,uuid,argparse,math
base=Path(__file__).resolve().parent;package=base.parent

def positive_timeout(value):
 seconds=float(value)
 if not math.isfinite(seconds) or seconds<=0:raise argparse.ArgumentTypeError('timeout must be finite and positive')
 return seconds
parser=argparse.ArgumentParser(description='Replay independent48; save failed/timeout attempts without publishing a nine-suite PASS')
parser.add_argument('--timeout',type=positive_timeout,default=600,help='native invocation timeout in seconds (default: 600)')
options=parser.parse_args()
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
run=Path(tempfile.mkdtemp(prefix='cpu_ac1_independent_'));source=package/'验证记录'/'independent_48_saved'
shutil.copytree(base/'rtl',run/'rtl');shutil.copy2(base/'desktop_launch.py',run/'desktop_launch.py')
for name in ('programs','cases.json','case_config.svh','case_count.svh','tb_adversarial.sv'):
 p=source/name
 if p.is_dir():shutil.copytree(p,run/name)
 else:shutil.copy2(p,run/name)
bins=r'C:\AMDDesignTools\2025.2\Vivado\bin'
files=' '.join('rtl/'+p.name for p in sorted((run/'rtl').iterdir()))
(run/'run.cmd').write_text(f'@echo off\ncall "{bins}\\xvlog.bat" --sv -i . {files} tb_adversarial.sv\nif errorlevel 1 exit /b 1\ncall "{bins}\\xelab.bat" tb_adversarial -s independent_sim -debug typical\nif errorlevel 1 exit /b 1\ncall "{bins}\\xsim.bat" independent_sim -tclbatch run.tcl -log private.log\nexit /b %errorlevel%\n',encoding='ascii')
(run/'run.tcl').write_text('run all\nquit\n',encoding='ascii')
inputs={p.relative_to(run).as_posix():sha(p) for p in run.rglob('*') if p.is_file()};start=datetime.datetime.now(datetime.timezone.utc).isoformat()
pid=None;rc=None;error=None;p=None
with (run/'console.log').open('wb') as f:
 try:
  p=subprocess.Popen([sys.executable,str(run/'desktop_launch.py'),r'C:\Windows\System32\cmd.exe','/d','/c','run.cmd'],cwd=run,stdout=f,stderr=subprocess.STDOUT);pid=p.pid;rc=p.wait(timeout=options.timeout)
 except subprocess.TimeoutExpired:rc='timeout';error='Native timeout; invocation-owned process tree terminated'
 except KeyboardInterrupt:rc='interrupted';error='Interrupted; invocation-owned process tree terminated'
 except OSError as exc:rc='launch_failed';error=str(exc)
 finally:
  if p is not None and p.poll() is None:p.kill();p.wait()
log=(run/'private.log').read_text(encoding='utf-8',errors='replace') if (run/'private.log').exists() else ''
console=(run/'console.log').read_text(encoding='utf-8',errors='replace')
passed=rc==0 and not re.search(r'(?im)^Fatal:|^ERROR:|FATAL_ERROR',log+'\n'+console) and log.splitlines().count('ADVERSARIAL_PASS cases=48 reset_witnesses=10 failures=0 oracle=external_python memory=independent_sync')==1 and '$finish called at time' in log
if any(sha(run/name)!=digest for name,digest in inputs.items()):passed=False;error='Executed inputs changed during run'
data={'status':'PASS' if passed else 'FAIL','scope':'independent48 only; not a nine-suite receipt or all-state proof','new_xsim_execution':bool(re.search(r'(?m)^#\s+xsim v',log)),'native_execution_complete':passed,'lifecycle_revision':'job1','attempt_id':run.name,'launcher_pid':pid,'native_exit':rc,'timeout_seconds':options.timeout,'error':error,'runner_sha256':sha(Path(__file__)),'started_at_utc':start,'ended_at_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'input_sha256':inputs,'console_sha256':sha(run/'console.log'),'log_sha256':sha(run/'private.log') if (run/'private.log').exists() else None}
(run/'independent_result.json').write_text(json.dumps(data,indent=2),encoding='utf-8')
dest=package/'验证记录'/run.name;shutil.copytree(run,dest,ignore=shutil.ignore_patterns('.Xil','xsim.dir','__pycache__'))
if not passed:raise SystemExit('Independent execution failed; raw failed attempt saved: '+str(dest))
print('INDEPENDENT48_PASS archive='+str(dest))
