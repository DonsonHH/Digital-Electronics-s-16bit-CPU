from pathlib import Path
from datetime import datetime,timezone
import hashlib,json,os,shutil,sys,tempfile

WORK=Path(__file__).parent
ROOT=Path(r'D:\OneDrive - University of Glasgow\同步文件夹\大三上\Courses\数电')
CORE=ROOT/'CPU核心设计'
BACKUP=Path(r'C:\Users\Donson\Documents\ChatGPT_CPU_归档\20261031_架构图更新_01a0c80f')
STAGE=WORK/'publication';STAGE.mkdir(exist_ok=True)
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def digest(b):return hashlib.sha256(b).hexdigest()
def read(p):return json.loads(p.read_text(encoding='utf-8-sig'))
def need(ok,msg):
 if not ok:raise AssertionError(msg)
def jbytes(obj):return (json.dumps(obj,ensure_ascii=False,indent=2)+'\n').encode('utf-8')
base=read(WORK/'baseline_files.json');review=read(WORK/'structural_review.json');visual=read(WORK/'visual_review.json');evidence=read(WORK/'evidence_review.json')
need(review['status']=='DOCUMENT_STRUCTURE_AND_SOURCE_REVIEW_PASS' and visual['status']=='VISUAL_REVIEW_PASS' and evidence['status']=='HISTORICAL_TRACE_RECHECK_PASS','Review gate')
need(review['Word_sha256']==sha(WORK/'candidate.docx') and review['PDF_sha256']==sha(WORK/'candidate.pdf'),'Reviewed bytes drift')
need(visual['Word_sha256']==review['Word_sha256'] and visual['PDF_sha256']==review['PDF_sha256'],'Visual review bound to other bytes')
need(len(visual['reviewed_pages'])==review['pages']==46,'Visual pages mismatch')

payload={'16位流水线CPU核心设计文档_AC1候选版.docx':(WORK/'candidate.docx').read_bytes()}
for f in (WORK/'figures').iterdir():
 if f.suffix in ['.svg','.png']:payload['架构图/'+f.name]=f.read_bytes()
need(len(payload)==5,'Unexpected figure payload')
readme=(CORE/'README.md').read_text(encoding='utf-8-sig')
start=readme.index('## 2026-10-29 文档修订');end=readme.index('## 创建及打开 Vivado')
revision='''## 2026-10-31 架构图修订

核心Word现为46页，保留四章结构和Word内56项可点击分级目录。第2.1.1、2.1.2节分别为整体控制与数据通路架构图、五级Datapath详细图，独占第9、10页横向图页；其余正文为纵向。两张主图与现有F/Q/G、冒险网络及五状态FSM相互对应。

可编辑源图和3600×2250 PNG位于`架构图/`：`01_CPU整体架构.svg/.png`、`02_五级Datapath.svg/.png`。第2.6节（第17–19页）的表14给出方框、实际RTL及输入输出对应；IFCU至WBCU是core内部职责分区，CTRL_X/M/W是既有随行控制字段集合。第3.7节（第29–31页）继续解释运行模式与WB排空边界；第4.4.2节（第36页）保留Pre5执行记录的原日期及覆盖口径。

本轮只修订图文，CPU实现版本、ISA、13份生产RTL、全部TB与XDC不变。加减仍采用原生17位`+`表达式，没有接入Hybrid。图中同步IM输出承担D级指令数据边界，DM输出承担W级load数据边界；没有新增IR/MDR、独立五级控制器、FIFO/cache或resume端口。

本轮按当前源码重新核对ADD相关、LDR到STR、CMP/JZ、HALT排空、MEM故障与Reset；只读重解析Pre5原始VCD的4,824个上升沿，逐项核对11份CSV/JSON。所用九套回归attempt仍为`440e0d7a-1244-4333-a4f8-5adf612f9833`，独立48例仍为`cpu_ac1_independent_glok75my`，均位于相邻`../Pre5_控制单元设计/Vivado`。这是历史证据复核，不是2026-10-31新运行XSim、综合或下板。

修改前Word、README、索引与指纹保存在`C:/Users/Donson/Documents/ChatGPT_CPU_归档/20261031_架构图更新_01a0c80f`，此前10月29日文档修订的归档继续保留。当前文档与图形摘要见`证据索引.json`，`文件SHA256.json`同步当前指纹；原有执行receipt不改写。清单中原有缺失的`验证记录/AC1已验收负向原始证据.zip`仍保留原记录，本轮未恢复该历史文件。

'''
payload['README.md']=(readme[:start]+revision+readme[end:]).encode('utf-8')
index=read(CORE/'证据索引.json')
index.setdefault('document_revision_history',[]).append(index['current_document'])
index['current_document']={**index['current_document'],'revision_date':'2026-10-31','sha256':digest(payload['16位流水线CPU核心设计文档_AC1候选版.docx']),'pages':46,'toc_entries':56,'tables':32,'figures':10,'sections_updated':['2.1.1 overall control and datapath architecture','2.1.2 detailed five-stage datapath','2.6.2 table14 block/RTL/input/output map','figure sequence, live references and TOC'],'landscape_pages':[9,10],'RTL_TB_XDC_changed':False,'new_simulation_or_synthesis':False,'backup_and_QA':str(BACKUP)}
index['architecture_figures']={'revision_date':'2026-10-31','baseline':'v1.6-timing-AC1','ISA':'v1.5','core_RTL_sha256':sha(CORE/'Vivado/rtl/datapath_core.sv'),'block_signal_map':'Word 2.6.2 table14','source_format':'native editable SVG text and vector shapes','png_pixels':[3600,2250],'files':{k:digest(v) for k,v in payload.items() if k.startswith('架构图/')},'implementation_changed':False,'historical_evidence_rechecked_on':'2026-10-31','new_xsim_execution':False,'trace_cases_checked':11,'raw_vcd_edges_reparsed':4824,'review_cases':['DOC_ADD_ADD','TRACE_LOAD_STR','T02','T07','LEGAL_STR_BEFORE_HALT','T16','T05','16 reset probes from 5 modes'],'review_scope':'Source/diagram/document consistency and saved clock-edge evidence; no new simulation, synthesis, P&R or board claim'}
payload['证据索引.json']=jbytes(index)

manifest=read(CORE/'文件SHA256.json');oldrev=manifest.get('documentation_revision',{})
oldhashes=manifest['files'];newhashes={}
for p in CORE.rglob('*'):
 if p.is_file() and p.name!='文件SHA256.json' and not p.name.startswith('~$'):
  name=p.relative_to(CORE).as_posix();newhashes[name]=digest(payload[name]) if name in payload else sha(p)
newhashes.update({k:digest(v) for k,v in payload.items()})
missing=[name for name in oldhashes if not (CORE/name).is_file()]
need(missing==['验证记录/AC1已验收负向原始证据.zip'],'Historical missing set changed')
for name in missing:newhashes[name]=oldhashes[name]
manifest['files']=dict(sorted(newhashes.items()))
manifest['scope']='Current package fingerprints after architecture-figure documentation revision; historical execution snapshots retain their original identities'
manifest['verified_at_utc']=datetime.now(timezone.utc).isoformat();manifest['previous_manifest_archive']=(BACKUP/'文件SHA256.json').as_posix()
manifest.setdefault('previous_documentation_revisions',[]).append(oldrev)
manifest['documentation_revision']={'date':'2026-10-31','CPU':'v1.6-timing-AC1','ISA':'v1.5','RTL_TB_XDC_changed':False,'edited_files':list(payload)+['文件SHA256.json'],'preexisting_missing_entries_retained':missing,'note':'Existing current files rehashed; the missing historical ZIP remains recorded and was not marked verified'}
payload['文件SHA256.json']=jbytes(manifest)
for name,b in payload.items():
 p=STAGE/name;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(b)
(WORK/'prepared_publication.json').write_bytes(jbytes({'files':{k:digest(v) for k,v in payload.items()},'historical_missing_preserved':missing,'reviewed_Word_sha256':review['Word_sha256']}))
if '--publish' not in sys.argv:
 print('PUBLICATION_PREPARED files='+str(len(payload)));raise SystemExit(0)

# Preflight against the full snapshot immediately before any original write.
for rel,meta in base.items():need(sha(ROOT/rel)==meta['sha256'],'Concurrent source change '+rel)
for name in payload:
 dest=CORE/name
 if 'CPU核心设计/'+name not in base:need(not dest.exists(),'New destination already exists '+name)
for name in ['16位流水线CPU核心设计文档_AC1候选版.docx','README.md','证据索引.json','文件SHA256.json']:
 need(sha(BACKUP/name)==base['CPU核心设计/'+name]['sha256'],'Backup mismatch '+name)

for name,b in payload.items():
 dest=CORE/name;dest.parent.mkdir(parents=True,exist_ok=True)
 fd,tmp=tempfile.mkstemp(prefix='.arch_publish_',dir=str(dest.parent))
 try:
  with os.fdopen(fd,'wb') as h:h.write(b);h.flush();os.fsync(h.fileno())
  os.replace(tmp,dest)
 finally:
  if os.path.exists(tmp):os.unlink(tmp)
 need(sha(dest)==digest(b),'Publication readback '+name)

# Independent final current-file check, preserving the pre-existing missing ZIP.
actual_missing=[]
for name,d in manifest['files'].items():
 p=CORE/name
 if not p.exists():actual_missing.append(name)
 else:need(sha(p)==d,'Published manifest mismatch '+name)
need(actual_missing==missing,'Historical missing set changed on publish')
allowed={'CPU核心设计/'+n for n in payload}
for rel,meta in base.items():
 if rel not in allowed:need(sha(ROOT/rel)==meta['sha256'],'Unexpected original change '+rel)
out={'status':'PUBLICATION_READBACK_PASS','files':{k:sha(CORE/k) for k in payload},'all_other_snapshot_files_unchanged':True,'source_snapshot_files':len(base),'RTL_TB_XDC_changed':False,'Pre5_evidence_unchanged':True,'preexisting_missing_retained':actual_missing,'backup':str(BACKUP)}
(WORK/'publication.json').write_bytes(jbytes(out))
qa=BACKUP/'本次修订与检查';qa.mkdir(exist_ok=True)
for p in WORK.iterdir():
 if p.is_file() and p.name!='source.docx':shutil.copy2(p,qa/p.name)
for name in ['figures','pages']:
 shutil.copytree(WORK/name,qa/name,dirs_exist_ok=True)
print(json.dumps(out,ensure_ascii=False,indent=2))
