from pathlib import Path
import json,shutil,subprocess,sys,uuid,hashlib,re,tempfile
from negative_test_support import ROOT,sha
base=ROOT.parent;out=Path(tempfile.mkdtemp(prefix='cpu_v16_evidence_'))
status=json.loads((base/'最近运行.json').read_text(encoding='utf-8-sig'));positive=Path(status['archived_run'])
receipt=json.loads((positive/'verification_results.json').read_text(encoding='utf-8'))
if receipt['result_kind']!='fresh_execution' or receipt['execution_binding']['native_subprocesses']!=19:raise RuntimeError('Positive fresh proof missing')
results=[dict(case='actual_fresh_execution',status=receipt['status'],attempt_id=receipt['attempt_id'],native_commands=19)]
def cli(name,run,extra=None,expect=0):
    target=out/(name+'.json');console=out/(name+'.console.log')
    argv=[sys.executable,str(base/'Vivado'/'verify_results.py'),'--run',str(run),'--output',str(target)]+(extra or [])
    with console.open('wb') as f:p=subprocess.run(argv,stdout=f,stderr=subprocess.STDOUT)
    data=json.loads(target.read_text(encoding='utf-8'))
    if p.returncode!=expect or data.get('new_xsim_execution') is not False or data.get('new_execution_pass') is not False or data['status']=='PASS':raise RuntimeError('Historical CLI promoted or misclassified '+name)
    results.append(dict(case=name,exit=p.returncode,result=data,console_sha256=sha(console)))
    print('M2_CASE_CHECKED '+name+' '+data['status'],flush=True)
cli('new_record_historical_recheck',positive)
copied=out/'copied_logs_without_execution';shutil.copytree(positive,copied);(copied/'verification_results.json').unlink()
cli('copied_no_receipt',copied,['--package',str(base)],expect=2)
ledger_before=sha(copied/'execution_ledger.json')
argv=[sys.executable,str(base/'Vivado'/'execute_regression.py'),'--run',str(copied),'--package',str(base),'--attempt-id',str(uuid.uuid4())]
with (out/'reused_native_directory.console.log').open('wb') as f:p=subprocess.run(argv,stdout=f,stderr=subprocess.STDOUT)
if p.returncode==0 or (copied/'verification_results.json').exists() or sha(copied/'execution_ledger.json')!=ledger_before:raise RuntimeError('Copied native directory accepted or old ledger overwritten')
results.append(dict(case='reused_native_directory',rejected=True,old_ledger_unchanged=True))
for label,file in [('missing_csv','case_results.csv'),('missing_native_log','hazards.log')]:
    target=out/label;shutil.copytree(positive,target);(target/file).unlink();cli(label,target,expect=1)
drift=out/'input_snapshot_drift';shutil.copytree(positive,drift)
with (drift/'tb'/'tb_datapath.sv').open('a',encoding='utf-8') as f:f.write('\n// deliberately mismatched archived source\n')
cli('input_snapshot_drift',drift,expect=1)
package=out/'current_package_drift';shutil.copytree(base/'Vivado',package/'Vivado',ignore=shutil.ignore_patterns('project','综合记录','__pycache__'))
shutil.copytree(base/'程序镜像',package/'程序镜像')
with (package/'Vivado'/'tb'/'tb_datapath.sv').open('a',encoding='utf-8') as f:f.write('\n// deliberately different current source\n')
cli('current_package_mismatch',positive,['--package',str(package)],expect=1)
# A real new native Fatal must fail publication while preserving prior success.
fault=out/'fresh_fatal_package';shutil.copytree(base/'Vivado',fault/'Vivado',ignore=shutil.ignore_patterns('project','综合记录','__pycache__'));shutil.copytree(base/'程序镜像',fault/'程序镜像')
shutil.copy2(base/'验证结果.json',fault/'验证结果.json');prior=sha(fault/'验证结果.json')
p=fault/'Vivado'/'rtl'/'datapath_core.sv';s=p.read_text(encoding='utf-8');seam='wire load_use = x_valid &&'
if s.count(seam)!=1:raise RuntimeError('Fatal seam missing')
p.write_text(s.replace(seam,"wire load_use = 1'b0 && x_valid &&"),encoding='utf-8')
with (out/'fresh_fatal.console.log').open('wb') as f:proc=subprocess.run([shutil.which('pwsh'),'-NoProfile','-File',str(fault/'Vivado'/'run_verify.ps1')],stdout=f,stderr=subprocess.STDOUT)
state=json.loads((fault/'最近运行.json').read_text(encoding='utf-8-sig'));failed_run=Path(state['archived_run'])
native=(failed_run/'datapath.log').read_text(encoding='utf-8')
if proc.returncode==0 or state['status']!='failed' or sha(fault/'验证结果.json')!=prior or not re.search(r'^Fatal: Unready newest producer consumed BASELINE$',native,re.M) or (failed_run/'verification_results.json').exists():raise RuntimeError('Fatal published or historical success confused')
results.append(dict(case='fresh_fatal_and_old_success',status='failed',wrapper_exit=proc.returncode,old_success_preserved=True,failed_attempt_id=state['attempt_id'],successful_attempt_id=receipt['attempt_id'],archive=str(failed_run),fatal='Unready newest producer consumed BASELINE'))
(out/'m2_results.json').write_text(json.dumps(dict(status='PASS',verification_revision='1.6-vtools-r1',cases=len(results),results=results),ensure_ascii=False,indent=2),encoding='utf-8')
print('M2_ACCEPTANCE_PASS cases='+str(len(results)))

archive=base/'审查'/'验证工具_r1'/'证据测试'/out.name
archive.parent.mkdir(parents=True,exist_ok=True)
shutil.copytree(out,archive,ignore=shutil.ignore_patterns('xsim.dir','.Xil','__pycache__'))
print('EVIDENCE_TESTS_ARCHIVE='+str(archive))
