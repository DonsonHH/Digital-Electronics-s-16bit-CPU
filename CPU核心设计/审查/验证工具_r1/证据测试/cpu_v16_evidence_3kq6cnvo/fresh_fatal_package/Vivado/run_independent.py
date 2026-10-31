"""Execute a generated, manifest-bound independent48 package in a fresh native job."""
from pathlib import Path
import argparse,csv,datetime,hashlib,json,math,re,shutil,stat,subprocess,sys,tempfile
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
    frozen=json.loads((BASE/'verification/frozen48_content.json').read_text(encoding='utf-8'))['files']
    oracle_sources={Path(n).name:BASE/n for n in ['generate_independent.py','verification/isa_reference.py','verification/independent_vectors.py','verification/test_manifest.json','verification/ISA_v1.5_contract.md','verification/frozen48_content.json']}
    required=set(frozen)|{'oracle_source/'+n for n in oracle_sources}
    actual=set()
    for p in source.rglob('*'):
        if p.is_symlink() or getattr(p.lstat(),'st_reparse_tag',0)==getattr(stat,'IO_REPARSE_TAG_MOUNT_POINT',0xA0000003):raise ValueError('Case package links are not permitted')
        if p.is_file():actual.add(p.relative_to(source).as_posix())
    if actual!=required|{'manifest.json'} or set(manifest['input_sha256'])!=required:raise ValueError('Case package must contain the exact reviewed fixture inventory; logs and executors are forbidden')
    for name,digest in frozen.items():
        if hashlib.sha256((source/name).read_bytes().replace(b'\r\n',b'\n')).hexdigest()!=digest:raise ValueError('Fixture differs from the independent frozen content contract: '+name)
    for name,p in oracle_sources.items():
        if (source/'oracle_source'/name).read_bytes()!=p.read_bytes():raise ValueError('Case oracle source differs from this tool revision: '+name)
    for name,digest in manifest['input_sha256'].items():
        target=(source/name).resolve()
        if not target.is_relative_to(source.resolve()) or sha(target)!=digest:raise ValueError('Case package hash mismatch: '+name)
    return expected
def main():
    parser=argparse.ArgumentParser(description=__doc__);add_tool_arguments(parser)
    parser.add_argument('--cases',type=Path);parser.add_argument('--rtl',type=Path,default=BASE/'rtl')
    parser.add_argument('--timeout',type=positive_timeout,default=600)
    a=parser.parse_args();tools=resolve_tools(a.vivado_bin,python=sys.executable,config=a.config)
    source=a.cases.resolve() if a.cases else Path(tempfile.mkdtemp(prefix='cpu_cases_parent_'))/'cases'
    if a.cases is None:generate(source)
    expected=load_case_package(source)
    run=Path(tempfile.mkdtemp(prefix='cpu_ac1_independent_'))
    shutil.copytree(a.rtl,run/'rtl');shutil.copy2(BASE/'desktop_launch.py',run/'desktop_launch.py')
    for group in ['programs','oracle_source']:shutil.copytree(source/group,run/group)
    for name in ['cases.json','case_config.svh','case_count.svh','manifest.json']:shutil.copy2(source/name,run/name)
    shutil.copy2(BASE/'verification/tb_adversarial.sv',run/'tb_adversarial.sv')
    declared=json.loads((run/'manifest.json').read_text(encoding='utf-8'))['input_sha256']
    for name,digest in declared.items():
        if sha(run/name)!=digest:raise ValueError('Case package changed during copying: '+name)
    # Keep the reviewed frozen checker byte-for-byte in the generated packet.
    # In the PRIVATE execution copy only, connect its original 13 ports
    # explicitly so later observation-only output ports may remain open.
    # The replacement cannot touch any oracle, assertion or timing logic.
    checker=run/'tb_adversarial.sv';before=sha(checker)
    text=checker.read_text(encoding='utf-8')
    old='datapath_core dut(.*);'
    explicit='datapath_core dut(.clk(clk),.rst(rst),.im_addr(im_addr),.im_en(im_en),.im_dout(im_dout),.dm_addr(dm_addr),.dm_en(dm_en),.dm_we(dm_we),.dm_din(dm_din),.dm_dout(dm_dout),.halted(halted),.fault(fault));'
    if text.count(old)!=1:raise ValueError('Frozen checker connection seam changed')
    checker.write_text(text.replace(old,explicit),encoding='utf-8')
    checker_adapter={'revision':'explicit_original_ports_r1','scope':'private connection-only substitution; frozen packet and all checker assertions unchanged','packet_sha256':before,'executed_sha256':sha(checker)}
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
    data['checker_interface_adapter']=checker_adapter
    (run/'independent_result.json').write_text(json.dumps(data,indent=2),encoding='utf-8')
    dest=PACKAGE/'验证记录'/run.name;shutil.copytree(run,dest,ignore=shutil.ignore_patterns('.Xil','xsim.dir','__pycache__'))
    if not passed:raise SystemExit('Independent execution failed; raw failed attempt saved: '+str(dest))
    print('INDEPENDENT48_PASS archive='+str(dest))
if __name__=='__main__':main()
