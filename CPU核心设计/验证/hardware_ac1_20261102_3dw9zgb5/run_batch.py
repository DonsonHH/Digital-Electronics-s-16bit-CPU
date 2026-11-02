"""Run only an explicitly selected Tcl script in this evidence directory."""
from pathlib import Path
import os,subprocess,sys

root=Path(__file__).resolve().parent
script=root/sys.argv[1]
if not script.is_file() or script.parent!=root or script.suffix!='.tcl':
    raise SystemExit('Expected an existing local Tcl script')
launcher=Path(r'C:\Users\Donson\Documents\GitHub\Digital-Electronics-s-16bit-CPU\CPU核心设计\Vivado\desktop_launch.py')
vivado=Path(r'C:\AMDDesignTools\2025.2\Vivado')
env={k.upper():v for k,v in os.environ.items()}
env['PATH']=';'.join(str(vivado/p)for p in ['lib/win64.o','bin','bin/unwrapped/win64.o'])+';'+env.get('PATH','')
stem=script.stem
cmd=root/(stem+'.cmd')
if cmd.exists() or (root/(stem+'.log')).exists():
    raise SystemExit('Preserve the existing attempt; choose a new script/attempt name')
cmd.write_text('@echo off\ncall "'+str(vivado/'bin/vivado.bat')+'" -mode batch -source '+script.name+' -log '+stem+'.log -journal '+stem+'.jou\nexit /b %errorlevel%\n',encoding='ascii')
with (root/(stem+'.console.log')).open('wb')as out:
    process=subprocess.Popen([sys.executable,str(launcher),r'C:\Windows\System32\cmd.exe','/d','/c',cmd.name],cwd=root,env=env,stdout=out,stderr=subprocess.STDOUT)
    print('OWNED_LAUNCHER_PID='+str(process.pid),flush=True)
    try:
        code=process.wait(timeout=120)
    except BaseException:
        if process.poll()is None:process.kill();process.wait()
        raise
print('BATCH_EXIT='+str(code),flush=True)
raise SystemExit(code)
