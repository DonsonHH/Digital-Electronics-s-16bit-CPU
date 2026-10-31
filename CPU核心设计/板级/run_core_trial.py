"""Reuse unchanged trusted core test infrastructure inside a private candidate package."""
from pathlib import Path
import argparse,hashlib,json,os,re,shutil,subprocess,sys,tempfile
B=Path(__file__).resolve().parent;P=B.parent;V=P/'Vivado';sys.path.insert(0,str(V));sys.path.insert(0,str(B))
from tool_config import add_tool_arguments,resolve_tools
from candidate_registry import CANDIDATES,apply_candidate
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 parser=argparse.ArgumentParser(description=__doc__);add_tool_arguments(parser);parser.add_argument('--candidate',choices=['forward_onehot'],required=True);a=parser.parse_args()
 tools=resolve_tools(a.vivado_bin,python=sys.executable,config=a.config)
 work=Path(tempfile.mkdtemp(prefix='cpu345_coretrial_'));package=work/'package';package.mkdir();dest=P/'验证'/work.name
 result={'status':'RUNNING','candidate':a.candidate,'scope':'Original core regressions and immutable48 fixture contract for a cycle-preserving combinational candidate','steps':[],'tools':tools}
 try:
  shutil.copytree(V,package/'Vivado',ignore=shutil.ignore_patterns('project','时序记录','创建记录','综合记录','__pycache__'))
  shutil.copytree(P/'程序镜像',package/'程序镜像')
  shutil.copytree(V/'rtl',work/'rtl');result['candidate_overlay_sha256']=apply_candidate(work,a.candidate)
  shutil.copy2(work/'rtl/operand_forward.v',package/'Vivado/rtl/operand_forward.v')
  result['executed_RTL_sha256']={p.name:sha(p) for p in (package/'Vivado/rtl').iterdir() if p.is_file()}
  env={**os.environ,'CPU_VIVADO_BIN':tools['vivado_bin'],'CPU_PYTHON':sys.executable,'PYTHONDONTWRITEBYTECODE':'1'}
  suites=['regression','independent','mutations','unknown']
  for suite in suites:
   print('CORE_TRIAL_START '+suite,flush=True)
   if suite=='regression':command=[shutil.which('pwsh') or 'powershell','-NoProfile','-File',str(package/'Vivado/run_verify.ps1'),'-Python',sys.executable,'-VivadoBin',tools['vivado_bin']]
   else:
    script={'independent':'run_independent.py','mutations':'run_mutations.py','unknown':'run_unknown_controls.py'}[suite]
    command=[sys.executable,'-B','-X','utf8',str(package/'Vivado'/script),'--vivado-bin',tools['vivado_bin']]
    if suite=='mutations':command+=['--output-root',str(work/'mutations')]
   log=work/(suite+'.console.log')
   with log.open('wb') as output:code=subprocess.run(command,cwd=package,env=env,stdout=output,stderr=subprocess.STDOUT).returncode
   result['steps'].append({'suite':suite,'exit':code,'log_sha256':sha(log)})
   if code:raise RuntimeError('Core candidate suite failed: '+suite)
   print('CORE_TRIAL_PASS '+suite,flush=True)
  receipt=json.loads((package/'验证结果.json').read_text(encoding='utf-8-sig'))
  if receipt['status']!='PASS' or receipt['execution_binding']['native_subprocesses']!=19:raise ValueError('Core9 native count binding missing')
  if receipt['rtl_sha256']!=result['executed_RTL_sha256']:raise ValueError('Core candidate source receipt differs')
  result['core_regression']=receipt
  result['status']='PASS'
 except BaseException as error:result.update(status='FAIL',error=str(error));raise
 finally:
  (work/'result.json').write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding='utf-8');shutil.copytree(work,dest,ignore=shutil.ignore_patterns('.Xil','xsim.dir','__pycache__'));print('CORE_TRIAL_RECORD='+str(dest),flush=True)
if __name__=='__main__':main()
