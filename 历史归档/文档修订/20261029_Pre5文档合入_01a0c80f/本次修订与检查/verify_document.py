"""Check the documentation revision without changing the CPU or old evidence."""
from pathlib import Path
from docx import Document
from docx.oxml.ns import qn
from pypdf import PdfReader
import csv,json,hashlib,re

WORK=Path(__file__).resolve().parent
BASE=Path(r'D:\OneDrive - University of Glasgow\同步文件夹\大三上\Courses\数电\CPU核心设计')
PRE5=BASE.parent/'Pre5_控制单元设计'
ARCHIVE=Path(r'C:\Users\Donson\Documents\ChatGPT_CPU_归档\20261029_Pre5文档合入_01a0c80f')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def read(p):return json.loads(p.read_text(encoding='utf-8-sig'))
def require(ok,why):
    if not ok:raise RuntimeError(why)

candidate=WORK/'candidate.docx';current=Document(candidate);original=Document(ARCHIVE/candidate.name.replace('candidate.docx','16位流水线CPU核心设计文档_AC1候选版.docx'))
before=read(WORK/'before.json');edits=read(WORK/'document_changes.json')
require(len(current.tables)==32 and len(current.inline_shapes)==9,'Unexpected table/figure loss')
require(len(current.sections)==1 and current.sections[0].page_width==original.sections[0].page_width,'Page section contract changed')
required_text=('控制逻辑模型','内部功能与信号归属','本拍控制与时钟边沿','运行模式与事件定义','状态转移与当前输出','排空完成与复位返回','Pre5控制验证记录')
alltext='\n'.join(p.text for p in current.paragraphs)
for phrase in required_text:require(phrase in alltext,'Missing integrated topic: '+phrase)
require('不启动Pre5' not in alltext,'Pre5 status remains stale')
require('实现基线 v1.6-timing-AC1' in alltext and 'ISA v1.5' in alltext,'Implementation/ISA identity changed')
require(len(list(current._element.iter(qn('m:oMath'))))>=2,'F/Q/G native equations absent')
toc=[p for p in current.paragraphs if p.style.name.lower() in ('toc 1','toc 2','toc 3')]
headings=[p for p in current.paragraphs if p.style.name.startswith('Heading')]
require(len(toc)==len(headings)==54,'TOC does not match all heading levels')
with (WORK/'headings_pages.tsv').open(encoding='utf-8-sig',newline='') as f:page_map=list(csv.DictReader(f,delimiter='\t'))
require(len(page_map)==54,'Native Word heading page map absent')
for toc_p,item in zip(toc,page_map):
    normalized=re.sub(r'\s+','',toc_p.text)
    expected=re.sub(r'\s+','',item['number']+' '+item['heading'])
    require(normalized.startswith(expected) and normalized.endswith(item['page']),'TOC heading/page differs: '+item['heading'])
names=[n.get(qn('w:name')) for n in current._element.iter(qn('w:bookmarkStart'))]
require(len(names)==len(set(names)),'Duplicate bookmark names')
for e in current._element.iter(qn('w:hyperlink')):
    anchor=e.get(qn('w:anchor'))
    if anchor:require(anchor in names,'Broken hyperlink: '+anchor)
for instruction in current._element.iter(qn('w:instrText')):
    m=re.search(r'\b(?:REF|PAGEREF)\s+([^\s]+)',instruction.text or '')
    if m:require(m[1] in names,'Broken field reference: '+m[1])
for e in original._element.iter(qn('w:bookmarkStart')):
    name=e.get(qn('w:name'))
    if not name.startswith('_Toc'):require(name in names,'Original figure/table bookmark lost: '+name)

# Rewriting the TOC and three figure captions is intentional. Other old body
# paragraphs and 30 entire tables must retain their mature specification text.
changed={c['original_index'] for c in edits['changes']}|{169,252,253}
current_paras=[p.text for p in current.paragraphs]
for i,p in enumerate(original.paragraphs):
    if i in changed or p.style.name.lower().startswith('toc ') or not p.text.strip():continue
    require(p.text in current_paras,'Unexpected old paragraph removal: '+str(i)+' '+p.text[:55])
for i,t in enumerate(original.tables):
    if i in (13,23):continue
    require([[c.text for c in row.cells] for row in t.rows]==[[c.text for c in row.cells] for row in current.tables[i].rows],'Unrelated table changed: '+str(i+1))
table=current.tables[23]
require(len(table.rows)==12 and len(table.columns)==5,'Full FSM transition/output table absent')
require(table.cell(1,1).text=='rst=1' and table.cell(11,0).text=='101/110/111','Reset/illegal state coverage absent')
expected_rows=[('RUN 000','E=1','DRAIN_FAULT','0,0'),('RUN 000','E=0,H=1','DRAIN_HALT','0,0'),
               ('RUN 000','E=0,H=0','RUN','0,0'),('DRAIN_HALT 001','D=0','DRAIN_HALT','0,0'),
               ('DRAIN_HALT 001','D=1','HALTED','0,0'),('DRAIN_FAULT 010','D=0','DRAIN_FAULT','0,0'),
               ('DRAIN_FAULT 010','D=1','FAULTED','0,0'),('HALTED 011','任意E/H/D','HALTED','1,0'),
               ('FAULTED 100','任意E/H/D','FAULTED','0,1')]
for row,expected in zip(table.rows[2:11],expected_rows):require(tuple(c.text for c in row.cells[:4])==expected,'FSM state/output mismatch')
source=(BASE/'Vivado/rtl/datapath_core.sv').read_text(encoding='utf-8')
for name,n in [('RUN',0),('DRAIN_HALT',1),('DRAIN_FAULT',2),('HALTED',3),('FAULTED',4)]:
    require(re.search(name+r'\s*=\s*3\x27d'+str(n),source),'RTL mode encoding differs')
require('mode_next = FAULTED' in source and 'wire w_stop_token = w_valid && (w_halt || w_fault);' in source,'RTL stop contract differs')

pdf=PdfReader(WORK/'candidate.pdf');require(len(pdf.pages)==44,'Rendered page count changed; review actual output again')
pdftext='\n'.join(p.extract_text() for p in pdf.pages)
require(not re.search(r'Error!|错误!|错误！|Reference source not found|未定义书签',pdftext,re.I),'Broken Word field rendered')
for n,page in enumerate(pdf.pages,1):require(len(page.extract_text().strip())>80,'Unexpected near-blank page: '+str(n))
for name,h in before['core_files'].items():require(sha(BASE/name)==h,'Original core changed before publish: '+name)
for name,h in before['pre5_files'].items():require(sha(PRE5/name)==h,'Pre5/history changed: '+name)
result=dict(status='DOCUMENT_REVIEW_PASS',document_pages=44,toc_entries=54,tables=32,figures=9,
            fsm_table_rows=11,original_nonrevised_tables_preserved=30,ISA_changed=False,RTL_TB_XDC_changed=False,
            other_core_files_unchanged=True,Pre5_files_unchanged=True,new_native_simulation=False,
            candidate_sha256=sha(candidate),rendered_pdf_sha256=sha(WORK/'candidate.pdf'),
            backup=str(ARCHIVE),visual_review='Required separately on all 44 final page images')
(WORK/'structural_review.json').write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps(result,ensure_ascii=False,indent=2))
