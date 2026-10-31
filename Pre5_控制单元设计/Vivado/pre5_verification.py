"""Portable Pre5 verification entry. Changes no original CPU or FPGA image."""
from pathlib import Path
from datetime import datetime,timezone
import argparse,hashlib,json,os,shutil,subprocess,sys,tempfile

ROOT=Path(__file__).resolve().parent
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def read(p):return json.loads(p.read_text(encoding='utf-8-sig'))
def utc():return datetime.now(timezone.utc).isoformat()
def verify_inputs():
    manifest=read(ROOT/'source_manifest.json')
    for name,digest in manifest['input_sha256'].items():
        if sha(ROOT/name)!=digest:raise RuntimeError('Approved package source changed: '+name+'; review and update manifest before claiming a new PASS')
    for folder in ('rtl','tb'):
        expected={n.split('/',1)[1] for n in manifest['input_sha256'] if n.startswith(folder+'/')}
        actual={p.name for p in (ROOT/folder).iterdir() if p.is_file()}
        if expected!=actual:raise RuntimeError('Source inventory differs: '+folder)

def execute(stage):
    verify_inputs()
    if stage=='regression':
        shell=shutil.which('pwsh') or shutil.which('powershell')
        if not shell:raise RuntimeError('PowerShell is required')
        args=[shell,'-NoProfile','-ExecutionPolicy','Bypass','-File',str(ROOT/'run_verify.ps1'),'-Python',sys.executable]
    else:args=[sys.executable,'-B','-X','utf8',str(ROOT/'run_independent.py')]
    # Each attempt owns a real writable ASCII TEMP, avoiding MSIX redirection.
    temp_parent=Path(os.environ.get('LOCALAPPDATA',tempfile.gettempdir()))/'Temp'/'pre5_native'
    if not str(temp_parent).isascii():temp_parent=Path(tempfile.gettempdir())/'pre5_native'
    if not str(temp_parent).isascii():raise RuntimeError('Set TEMP to a writable ASCII directory before running Vivado')
    temp_parent.mkdir(parents=True,exist_ok=True)
    environment=os.environ.copy();environment['TEMP']=str(temp_parent);environment['TMP']=str(temp_parent)
    attempts=ROOT/'验证记录';attempts.mkdir(exist_ok=True)
    log=attempts/(stage+'_'+datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%S%f')+'.console.log')
    started=utc();process=None;code='launch_failed';error=None
    with log.open('wb') as handle:
        try:
            process=subprocess.Popen([sys.executable,'-B',str(ROOT/'desktop_launch.py'),*args],cwd=ROOT,env=environment,stdout=handle,stderr=subprocess.STDOUT)
            code=process.wait(timeout=900)
        except subprocess.TimeoutExpired:code='timeout';error='Owned invocation exceeded 900 seconds'
        except KeyboardInterrupt:code='interrupted';error='Owned invocation interrupted'
        except OSError as exc:code='launch_failed';error=str(exc)
        finally:
            if process is not None and process.poll() is None:process.kill();process.wait()
    try:verify_inputs()
    except Exception as exc:error=str(exc)
    result={'stage':stage,'status':'NATIVE_COMPLETED' if code==0 and error is None else 'FAIL','native_exit':code,
        'started_at_utc':started,'ended_at_utc':utc(),'console':log.relative_to(ROOT).as_posix(),
        'console_sha256':sha(log),'error':error,'hardware_programmed':False}
    log.with_suffix('.json').write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding='utf-8')
    print('PRE5_'+stage.upper()+'_EXIT='+str(code)+' status='+result['status'],flush=True)
    if result['status']!='NATIVE_COMPLETED':raise SystemExit(1)

if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--stage',choices=['regression','independent'],required=True)
    execute(parser.parse_args().stage)
