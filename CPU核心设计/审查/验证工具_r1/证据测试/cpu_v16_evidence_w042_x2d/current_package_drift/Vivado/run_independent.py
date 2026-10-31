"""Execute a generated, manifest-bound independent48 package in a fresh native job."""
from pathlib import Path
import argparse,csv,datetime,hashlib,json,math,re,shutil,subprocess,sys,tempfile
from tool_config import add_tool_arguments,resolve_tools
from generate_independent import generate
BASE=Path(__file__).resolve().parent
PACKAGE=BASE.parent
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def positive_timeout(value):
    seconds=float(value)
    if not math.isfinite(seconds) or seconds<=0:raise argparse.ArgumentTypeError('timeout must be finite and positive')
    return seconds
def load_case_package(source):
    manifest=json.loads((source/'manifest.json').read_text(encoding='utf-8'))
    expected=json.loads((BASE/'verification/test_manifest.json').read_text(encoding='utf-8'))['frozen_independent48']
    if manifest['case_count']!=expected['case_count'] or manifest['labels']!=expected['labels']:raise ValueError('Unreviewed independent fixture identity')
    for name,digest in manifest['input_sha256'].items():
        target=(source/name).resolve()
        if not target.is_relative_to(source.resolve()) or sha(target)!=digest:raise ValueError('Case package hash mismatch: '+name)
    return expected
def main():
    parser=argparse.ArgumentParser(description=__doc__);add_tool_arguments(parser)
    parser.add_argument('--cases',type=Path);parser.add_argument('--rtl',type=Path,default=BASE/'rtl')
    parser.add_argument('--timeout',type=positive_timeout,default=600)
    a=parser.parse_args();tools=resolve_tools(a.vivado_bin,config=a.config)
    source=a.cases.resolve() if a.cases else Path(tempfile.mkdtemp(prefix='cpu_cases_parent_'))/'cases'
    if a.cases is None:generate(source)
    expected=load_case_package(source)
    run=Path(tempfile.mkdtemp(prefix='cpu_ac1_independent_'))
    shutil.copytree(a.rtl,run/'rtl');shutil.copy2(BASE/'desktop_launch.py',run/'desktop_launch.py')
    for item in source.iterdir():
        if item.is_dir():shutil.copytree(item,run/item.name)
        else:shutil.copy2(item,run/item.name)
    bins=tools['vivado_bin'];files=' '.join('rtl/'+p.name for p in sorted((run/'rtl').iterdir()) if p.suffix in ('.v','.sv'))
    command=f'@echo off\ncall "{bins}\\xvlog.bat" --sv -i . {files} tb_adversarial.sv\nif errorlevel 1 exit /b 1\ncall "{bins}\\xelab.bat" tb_adversarial -s independent_sim -debug typical\nif errorlevel 1 exit /b 1\ncall "{bins}\\xsim.bat" independent_sim -tclbatch run.tcl -log private.log\nexit /b %errorlevel%\n'
    (run/'run.cmd').write_text(command,encoding='ascii');(run/'run.tcl').write_text('run all\nquit\n',encoding='ascii')
    inputs={p.relative_to(run).as_posix():sha(p) for p in run.rglob('*') if p.is_file()}
    start=datetime.datetime.now(datetime.timezone.utc).isoformat();p=None;pid=None;rc=None;error=None
    with (run/'console.log').open('wb') as f:
        try:
            p=subprocess.Popen([sys.executable,str(run/'desktop_launch.py'),r'C:\Windows\System32\cmd.exe','/d','/c','run.cmd'],cwd=run,stdout=f,stderr=subprocess.STDOUT)
            pid=p.pid;rc=p.wait(timeout=a.timeout)
        except subprocess.TimeoutExpired:rc='timeout';error='Native timeout; invocation-owned process tree terminated'
        except KeyboardInterrupt:rc='interrupted';error='Interrupted; invocation-owned process tree terminated'
        except OSError as exc:rc='launch_failed';error=str(exc)
        finally:
            if p is not None and p.poll() is None:p.kill();p.wait()
    log=(run/'private.log').read_text(encoding='utf-8',errors='replace') if (run/'private.log').exists() else ''
    console=(run/'console.log').read_text(encoding='utf-8',errors='replace')
    marker=f'ADVERSARIAL_PASS cases={expected["case_count"]} reset_witnesses={expected["reset_rerun_witnesses"]} failures=0 oracle=external_python memory=independent_sync'
    passed=rc==0 and not re.search(r'(?im)^Fatal:|^ERROR:|FATAL_ERROR',log+'\n'+console) and log.splitlines().count(marker)==1 and '$finish called at time' in log
    if passed:
        with (run/'independent_results.csv').open(encoding='utf-8-sig',newline='') as f:rows=list(csv.DictReader(f))
        passed=len(rows)==expected['result_rows'] and len({(r['case'],r['epoch']) for r in rows})==len(rows) and {r['case'] for r in rows}==set(expected['labels'])
    if any(sha(run/name)!=digest for name,digest in inputs.items()):passed=False;error='Executed inputs changed during run'
    data={'status':'PASS' if passed else 'FAIL','scope':'independent48 only; not a nine-suite receipt or all-state proof','new_xsim_execution':bool(re.search(r'(?m)^#\s+xsim v',log)),'native_execution_complete':passed,'lifecycle_revision':'job1','attempt_id':run.name,'launcher_pid':pid,'native_exit':rc,'timeout_seconds':a.timeout,'error':error,'runner_sha256':sha(Path(__file__)),'started_at_utc':start,'ended_at_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'input_sha256':inputs,'console_sha256':sha(run/'console.log'),'log_sha256':sha(run/'private.log') if (run/'private.log').exists() else None,'tool_configuration':tools,'fixture_source':'generated_current' if a.cases is None else str(source)}
    (run/'independent_result.json').write_text(json.dumps(data,indent=2),encoding='utf-8')
    dest=PACKAGE/'验证记录'/run.name;shutil.copytree(run,dest,ignore=shutil.ignore_patterns('.Xil','xsim.dir','__pycache__'))
    if not passed:raise SystemExit('Independent execution failed; raw failed attempt saved: '+str(dest))
    print('INDEPENDENT48_PASS archive='+str(dest))
if __name__=='__main__':main()
