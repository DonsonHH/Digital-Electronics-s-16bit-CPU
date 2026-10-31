"""Unified maintained verification entry with resolved tools and a bound stage receipt."""
from pathlib import Path
import argparse,datetime,hashlib,json,os,shutil,subprocess,sys,uuid
from tool_config import add_tool_arguments,resolve_tools
BASE=Path(__file__).resolve().parent
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 p=argparse.ArgumentParser(description=__doc__);add_tool_arguments(p)
 p.add_argument('--suite',choices=['all','regression','independent','mutations','unknown','evidence','lifecycle'],default='all')
 a=p.parse_args();tools=resolve_tools(a.vivado_bin,python=sys.executable,config=a.config)
 expected=json.loads((BASE/'verification/test_manifest.json').read_text(encoding='utf-8'))
 out=BASE.parent/'验证'/('tools_'+uuid.uuid4().hex);out.mkdir(parents=True)
 sources={f.relative_to(BASE).as_posix():sha(f) for f in BASE.rglob('*') if f.is_file() and (f.suffix in ['.py','.ps1','.cmd'] or (f.parent.name=='verification' and f.suffix in ['.md','.json'])) and not any(x in f.parts for x in ['project','__pycache__','时序记录','创建记录'])}
 env={**os.environ,'CPU_VIVADO_BIN':tools['vivado_bin'],'CPU_PYTHON':sys.executable,'PYTHONDONTWRITEBYTECODE':'1','PYTHONUTF8':'1'}
 suites=['regression','independent','mutations','unknown','evidence','lifecycle'] if a.suite=='all' else [a.suite]
 receipt={'status':'RUNNING','suites':suites,'tools':tools,'source_sha256':sources,'manifest_sha256':sha(BASE/'verification/test_manifest.json'),'steps':[],'scope':'Tooling and native execution checks, not hardware acceptance'}
 target=out/'result.json'
 try:
  for suite in suites:
   if suite=='regression':
    cmd=[shutil.which('pwsh') or 'powershell','-NoProfile','-File',str(BASE/'run_verify.ps1'),'-Python',sys.executable,'-VivadoBin',tools['vivado_bin']]
   else:
    script={'independent':'run_independent.py','mutations':'run_mutations.py','unknown':'run_unknown_controls.py','evidence':'run_evidence_tests.py','lifecycle':'test_process_lifecycle.py'}[suite]
    cmd=[sys.executable,'-B','-X','utf8',str(BASE/script)]
    if suite!='lifecycle':cmd+=['--vivado-bin',tools['vivado_bin']]
    if suite=='mutations':cmd+=['--output-root',str(out/'mutations')]
   print('VERIFY_SUITE_START '+suite,flush=True)
   with (out/(suite+'.console.log')).open('wb') as f:rc=subprocess.run(cmd,cwd=BASE,env=env,stdout=f,stderr=subprocess.STDOUT).returncode
   step={'suite':suite,'exit':rc,'log_sha256':sha(out/(suite+'.console.log'))};receipt['steps'].append(step)
   if rc:raise RuntimeError('Verification suite failed: '+suite+'; see '+str(out))
   if suite=='regression':
    r=json.loads((BASE.parent/'验证结果.json').read_text(encoding='utf-8-sig'))
    if r['status']!='PASS' or r['execution_binding']['native_subprocesses']!=expected['regression']['native_steps']:raise ValueError('Native regression manifest mismatch')
   print('VERIFY_SUITE_PASS '+suite,flush=True)
  if any(sha(BASE/n)!=h for n,h in sources.items()):raise ValueError('Tooling sources changed during execution')
  receipt['status']='PASS'
 except BaseException as e:receipt['status']='FAIL';receipt['error']=str(e);raise
 finally:
  receipt['completed_at_utc']=datetime.datetime.now(datetime.timezone.utc).isoformat();target.write_text(json.dumps(receipt,ensure_ascii=False,indent=2),encoding='utf-8')
 print('UNIFIED_VERIFY_PASS receipt='+str(target),flush=True)
if __name__=='__main__':main()
