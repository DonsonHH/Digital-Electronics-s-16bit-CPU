"""Fresh source-bound XSim runs, WDB/VCD and relocatable XPR. No hardware access."""
from pathlib import Path
import argparse
import datetime
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parent


def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()


def run(program, bins):
    manifest = json.loads((ROOT/'source_manifest.json').read_text(encoding='utf-8'))
    for name, expected in manifest['sha256'].items():
        if sha(ROOT/name) != expected:
            raise ValueError('Packaged input changed: '+name)
    work = Path(tempfile.mkdtemp(prefix='pre6_xsim_'))
    result = {'status':'RUNNING', 'program':program, 'work_directory':str(work),
              'started_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),
              'CPU':'v1.6', 'ISA':'v1.5', 'implementation':'AC1',
              'new_XSim_execution':True, 'physical_board_execution':False}
    dest = ROOT/'运行记录'/work.name
    try:
        for group in ['rtl','tb','programs','constraints','tools']:
            shutil.copytree(ROOT/group,work/group)
        if program != 'system':
            for p in (ROOT/'benchmarks'/program).iterdir():
                shutil.copy2(p, work/('tb' if p.suffix=='.svh' else 'programs')/p.name)
        else:
            # Both benches compile; the selected bench needs an include even when it is not the top.
            shutil.copy2(ROOT/'benchmarks/copy_checksum/selected_expected.svh',work/'tb/selected_expected.svh')
        shutil.copy2(ROOT/'create_project.tcl',work/'create_project.tcl')
        command = work/'run.cmd'
        command.write_text('@echo off\ncall "'+str(bins/'vivado.bat')+'" -mode batch -source create_project.tcl -log vivado.log -nojournal -tclargs '+program+'\nexit /b %errorlevel%\n',encoding='ascii')
        result['input_sha256']={p.relative_to(work).as_posix():sha(p) for p in work.rglob('*') if p.is_file()}
        env=dict(os.environ)
        env.update(PYTHONUTF8='1',PYTHONDONTWRITEBYTECODE='1')
        console=work/'console.log'
        print('PRE6_NATIVE_START program='+program+' work='+str(work),flush=True)
        process=None
        try:
            with console.open('wb') as out:
                process=subprocess.Popen([sys.executable,str(work/'tools/desktop_launch.py'),
                                          r'C:\Windows\System32\cmd.exe','/d','/c',str(command)],
                                         cwd=work,env=env,stdout=out,stderr=subprocess.STDOUT)
                result['launcher_pid']=process.pid
                result['exit_code']=process.wait(timeout=900)
        finally:
            if process is not None and process.poll() is None:
                process.kill();process.wait()
        text=console.read_text(encoding='utf-8',errors='replace')
        if result.get('exit_code')!=0 or re.search(r'(?im)^ERROR:|^Fatal:|FATAL_ERROR',text):
            raise RuntimeError('Native run failed; inspect console.log')
        if 'PRE6_SIMULATION_COMPLETE' not in text or '$finish called at time' not in text:
            raise RuntimeError('No verified normal simulation completion')
        if program=='system':
            if 'SYSTEM_PASS cases=11 boot=file_only reset_kinds=2 debug_injections=2' not in text:
                raise RuntimeError('System suite did not finish')
            result['case_lines']=re.findall(r'^SYSTEM_CASE_PASS .+$',text,re.M)
            if len(result['case_lines'])!=12:
                raise RuntimeError('Expected 12 system epoch results')
        else:
            exp=manifest['programs'][program]
            pattern=(r'BOARD_SELECTED_PASS program='+program+r' cycles=(\d+) completed=(\d+) stalls=(\d+) redirects=(\d+) stores=(\d+)')
            found=re.findall(pattern,text)
            expected=tuple(str(exp[k])for k in ['CYCLES','N','STALLS','REDIRECTS','STORES'])
            if found != [expected]:
                raise RuntimeError('Missing or incorrect exact program counts')
            result['actual']=dict(zip(['C','N','S','R','stores'],map(int,found[0])))
        for name,expected in result['input_sha256'].items():
            if sha(work/name)!=expected:raise RuntimeError('Input changed during run: '+name)
        result['status']='PASS'
        result['project_relative']='project/pre6_cpu.xpr'
    except BaseException as error:
        result['status']='FAIL';result['error']=str(error)
        raise
    finally:
        result['ended_utc']=datetime.datetime.now(datetime.timezone.utc).isoformat()
        result['output_sha256']={p.relative_to(work).as_posix():sha(p)for p in work.rglob('*')if p.is_file() and not any(part in p.parts for part in ['xsim.dir','.Xil','__pycache__']) and p.suffix in ['.vcd','.wdb','.csv','.xpr','.log']}
        result['excluded_cache_directories']=['.Xil','xsim.dir','__pycache__']
        (work/'result.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
        dest.parent.mkdir(exist_ok=True)
        shutil.copytree(work,dest,ignore=shutil.ignore_patterns('.Xil','xsim.dir','__pycache__'))
        (ROOT/'最近运行.json').write_text(json.dumps({'status':result['status'],'program':program,'record':dest.relative_to(ROOT).as_posix(),'project':str(dest/'project/pre6_cpu.xpr')},ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
        print('PRE6_RECORD='+str(dest),flush=True)
    print('PRE6_PROGRAM_PASS '+program,flush=True)
    return result


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--program',choices=['all_ops','baseline','loop','memory_copy','copy_checksum','system','all'],default='copy_checksum')
    p.add_argument('--vivado-bin',type=Path,default=Path(os.environ.get('CPU_VIVADO_BIN',r'C:/AMDDesignTools/2025.2/Vivado/bin')))
    a=p.parse_args()
    if not (a.vivado_bin/'vivado.bat').is_file():raise ValueError('Set --vivado-bin or CPU_VIVADO_BIN')
    programs=['all_ops','baseline','loop','memory_copy','copy_checksum','system'] if a.program=='all' else [a.program]
    results=[run(name,a.vivado_bin)for name in programs]
    print('PRE6_RUNS_PASS count='+str(len(results)))


if __name__=='__main__':main()
