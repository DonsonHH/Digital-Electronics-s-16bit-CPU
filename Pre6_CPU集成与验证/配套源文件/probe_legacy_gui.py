"""Reproduce the user's GUI synthesis path on a private copy of the delivered r2 project."""
from pathlib import Path
import argparse
import ctypes
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile

SOURCE=Path(r'D:/OneDrive - University of Glasgow/同步文件夹/大三上/Courses/数电/Pre6_CPU集成与验证/Vivado/工程')
VIVADO=Path(r'C:/AMDDesignTools/2025.2/Vivado/bin/vivado.bat')


def main():
    parser=argparse.ArgumentParser();parser.add_argument('--clear-output-readonly',action='store_true');parser.add_argument('--flat-synthesis-images',action='store_true');args=parser.parse_args()
    work=Path(tempfile.mkdtemp(prefix='pre6_gui_red_'))
    shutil.copytree(SOURCE,work/'snapshot',ignore=shutil.ignore_patterns('.Xil','xsim.dir','__pycache__'))
    changed=[]
    if args.clear_output_readonly:
        for root in (work/'snapshot/project').iterdir():
            if root.is_dir()and root.name.endswith(('.cache','.runs','.sim')):
                for item in [root,*root.rglob('*')]:
                    attributes=ctypes.windll.kernel32.GetFileAttributesW(str(item))
                    if attributes&1:
                        if not ctypes.windll.kernel32.SetFileAttributesW(str(item),attributes&~1):raise ctypes.WinError()
                        changed.append(item.relative_to(work).as_posix())
    xpr=work/'snapshot/project/pre6_cpu.xpr'
    script='''set pre6_xpr {%s}
puts "GUI_REPRO_BEGIN"
foreach suffix {pre6_cpu.cache/wt pre6_cpu.runs/synth_1} {
    set folder [file join [file dirname $pre6_xpr] $suffix]
    puts "GUI_DIRECTORY_CHECK path=$folder exists=[file exists $folder] writable=[file writable $folder] readonly=[file attributes $folder -readonly]"
}
open_project $pre6_xpr
__GENERIC_FIX__
set run_folder [file normalize [get_property DIRECTORY [get_runs synth_1]]]
if {![string match "[file dirname [file dirname $pre6_xpr]]/*" $run_folder]} {error "Run directory escaped private snapshot"}
reset_run synth_1
launch_runs synth_1 -jobs 2
wait_on_run synth_1
puts "GUI_SYNTH_STATUS=[get_property STATUS [get_runs synth_1]]"
close_project
puts "GUI_REPRO_FINISH"
exit
'''%xpr.as_posix()
    generic='set_property generic {IM_INIT_FILE="dut_im.mem" DM_INIT_FILE="dut_dm.mem"} [get_filesets sources_1]\nputs "GUI_SELECTED_IMAGES=[get_property generic [get_filesets sources_1]]"' if args.flat_synthesis_images else ''
    script=script.replace('__GENERIC_FIX__',generic)
    (work/'probe.tcl').write_text(script,encoding='ascii')
    (work/'probe.cmd').write_text('@echo off\ncall "'+str(VIVADO)+'" -mode batch -source probe.tcl -log probe.log -nojournal\nexit /b %errorlevel%\n',encoding='ascii')
    with (work/'console.log').open('wb')as out:
        p=subprocess.run([sys.executable,str(SOURCE/'tools/desktop_launch.py'),r'C:\Windows\System32\cmd.exe','/d','/c',str(work/'probe.cmd')],cwd=work,stdout=out,stderr=subprocess.STDOUT,timeout=600,env={**os.environ,'PYTHONUTF8':'1'})
    log=(work/'console.log').read_text(encoding='utf-8',errors='replace')
    symptoms=[line for line in log.splitlines()if ('GUI_DIRECTORY_CHECK path='in line and not line.startswith('#'))or re.search(r'Common 17-1293|Synth 8-4445|^ERROR:|GUI_SYNTH_STATUS=',line)]
    red=bool(re.search(r'Common 17-1293|Synth 8-4445',log))
    green=not red and 'GUI_SYNTH_STATUS=synth_design Complete!'in log and not re.search(r'(?m)^ERROR:|^CRITICAL WARNING:',log)
    result={'private_work':str(work),'source_project':str(SOURCE),'native_exit':p.returncode,'cleared_output_readonly':len(changed),'flat_synthesis_images':args.flat_synthesis_images,'same_GUI_symptom_reproduced':red,'corrected_synthesis_green':green,'symptoms':symptoms}
    (work/'reproduction.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print(json.dumps(result,ensure_ascii=False),flush=True)
    if args.flat_synthesis_images:
        if not green:raise SystemExit('Corrected synthesis did not pass')
    elif not red:raise SystemExit('Original directory/MEM symptom not reproduced; inspect native log before proposing fixes')


if __name__=='__main__':main()
