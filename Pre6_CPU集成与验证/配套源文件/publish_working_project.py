"""Publish a mutable GUI working copy beside immutable run evidence."""
from pathlib import Path
import datetime
import json
import shutil

B=Path(__file__).resolve().parents[1]/'Vivado'


def main():
    choices=[]
    for p in (B/'运行记录').glob('*/result.json'):
        r=json.loads(p.read_text(encoding='utf-8'))
        if r['status']=='PASS'and r['program']=='copy_checksum':choices.append((r['started_utc'],p,r))
    _,source,record=max(choices)
    target=B/'工程'
    if target.exists():raise ValueError('Refusing to overwrite the GUI working copy')
    shutil.copytree(source.parent,target,ignore=shutil.ignore_patterns('result.json','console.log','run.cmd','.Xil','xsim.dir','__pycache__'))
    (B/'工程来源.json').write_text(json.dumps({'source_record':source.relative_to(B).as_posix(),
             'project':'工程/project/pre6_cpu.xpr','default_simulation_program':'copy_checksum',
             'expected_cycles':55,'mutable_GUI_working_copy':True,
             'created_utc':datetime.datetime.now(datetime.timezone.utc).isoformat()},ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print('GUI_WORKING_PROJECT='+str(target/'project/pre6_cpu.xpr'))


if __name__=='__main__':main()
