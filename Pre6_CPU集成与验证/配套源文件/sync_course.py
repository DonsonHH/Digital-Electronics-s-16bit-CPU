"""Copy current course deliverables without deleting local historical files."""
from pathlib import Path
import argparse
import datetime
import hashlib
import json
import shutil
import subprocess

REPO=Path(__file__).resolve().parents[2]
COURSE=Path(r'D:/OneDrive - University of Glasgow/同步文件夹/大三上/Courses/数电')


def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--group',choices=['core','pre6','all'],default='all')
    a=p.parse_args()
    assert COURSE.is_dir() and REPO.name=='Digital-Electronics-s-16bit-CPU'
    files=[]
    if a.group in ['core','all']:
        raw=subprocess.check_output(['git','ls-files','-z','--','CPU核心设计'],cwd=REPO)
        files.extend(REPO/n.decode('utf-8')for n in raw.split(b'\0')if n)
        if (REPO/'CPU核心设计/tools.local.json').is_file():files.append(REPO/'CPU核心设计/tools.local.json')
    if a.group in ['pre6','all']:
        files.extend(p for p in (REPO/'Pre6_CPU集成与验证').rglob('*')if p.is_file()
                     and '__pycache__'not in p.parts and not p.name.startswith('~$')
                     and not p.is_relative_to(REPO/'Pre6_CPU集成与验证/Vivado/工程'))
    backup=Path(r'C:/Users/Donson/Documents/ChatGPT_CPU_归档')/('Pre6同步前_'+datetime.datetime.now().strftime('%Y%m%d_%H%M%S_%f'))
    changed=[];same=0;copied_bytes=0
    for src in files:
        rel=src.relative_to(REPO);dst=COURSE/rel
        assert dst.resolve().is_relative_to(COURSE.resolve())
        digest=sha(src)
        if dst.is_file()and sha(dst)==digest:
            same+=1;continue
        if dst.exists():
            if not dst.is_file():raise ValueError('Destination is not a regular file: '+str(dst))
            saved=backup/rel;saved.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(dst,saved)
        # Source/material sync never imports archive directory modes or GUI run state.
        dst.parent.mkdir(parents=True,exist_ok=True);dst.write_bytes(src.read_bytes())
        if sha(dst)!=digest:raise RuntimeError('Copy hash mismatch: '+str(dst))
        changed.append(rel.as_posix());copied_bytes+=src.stat().st_size
    summary={'group':a.group,'source':str(REPO),'destination':str(COURSE),'checked':len(files),
             'copied':len(changed),'unchanged':same,'copied_bytes':copied_bytes,'overwritten_backup':str(backup),
             'deleted_files':0,'all_copied_hashes_verified':True}
    backup.mkdir(parents=True,exist_ok=True)
    (backup/'sync.json').write_text(json.dumps({**summary,'changed':changed},ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print(json.dumps(summary,ensure_ascii=False))


if __name__=='__main__':main()
