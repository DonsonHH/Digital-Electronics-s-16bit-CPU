"""Create GUI working projects from source; never copy cached run folders or attributes."""
from pathlib import Path
import argparse
import datetime
import json
import os
import subprocess
import sys
import tempfile
import shutil
from run_project import prepare,clear_readonly,sha

ROOT=Path(__file__).resolve().parent


def quoted(p):return '"'+p.as_posix().encode('ascii','backslashreplace').decode('ascii')+'"'


def native(script,label,gui=False):
    work=Path(tempfile.mkdtemp(prefix='pre6_r3_publish_'))
    (work/'bootstrap.tcl').write_text(script,encoding='ascii')
    (work/'run.cmd').write_text('@echo off\ncall C:\\AMDDesignTools\\2025.2\\Vivado\\bin\\vivado.bat -mode '+('gui'if gui else'batch')+' -source bootstrap.tcl -log native.log -nojournal\nexit /b %errorlevel%\n',encoding='ascii')
    with (work/'console.log').open('wb')as out:
        result=subprocess.run([sys.executable,str(ROOT/'tools/desktop_launch.py'),r'C:\Windows\System32\cmd.exe','/d','/c',str(work/'run.cmd')],cwd=work,stdout=out,stderr=subprocess.STDOUT,env={**os.environ,'PYTHONUTF8':'1'},timeout=1800)
    log=(work/'native.log').read_text(encoding='utf-8',errors='replace')
    import re
    if result.returncode or re.search(r'(?m)^ERROR:|^CRITICAL WARNING:|^Fatal:|^PRE6_R3_FLOW_FAILED=',log):raise RuntimeError(label+' failed: '+str(work))
    return work,log


def create_working_project(kind,target):
    target=target.resolve();xpr=target/'project/pre6_cpu.xpr'
    marker=target/'.pre6_publisher.json';receipt=target/'创建记录.json'
    if target.exists():
        complete=json.loads(receipt.read_text(encoding='utf-8'))if receipt.is_file()else{}
        if complete.get('kind')==kind and complete.get('created_from_source')and xpr.is_file():
            clear_readonly(target);return xpr
        owned=json.loads(marker.read_text(encoding='utf-8'))if marker.is_file()else{}
        if owned.get('creator')!='pre6-r3-publisher'and not complete.get('created_from_source'):
            raise ValueError('Existing directory is not a recognized Pre6 working project: '+str(target))
        saved=target.with_name(target.name+'_incomplete_'+datetime.datetime.now().strftime('%Y%m%d_%H%M%S_%f'))
        assert saved.parent==target.parent and not saved.exists()
        shutil.move(target,saved)
        print('PRE6_INCOMPLETE_WORK_PRESERVED='+str(saved),flush=True)
    target.mkdir(parents=True)
    state={'creator':'pre6-r3-publisher','kind':kind,'status':'PREPARING'}
    marker.write_text(json.dumps(state,indent=2),encoding='utf-8')
    try:
        prepare(target,'copy_checksum');clear_readonly(target)
        script='set argv [list '+kind+' create]\nsource -encoding utf-8 '+quoted(target/'project_flow.tcl')+'\n'
        work,log=native(script,'Create '+kind)
        if 'PRE6_R3_FLOW_COMPLETE kind='+kind+' mode=create'not in log:raise RuntimeError('Creation marker missing')
        clear_readonly(target)
        proof={'kind':kind,'program':'copy_checksum','project':str(xpr),'created_from_source':True,
               'no_copied_run_state':True,'native_log':str(work/'native.log'),'native_log_sha256':sha(work/'native.log')}
        receipt.write_text(json.dumps(proof,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
        state['status']='READY';marker.write_text(json.dumps(state,indent=2),encoding='utf-8')
    except BaseException as error:
        state.update(status='FAILED',error=str(error));marker.write_text(json.dumps(state,indent=2),encoding='utf-8');raise
    return xpr


def main():
    parser=argparse.ArgumentParser();parser.add_argument('--destination',type=Path,default=ROOT)
    parser.add_argument('--kind',choices=['cpu','board','both'],default='both')
    parser.add_argument('--cpu-directory',type=Path,default=Path.home()/'Documents/CPU_Pre6/CPU')
    parser.add_argument('--board-directory',type=Path,default=Path.home()/'Documents/CPU_Pre6/EES331')
    a=parser.parse_args()
    for kind,folder in [('cpu','工程'),('board','EES331工程')]:
        if a.kind not in [kind,'both']:continue
        target=a.cpu_directory.resolve()if kind=='cpu'else a.board_directory.resolve()
        if not str(target).isascii():raise ValueError('Vivado GUI/IP generation uses the configured ASCII work directory')
        xpr=create_working_project(kind,target)
        print('R3_GUI_PROJECT_READY '+str(xpr),flush=True)


if __name__=='__main__':main()
