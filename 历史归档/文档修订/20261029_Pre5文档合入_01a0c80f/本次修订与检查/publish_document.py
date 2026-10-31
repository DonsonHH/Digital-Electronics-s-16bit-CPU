"""Publish the verified Pre5 documentation revision with recoverable originals.

Only the existing core Word, README, evidence index and package manifest change.
No production source, test, constraint, simulation record or Pre5 artifact changes.
"""
from pathlib import Path
from datetime import datetime,timezone
import hashlib,json,os,shutil,uuid

WORK=Path(__file__).resolve().parent
BASE=Path(r'D:\OneDrive - University of Glasgow\同步文件夹\大三上\Courses\数电\CPU核心设计')
PRE5=BASE.parent/'Pre5_控制单元设计'
BACKUP=Path(r'C:\Users\Donson\Documents\ChatGPT_CPU_归档\20261029_Pre5文档合入_01a0c80f')
WORD='16位流水线CPU核心设计文档_AC1候选版.docx'
ALLOWED=(WORD,'README.md','证据索引.json','文件SHA256.json')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def read(p):return json.loads(p.read_text(encoding='utf-8-sig'))
def write(p,value):p.write_text(json.dumps(value,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
def require(ok,message):
    if not ok:raise RuntimeError(message)

before=read(WORK/'before.json');review=read(WORK/'structural_review.json')
require(review['status']=='DOCUMENT_REVIEW_PASS' and review['document_pages']==44 and review['toc_entries']==54,'Document structural review incomplete')
require(sha(WORK/'candidate.docx')==review['candidate_sha256'] and sha(WORK/'candidate.pdf')==review['rendered_pdf_sha256'],'Document changed since reviewed render')
pages=sorted((WORK/'pages_final').glob('page-*.png'))
require(len(pages)==44,'Final raster review set is incomplete')
for name,digest in before['core_files'].items():require(sha(BASE/name)==digest,'Original core changed before publish: '+name)
for name,digest in before['pre5_files'].items():require(sha(PRE5/name)==digest,'Pre5 changed before publish: '+name)
for name in ALLOWED:require(sha(BACKUP/name)==before['core_files'][name],'Original backup differs: '+name)

qa=BACKUP/'本次修订与检查';require(not qa.exists(),'Never overwrite the existing publication attempt')
qa.mkdir()
for name in ('candidate.pdf','document_changes.json','structural_review.json','headings_pages.tsv','build_document.py',
             'verify_document.py','publish_document.py','render_word.vbs','cu_fqg.svg','mode_fsm.svg'):
    shutil.copy2(WORK/name,qa/name)
write(qa/'visual_review.json',dict(status='ALL_PAGES_REVIEWED',pages=44,render_engine='Microsoft Word',
      png_sha256={p.name:sha(p) for p in pages},pdf_sha256=sha(WORK/'candidate.pdf'),
      scope='Full final page images reviewed for clipping, overlap, headings, tables, equations, captions and pagination'))

index=read(BACKUP/'证据索引.json')
# Retain all older dated reviews and execution identities; add this revision.
index['current_document']={'relative':WORD,'revision_date':'2026-10-29','CPU':'v1.6-timing-AC1','ISA':'v1.5',
    'sha256':sha(WORK/'candidate.docx'),'pages':44,'toc_entries':54,'tables':32,'figures':9,
    'sections_updated':['2.6 CU F/Q/G and signal ownership','3.7 mode FSM input/output and drain boundary','4.4.2 Pre5 source-bound evidence'],
    'RTL_TB_XDC_changed':False,'new_simulation_or_synthesis':False,'backup_and_QA':str(BACKUP)}
index['Pre5_control_evidence']={
    'relative_to_course_root':'Pre5_控制单元设计/Vivado','CPU_RTL_TB_identical':True,
    'original_execution_date':'2026-10-17','regression_attempt':'440e0d7a-1244-4333-a4f8-5adf612f9833',
    'regression_relative':'验证记录/cpu_v16_440e0d7a12444333a4f85adf612f9833',
    'independent_relative':'验证记录/cpu_ac1_independent_glok75my','trace_relative':'control_traces',
    'historical_rechecked_on':'2026-10-29','new_xsim_execution_on_document_revision':False,
    'scope':'Historical input-bound functional/control results only; no new timing or board acceptance',
    'nine_suites':9,'native_steps':19,'independent_cases':48,'reset_rerun_witnesses':10,
    'independent_result_rows':58,'independent_cycle_rows':952,'trace_cases':11,'original_VCD_rising_edges_reparsed':4824}
write(WORK/'证据索引.json',index)

old_manifest=read(BACKUP/'文件SHA256.json')
missing=[n for n in old_manifest['files'] if not (BASE/n).is_file()]
manifest=old_manifest.copy();manifest['files']=dict(old_manifest['files'])
manifest['scope']='Current package fingerprints after Pre5 documentation integration; unchanged historical execution snapshots retain their original identities'
manifest['verified_at_utc']=datetime.now(timezone.utc).isoformat()
manifest['previous_manifest_archive']=(BACKUP/'文件SHA256.json').as_posix()
manifest['documentation_revision']={'date':'2026-10-29','CPU':'v1.6-timing-AC1','ISA':'v1.5','RTL_TB_XDC_changed':False,
   'edited_files':list(ALLOWED),'preexisting_missing_entries_retained':missing,
   'note':'No missing historical item was deleted from the manifest or marked as newly verified'}
for name,source in ((WORD,WORK/'candidate.docx'),('README.md',WORK/'README.md'),('证据索引.json',WORK/'证据索引.json')):
    manifest['files'][name]=sha(source)
write(WORK/'文件SHA256.json',manifest)

sources={WORD:WORK/'candidate.docx',**{n:WORK/n for n in ALLOWED[1:]}}
published=[];staging={};publication_id=uuid.uuid4().hex
try:
    for name,source in sources.items():
        staged=BASE/('.pre5_doc_'+publication_id+'_'+source.name)
        require(not staged.exists(),'Staging collision')
        shutil.copy2(source,staged);require(sha(staged)==sha(source),'Staging copy differs')
        staging[name]=staged
    for name in ALLOWED:
        require(sha(BASE/name)==before['core_files'][name],'Concurrent user save detected: '+name)
        os.replace(staging[name],BASE/name);published.append(name)
        require(sha(BASE/name)==sha(sources[name]),'Published bytes differ: '+name)
except BaseException:
    # Roll back only bytes written by this invocation; never replace an
    # intervening user save. Original and staged files remain recoverable.
    for name in reversed(published):
        if sha(BASE/name)==sha(sources[name]):shutil.copy2(BACKUP/name,BASE/name)
    raise
finally:
    # Remove only this operation's uniquely named, verified staging files.
    for name,staged in staging.items():
        if staged.is_file() and sha(staged)==sha(sources[name]):staged.unlink()

after={p.relative_to(BASE).as_posix():sha(p) for p in BASE.rglob('*') if p.is_file()}
require(set(after)==set(before['core_files']),'Unexpected core file added/deleted')
changed={n for n,h in after.items() if h!=before['core_files'][n]}
require(changed==set(ALLOWED),'Non-document files changed: '+str(changed))
for name,digest in before['pre5_files'].items():require(sha(PRE5/name)==digest,'Pre5 artifact changed')
current=read(BASE/'文件SHA256.json')
require([n for n in current['files'] if not (BASE/n).is_file()]==missing,'Historical missing-item state changed')
for name,h in current['files'].items():
    if (BASE/name).is_file():require(sha(BASE/name)==h,'Published package manifest mismatch: '+name)
require(read(BASE/'证据索引.json')['current_document']['sha256']==sha(BASE/WORD),'Document index hash differs')
result=dict(status='DOCUMENT_PUBLISHED_AND_VERIFIED',changed_files=sorted(changed),new_files=[],removed_files=[],
       pages=44,toc_entries=54,tables=32,figures=9,unchanged_pre5_files=len(before['pre5_files']),
       new_native_simulation=False,core_document_sha256=sha(BASE/WORD),backup=str(BACKUP),
       preexisting_missing_historical_entries=missing)
write(qa/'publication.json',result)
print(json.dumps(result,ensure_ascii=False,indent=2))
