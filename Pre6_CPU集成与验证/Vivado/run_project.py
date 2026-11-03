"""Create and verify fresh writable CPU/EES-331 projects. Never accesses hardware."""
from pathlib import Path
import argparse
import ctypes
import datetime
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import uuid

ROOT=Path(__file__).resolve().parent


def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()


def copy_bytes(source,target):
    target.parent.mkdir(parents=True,exist_ok=True)
    target.write_bytes(source.read_bytes())


def clear_readonly(root):
    root=root.resolve();changed=[]
    for p in [root,*root.rglob('*')]:
        assert p.resolve().is_relative_to(root)
        flags=ctypes.windll.kernel32.GetFileAttributesW(str(p))
        if flags==-1:raise ctypes.WinError()
        if flags&1:
            if not ctypes.windll.kernel32.SetFileAttributesW(str(p),flags&~1):raise ctypes.WinError()
            changed.append(p.relative_to(root).as_posix())
    return changed


def prepare(work,program):
    manifest=json.loads((ROOT/'source_manifest.json').read_text(encoding='utf-8'))
    for name,digest in manifest['sha256'].items():
        if sha(ROOT/name)!=digest:raise ValueError('Source input changed: '+name)
    for group in ['rtl','tb','constraints','tools']:
        for p in (ROOT/group).rglob('*'):
            if p.is_file():copy_bytes(p,work/group/p.relative_to(ROOT/group))
    for p in (ROOT/'benchmarks'/program).iterdir():
        copy_bytes(p,work/('tb'if p.suffix=='.svh'else'data')/p.name)
    copy_bytes(ROOT/'project_flow.tcl',work/'project_flow.tcl')
    return manifest['programs'][program]


def write_record(dest,receipt):
    temporary=dest/('result.'+uuid.uuid4().hex+'.tmp')
    temporary.write_text(json.dumps(receipt,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    temporary.replace(dest/'result.json')


def run(program,kind,mode,bins,gui=False):
    work=Path(tempfile.mkdtemp(prefix='pre6_r3_'))
    before={}
    receipt={'status':'RUNNING','program':program,'kind':kind,'mode':mode,'gui_mode':gui,'work_directory':str(work),
             'started_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'input_sha256':before,
             'new_XSim_execution':False,'physical_board_execution':False}
    dest=ROOT/'验证记录'/work.name
    dest.mkdir(parents=True,exist_ok=False)
    write_record(dest,receipt) # Visible before preflight or any native process.
    p=None
    try:
        expected=prepare(work,program)
        before={f.relative_to(work).as_posix():sha(f)for f in work.rglob('*')if f.is_file()}
        receipt.update(expected=expected,input_sha256=before)
        write_record(dest,receipt)
        command=work/'run.cmd'
        command.write_text('@echo off\ncall "'+str(bins/'vivado.bat')+'" -mode '+('gui'if gui else'batch')+' -source project_flow.tcl -log vivado.log -nojournal -tclargs '+kind+' '+mode+'\nexit /b %errorlevel%\n',encoding='ascii')
        print('R3_NATIVE_START '+str(work)+' '+kind+' '+program+' '+mode,flush=True)
        with (work/'console.log').open('wb')as output:
            p=subprocess.Popen([sys.executable,str(work/'tools/desktop_launch.py'),r'C:\Windows\System32\cmd.exe','/d','/c',str(command)],
                               cwd=work,env={**os.environ,'PYTHONUTF8':'1','PYTHONDONTWRITEBYTECODE':'1'},stdout=output,stderr=subprocess.STDOUT)
            receipt['launcher_pid']=p.pid;write_record(dest,receipt)
            receipt['exit_code']=p.wait(timeout=1800)
        # GUI mode sends the Tcl/simulation transcript to the native log, not stdout.
        native_log=work/'vivado.log'
        if not native_log.is_file():raise RuntimeError('Native Vivado log missing')
        log=native_log.read_text(encoding='utf-8',errors='replace')
        receipt['native_log_sha256']=sha(native_log)
        if receipt['exit_code']!=0 or re.search(r'(?m)^ERROR:|^CRITICAL WARNING:|^Fatal:|^PRE6_R3_FLOW_FAILED=',log):
            raise RuntimeError('Native flow contains an error/critical warning: '+str(work))
        terminal='PRE6_R3_FLOW_COMPLETE kind='+kind+' mode='+mode
        if terminal not in log:raise RuntimeError('Missing native completion marker')
        if mode!='create':
            pattern='PRE6_CPU_PASS'if kind=='cpu'else'PRE6_BOARD_SIM_PASS'
            found=re.findall('^'+pattern+r' program='+program+r' cycles=(\d+) completed=(\d+) stalls=(\d+) redirects=(\d+) stores=(\d+)$',log,re.M)
            row=tuple(str(expected[k])for k in ['CYCLES','N','STALLS','REDIRECTS','STORES'])
            count=2 if kind=='cpu'and mode in ['synthesis','full']else 1
            if found!=[row]*count or '$finish called at time'not in log:raise RuntimeError('Missing exact behavioral/netlist result')
            receipt['actual']=dict(zip(['C','N','S','R','stores'],map(int,row)))
            receipt['native_checked_epochs']=count
            receipt['new_XSim_execution']=True
        if mode in ['synthesis','full']:
            synth=(work/'project/pre6_cpu.runs/synth_1/runme.log').read_text(encoding='utf-8',errors='replace')
            if 'synth_design completed successfully'not in synth:raise RuntimeError('Synthesis not truly complete')
            if kind=='cpu'and '-mode out_of_context'not in synth:raise RuntimeError('Expected real OOC mode in synthesis command')
            receipt['synthesis']='PASS';receipt['post_synthesis_functional']='PASS'if kind=='cpu'else'not requested'
        if kind=='board'and mode=='full':
            if not list((work/'project/pre6_cpu.runs/impl_1').glob('*.bit')):raise RuntimeError('Bitstream missing')
            receipt['implementation']='PASS';receipt['bitstream']='GENERATED_NOT_PROGRAMMED'
        for name,digest in before.items():
            if sha(work/name)!=digest:raise RuntimeError('Input mutated during native run: '+name)
        receipt['status']='PASS'
    except BaseException as error:
        receipt['status']='FAIL';receipt['error']=str(error);raise
    finally:
        if p is not None and p.poll()is None:p.kill();p.wait()
        receipt['ended_utc']=datetime.datetime.now(datetime.timezone.utc).isoformat()
        # Preserve inputs and useful evidence, not project caches or mutable run state.
        for name in before:copy_bytes(work/name,dest/'inputs'/name)
        evidence=[]
        for f in work.rglob('*'):
            if not f.is_file()or any(x in f.parts for x in ['.Xil','xsim.dir']):continue
            if f.suffix in ['.log','.csv','.vcd','.wdb','.rpt','.dcp','.bit','.ltx']:
                rel=f.relative_to(work).as_posix();copy_bytes(f,dest/'outputs'/rel);evidence.append('outputs/'+rel)
        receipt['archived_input_sha256']={'inputs/'+name:digest for name,digest in before.items()}
        receipt['output_sha256']={name:sha(dest/name)for name in evidence}
        write_record(dest,receipt)
        print('R3_RECORD='+str(dest),flush=True)
    print('R3_PROJECT_PASS '+kind+' '+program+' '+mode,flush=True)
    return work


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--program',choices=['all_ops','baseline','loop','memory_copy','copy_checksum','all'],default='copy_checksum')
    p.add_argument('--kind',choices=['cpu','board'],default='cpu')
    p.add_argument('--mode',choices=['create','behavioral','synthesis','full'],default='full')
    p.add_argument('--gui',action='store_true')
    p.add_argument('--vivado-bin',type=Path,default=Path(r'C:/AMDDesignTools/2025.2/Vivado/bin'))
    args=p.parse_args()
    programs=['all_ops','baseline','loop','memory_copy','copy_checksum']if args.program=='all'else[args.program]
    for program in programs:run(program,args.kind,args.mode,args.vivado_bin,args.gui)


if __name__=='__main__':main()
