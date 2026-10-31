"""Windows lifecycle checks using only freshly created, invocation-owned processes.

Run: python -B -X utf8 test_process_lifecycle.py
No Vivado process is enumerated or killed by name. Process handles are retained
before termination, so cleanup cannot accidentally target a recycled PID.
"""
from pathlib import Path
import argparse,ctypes as c,json,os,shutil,subprocess,sys,tempfile,time
from ctypes import wintypes as w

ROOT=Path(__file__).resolve().parent
parser=argparse.ArgumentParser()
parser.add_argument('--launcher',type=Path,default=ROOT/'desktop_launch.py')
parser.add_argument('--worker',choices=('leaf','root'))
parser.add_argument('--release',type=Path)
args=parser.parse_args()
if args.worker=='leaf':
    time.sleep(60);raise SystemExit(0)
if args.worker=='root':
    child=subprocess.Popen([sys.executable,'-B',str(Path(__file__)),'--worker','leaf'])
    print('OWNED_PID',os.getpid(),flush=True);print('OWNED_PID',child.pid,flush=True)
    while not args.release.exists():time.sleep(0.02)
    # Intentionally leave the child running to test normal wrapper-exit cleanup.
    raise SystemExit(0)

if os.name!='nt':raise SystemExit('This test requires Windows')
k=c.WinDLL('kernel32',use_last_error=True)
k.OpenProcess.argtypes=[w.DWORD,w.BOOL,w.DWORD];k.OpenProcess.restype=w.HANDLE
k.WaitForSingleObject.argtypes=[w.HANDLE,w.DWORD];k.WaitForSingleObject.restype=w.DWORD
k.TerminateProcess.argtypes=[w.HANDLE,w.UINT];k.TerminateProcess.restype=w.BOOL
k.CloseHandle.argtypes=[w.HANDLE];k.CloseHandle.restype=w.BOOL

def owned_handle(pid):
    h=k.OpenProcess(0x100000|0x0001,False,pid)
    if not h:raise c.WinError(c.get_last_error())
    return h

def checked_tree(label,kill_launcher,unrelated,work):
    log=work/(label+'.log');release=work/(label+'.release');handles=[];process=None
    try:
        with log.open('wb') as out:
            process=subprocess.Popen([sys.executable,'-B',str(args.launcher),sys.executable,
                '-B',str(Path(__file__)),'--worker','root','--release',str(release)],stdout=out,stderr=subprocess.STDOUT)
            deadline=time.monotonic()+10
            while time.monotonic()<deadline:
                raw=log.read_text(encoding='utf-8',errors='replace')
                pids=[int(s.split()[1]) for s in raw.splitlines() if s.startswith('OWNED_PID ')]
                if len(pids)==2:break
                if process.poll() is not None:raise AssertionError('Launcher failed before worker startup: '+raw)
                time.sleep(0.02)
            else:raise AssertionError('Worker startup timed out')
            for pid in pids:handles.append(owned_handle(pid))
            if kill_launcher:process.kill()
            else:release.touch()
            rc=process.wait(timeout=10)
            stopped=[k.WaitForSingleObject(h,3000)==0 for h in handles]
            assert all(stopped),f'{label}: owned descendants remain alive: {stopped}'
            assert unrelated.poll() is None,'Unrelated sentinel was terminated'
            if not kill_launcher:assert rc==0,'Successful child exit changed'
        print('LIFECYCLE_CHECK_PASS '+label,flush=True)
    finally:
        if process is not None and process.poll() is None:process.kill();process.wait()
        for h in handles:
            if k.WaitForSingleObject(h,0)==258:k.TerminateProcess(h,1);k.WaitForSingleObject(h,3000)
            k.CloseHandle(h)

work=Path(tempfile.mkdtemp(prefix='cpu_process_lifecycle_'))
unrelated=subprocess.Popen([sys.executable,'-B',str(Path(__file__)),'--worker','leaf'],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
try:
    for code in (0,7):
        result=subprocess.run([sys.executable,'-B',str(args.launcher),r'C:\Windows\System32\cmd.exe','/d','/c','exit',str(code)],capture_output=True,timeout=10)
        assert result.returncode==code,(code,result.stdout,result.stderr)
        print('LIFECYCLE_CHECK_PASS exit_'+str(code),flush=True)
    result=subprocess.run([sys.executable,'-B',str(args.launcher),str(work/'nonexistent_program.exe')],capture_output=True,timeout=10)
    assert result.returncode!=0,'Missing executable unexpectedly succeeded'
    print('LIFECYCLE_CHECK_PASS launch_failure',flush=True)
    checked_tree('forced_launcher_exit',True,unrelated,work)
    checked_tree('normal_exit_cleans_orphan',False,unrelated,work)
    # Check the shared negative runner saves a timeout receipt, not a PASS.
    from negative_test_support import execute
    timeout_run=work/'negative_timeout';timeout_run.mkdir()
    shutil.copy2(args.launcher,timeout_run/'desktop_launch.py')
    # Keep the generated batch command ASCII even when this project lives in a
    # Chinese OneDrive directory; the temporary fixture uses a relative name.
    shutil.copy2(Path(__file__),timeout_run/'lifecycle_worker.py')
    (timeout_run/'run.cmd').write_text('@echo off\n"'+sys.executable+'" -B lifecycle_worker.py --worker leaf\n',encoding='ascii')
    assert execute(timeout_run,timeout=0.3)==1
    receipt=json.loads((timeout_run/'native_execution.json').read_text())
    assert receipt['exit_code']=='timeout' and receipt['error']
    assert unrelated.poll() is None
    print('LIFECYCLE_CHECK_PASS negative_timeout_receipt',flush=True)
    print('PROCESS_LIFECYCLE_PASS checks=6 scope=owned_processes_only',flush=True)
finally:
    if unrelated.poll() is None:unrelated.terminate();unrelated.wait(timeout=10)
