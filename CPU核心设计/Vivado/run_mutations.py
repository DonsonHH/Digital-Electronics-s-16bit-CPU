"""Independent negative review: mutate private snapshots, never delivered RTL."""
from pathlib import Path
import argparse,hashlib,json,re,shutil,subprocess,sys,tempfile
from datetime import datetime,timezone
p=argparse.ArgumentParser();p.add_argument('--vivado-bin',default=r'C:\AMDDesignTools\2025.2\Vivado\bin');a=p.parse_args()
root=Path(__file__).parent;results=[]
mutants=[
 ('drop_store_wb','datapath_core.sv','w_valid_next = m_valid;','w_valid_next = m_valid && !m_mem_write;','tb_datapath'),
 ('disable_interlock','datapath_core.sv','wire load_use = x_valid &&','wire load_use = 1\'b0 && x_valid &&','tb_datapath'),
 ('disable_z_forward','datapath_core.sv','if (m_valid && !m_fault && m_z_write)',"if (1'b0 && m_valid && !m_fault && m_z_write)",'tb_datapath'),
 ('keep_young_after_redirect','datapath_core.sv','if (mode == RUN && !frontend_kill)', 'if (mode == RUN)','tb_datapath'),
 ('load_ea_forward','operand_forward.v','if (!m_mem_read)',"if (1'b1)",'tb_forward_contract'),
]
baseline={p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in (root/'rtl').iterdir() if p.is_file()}
# A runtime error unrelated to the injected fault is not a successful control.
expected_failures={
 'drop_store_wb':r'^Unified M/W valid lost BASELINE$',
 'disable_interlock':r'^Unready newest producer consumed BASELINE$',
 'disable_z_forward':r'^Uniform WB order BASELINE index=9 pc=0009$',
 'keep_young_after_redirect':r'^Pipeline occupancy lost/duplicated BASELINE$',
 'load_ea_forward':r'^FORWARD_CONTRACT idx=00000000 qualifiers=000000d8$',
}
for label,file,old,new,top in mutants:
 run=Path(tempfile.mkdtemp(prefix='cpu_v16_mutant_'))
 for group in ('rtl','tb'):shutil.copytree(root/group,run/group)
 shutil.copy2(root/'desktop_launch.py',run/'desktop_launch.py')
 target=run/'rtl'/file;text=target.read_text();n=text.count(old)
 if n<1:raise RuntimeError('Mutation seam missing: '+label)
 target.write_text(text.replace(old,new),encoding='utf-8')
 sources=' '.join('rtl/'+p.name for p in sorted((run/'rtl').glob('*')) if p.suffix in ('.v','.sv'))
 sources+=' '+(' '.join('tb/'+p.name for p in sorted((run/'tb').glob('*.sv'))))
 command=rf'''@echo off
setlocal
call "{a.vivado_bin}\xvlog.bat" --sv -i tb {sources}
if errorlevel 1 exit /b 1
call "{a.vivado_bin}\xelab.bat" {top} -s mutant_sim -debug typical
if errorlevel 1 exit /b 1
call "{a.vivado_bin}\xsim.bat" mutant_sim -tclbatch run.tcl -log mutant.log
if errorlevel 1 exit /b 1
exit /b 0
'''
 (run/'run.cmd').write_text(command,encoding='ascii');(run/'run.tcl').write_text('run all\nquit\n',encoding='ascii')
 execution=subprocess.run([sys.executable,str(run/'desktop_launch.py'),r'C:\Windows\System32\cmd.exe','/d','/c','run.cmd'],cwd=run,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True)
 log=(run/'mutant.log').read_text(errors='replace') if (run/'mutant.log').exists() else ''
 fatal=re.search(r'(?m)^Fatal: (.+)',log)
 if not fatal:raise RuntimeError('Mutant escaped functional checks or failed before simulation: '+label+' '+execution.stdout[-1500:])
 if not re.fullmatch(expected_failures[label],fatal[1]):
  raise RuntimeError('Unrelated Fatal must not count as mutation detection: '+label+' '+fatal[1])
 destination=root.parent/'审查/负向测试'/run.name/label
 destination.mkdir(parents=True,exist_ok=False)
 shutil.copy2(run/'mutant.log',destination/'mutant.log');shutil.copy2(target,destination/file)
 for group in ('rtl','tb'):shutil.copytree(run/group,destination/group)
 for driver in ('run.cmd','run.tcl','desktop_launch.py'):shutil.copy2(run/driver,destination/driver)
 record={'mutation':label,'target':file,'matches':n,'top':top,'runtime':str(run),'archive_relative':destination.relative_to(root.parent).as_posix(),'rejected_at_runtime':True,'expected_failure':expected_failures[label],'fatal':fatal[1],'tool_exit':execution.returncode,'log_sha256':hashlib.sha256((destination/'mutant.log').read_bytes()).hexdigest(),'input_sha256':{p.relative_to(destination).as_posix():hashlib.sha256(p.read_bytes()).hexdigest() for group in ('rtl','tb') for p in sorted((destination/group).iterdir()) if p.is_file()}}
 results.append(record);print(json.dumps(record))
if baseline!={p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in (root/'rtl').iterdir() if p.is_file()}:raise RuntimeError('Delivered RTL changed during mutation review')
(root.parent/'审查/negative_mutations.json').write_text(json.dumps({'checks':len(results),'all_rejected':True,'completed_at_utc':datetime.now(timezone.utc).isoformat(),'runner_sha256':hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),'scope':'five deliberate private RTL faults with matched expected runtime failures; not general fault tolerance','results':results},indent=2),encoding='utf-8')
