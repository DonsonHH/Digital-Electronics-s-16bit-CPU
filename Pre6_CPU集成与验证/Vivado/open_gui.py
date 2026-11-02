"""Open a writable GUI project; board IP uses an automatic short ASCII workspace."""
from pathlib import Path
import argparse
import json
import os
import subprocess
import sys
import tempfile
from run_project import clear_readonly
from publish_projects import quoted

ROOT=Path(__file__).resolve().parent


def main():
    parser=argparse.ArgumentParser();parser.add_argument('kind',choices=['cpu','board'],default='cpu',nargs='?');parser.add_argument('--verify',action='store_true');a=parser.parse_args()
    target=Path.home()/'Documents/CPU_Pre6'/('CPU'if a.kind=='cpu'else'EES331')
    xpr=target/'project/pre6_cpu.xpr'
    from publish_projects import create_working_project
    xpr=create_working_project(a.kind,target)
    clear_readonly(target)
    if a.verify:
        if a.kind!='cpu':raise ValueError('Use the board implementation flow for board acceptance')
        from publish_projects import native
        script='set argv [list '+quoted(xpr)+']\nsource -encoding utf-8 '+quoted(ROOT/'accept_gui_project.tcl')+'\n'
        work,proof=native(script,'Short workspace GUI acceptance',gui=True)
        import re
        if not re.search(r'^PRE6_GUI_ACCEPTANCE_COMPLETE$',proof,re.M):raise RuntimeError('GUI acceptance incomplete')
        print('OPEN_GUI_VERIFIED='+str(work));return
    work=Path(tempfile.mkdtemp(prefix='pre6_open_'))
    (work/'open.tcl').write_text('open_project '+quoted(xpr)+'\n',encoding='ascii')
    (work/'open.cmd').write_text('@echo off\ncall C:\\AMDDesignTools\\2025.2\\Vivado\\bin\\vivado.bat -mode gui -source open.tcl -log open.log -nojournal\n',encoding='ascii')
    log=(work/'launcher.log').open('wb')
    p=subprocess.Popen([sys.executable,str(ROOT/'tools/desktop_launch.py'),r'C:\Windows\System32\cmd.exe','/d','/c',str(work/'open.cmd')],cwd=work,stdout=log,stderr=subprocess.STDOUT,creationflags=subprocess.CREATE_NO_WINDOW)
    print('VIVADO_OPENING='+str(xpr))
    print('OPEN_LOG='+str(work/'open.log'))


if __name__=='__main__':main()
