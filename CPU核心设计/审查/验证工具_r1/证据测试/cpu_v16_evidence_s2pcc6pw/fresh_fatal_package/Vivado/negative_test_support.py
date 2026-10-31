from pathlib import Path
import sys,subprocess,datetime,json,hashlib,shutil
from tool_config import resolve_tools
ROOT=Path(__file__).resolve().parent
_tools=None
def configure(vivado_bin=None,config=None):
    global _tools
    _tools=resolve_tools(vivado_bin,config=config)
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def execute(work,label='native',timeout=600):
    work=Path(work);before={p.relative_to(work).as_posix():sha(p) for p in work.rglob('*') if p.is_file()}
    log=work/(label+'_console.log');receipt=work/(label+'_execution.json')
    if log.exists() or receipt.exists():raise RuntimeError('Attempt would overwrite evidence')
    started=datetime.datetime.now(datetime.timezone.utc).isoformat()
    p=None;pid=None;rc=None;error=None
    with log.open('wb') as f:
        try:
            p=subprocess.Popen([sys.executable,str(work/'desktop_launch.py'),r'C:\Windows\System32\cmd.exe','/d','/c','run.cmd'],cwd=work,stdout=f,stderr=subprocess.STDOUT)
            pid=p.pid;rc=p.wait(timeout=timeout)
        except subprocess.TimeoutExpired:rc='timeout';error='Invocation-owned process tree terminated'
        except KeyboardInterrupt:rc='interrupted';error='Invocation-owned process tree terminated'
        except OSError as exc:rc='launch_failed';error=str(exc)
        finally:
            if p is not None and p.poll() is None:p.kill();p.wait()
    receipt.write_text(json.dumps(dict(started_at=started,ended_at=datetime.datetime.now(datetime.timezone.utc).isoformat(),launcher_pid=pid,exit_code=rc,error=error,lifecycle_revision='job1',input_sha256=before,console_sha256=sha(log)),indent=2),encoding='utf-8')
    return rc if isinstance(rc,int) else 1
def prepare(work,top,tbfiles,rtl=None):
    work=Path(work);work.mkdir(exist_ok=False)
    base=ROOT
    shutil.copytree(base/'rtl' if rtl is None else rtl,work/'rtl')
    shutil.copytree(base/'tb',work/'tb');shutil.copy2(base/'desktop_launch.py',work/'desktop_launch.py')
    for name,content in tbfiles.items():(work/name).write_text(content,encoding='ascii')
    sources=' '.join('rtl/'+p.name for p in (work/'rtl').iterdir() if p.suffix in ('.v','.sv'))
    sources+=' '+' '.join('tb/'+p.name for p in (work/'tb').glob('*.sv'))
    sources+=' '+' '.join(n for n in tbfiles if n.endswith('.sv'))
    bins=(_tools or resolve_tools())['vivado_bin']
    (work/'run.cmd').write_text(f'''@echo off
call "{bins}\\xvlog.bat" --sv -i tb {sources}
if errorlevel 1 exit /b 1
call "{bins}\\xelab.bat" {top} -s private_sim -debug typical
if errorlevel 1 exit /b 1
call "{bins}\\xsim.bat" private_sim -tclbatch run.tcl -log private.log
if errorlevel 1 exit /b 1
exit /b 0
''',encoding='ascii')
    (work/'run.tcl').write_text('run all\nquit\n',encoding='ascii')
    return work
if __name__=='__main__':raise SystemExit(execute(Path(sys.argv[1])))
