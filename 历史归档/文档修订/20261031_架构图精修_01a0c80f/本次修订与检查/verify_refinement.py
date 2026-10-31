from pathlib import Path
from docx import Document
from docx.oxml.ns import qn
from pypdf import PdfReader
from lxml import etree as ET
from PIL import Image
import hashlib,json,csv,re
WORK=Path(__file__).parent
ROOT=Path(r'D:\OneDrive - University of Glasgow\同步文件夹\大三上\Courses\数电')
def read(p):return json.loads(p.read_text(encoding='utf-8-sig'))
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def need(ok,msg):
 if not ok:raise AssertionError(msg)
def norm(s):return re.sub(r'\s+','',s)
old=Document(WORK/'source.docx');new=Document(WORK/'candidate.docx')
need(len(old.tables)==len(new.tables)==32 and len(new.inline_shapes)==10,'Table/figure count')
heads=[p for p in new.paragraphs if p.style.name.startswith('Heading')]
toc=[p for p in new.paragraphs if re.fullmatch('toc [123]',p.style.name,re.I)]
need(len(heads)==len(toc)==56,'Saved Word TOC not current')
with (WORK/'headings_pages.tsv').open(encoding='utf-8-sig',newline='') as f:hm=list(csv.DictReader(f,delimiter='\t'))
hm.sort(key=lambda r:int(r['position']))
for p,r in zip(toc,hm):need(norm(p.text).startswith(norm(r['number']+r['heading'])) and norm(p.text).endswith(r['page']),'TOC mismatch '+r['heading'])
need([(r['number'],r['page']) for r in hm if r['heading'] in ['整体控制与数据通路架构','五级数据通路详细连接']]==[('2.1.1','9'),('2.1.2','10')],'Figure heading/page map')
changed={r['index'] for r in read(WORK/'document_changes.json')['changes']}
current_text={norm(p.text) for p in new.paragraphs}
for i,p in enumerate(old.paragraphs):
 if i in changed or p.style.name.lower().startswith('toc ') or not p.text.strip():continue
 need(norm(p.text) in current_text,'Unintended paragraph change '+str(i))
for i,t in enumerate(old.tables):
 for ri,row in enumerate(t.rows):
  for ci,c in enumerate(row.cells):
   if i==13 and (ri,ci) in [(7,2),(9,2)]:continue
   need(norm(c.text)==norm(new.tables[i].cell(ri,ci).text),'Unintended table cell '+str((i+1,ri,ci)))
old_bm={e.get(qn('w:name')) for e in old._element.iter(qn('w:bookmarkStart')) if not e.get(qn('w:name')).startswith('_Toc')}
names=[e.get(qn('w:name')) for e in new._element.iter(qn('w:bookmarkStart'))]
need(len(names)==len(set(names)) and old_bm.issubset(names),'Bookmark loss/duplication')
refs=[]
for i in new._element.iter(qn('w:instrText')):
 m=re.search(r'\b(?:REF|PAGEREF)\s+(\S+)',i.text or '')
 if m:need(m[1] in names,'Broken reference');refs.append(m[1])
for h in new._element.iter(qn('w:hyperlink')):
 a=h.get(qn('w:anchor'))
 if a:need(a in names,'Broken hyperlink')
captions=[p for p in new.paragraphs if p.style.name=='Caption' and re.match(r'图\s*\d+',p.text)]
need([int(re.match(r'图\s*(\d+)',p.text)[1]) for p in captions]==list(range(1,11)),'Figure sequence')
media=lambda d:[d.part.related_parts[s._inline.graphic.graphicData.pic.blipFill.blip.embed].blob for s in d.inline_shapes]
om,nm=media(old),media(new)
need(om[2:]==nm[2:],'Eight retained figures changed')
for i,n in enumerate(['01_CPU整体架构.png','02_五级Datapath.png']):need(nm[i]==(WORK/'figures'/n).read_bytes(),'Embedded PNG differs')
pdf=PdfReader(WORK/'candidate.pdf');land=[i+1 for i,p in enumerate(pdf.pages) if p.mediabox.width>p.mediabox.height]
need(land==[9,10],'Landscape overflow '+str(land))
need(len(pdf.pages)==46,'Unexpected overall pagination; review all actual pages')
txt=[p.extract_text() for p in pdf.pages]
need('图 1' in txt[8] and '图 2' in txt[9],'Figure captions separated')
need(not re.search(r'错误[!！]|Error!|未定义书签','\n'.join(txt),re.I),'Broken field rendered')
for i,t in enumerate(txt,1):need(len(t.strip())>70,'Unexpected near-empty page '+str(i))
sem=read(WORK/'figure_semantics.json');route=read(WORK/'route_review.json')
need(not route['crossings'] and not route['text_crossings'],'Wire intersection gate')
need(not route['text_overlaps'] and not route['border_text_crossings'] and not route['text_bounds'],'Text/border/bounds collision gate')
for f in sem['figures']:
 need(not f['text_fit_warnings'],'Text overflow')
 tree=ET.parse(str(WORK/'figures'/f['file']));ids=tree.xpath('//@id');need(len(ids)==len(set(ids)),'Duplicate SVG id')
 need(not tree.xpath('//*[local-name()="image"]'),'Raster embedded in editable SVG')
 need(Image.open((WORK/'figures'/f['file']).with_suffix('.png')).size==(3600,round(f['height']*1.5)),'Raster aspect/size')
 nets={n['id']:n for n in f['nets']}
 if f['file'].startswith('01'):
  need(all(s.startswith('d_') for s in nets['ctrl_to_stage_1']['signals']),'ID control source misbound')
 else:
  need('z_effective' not in nets['target_pc_imm']['signals'] and nets['z_to_request']['signals']==['z_effective'],'Branch path mixing')
  need(nets['rf_writeback']['signals']==['wb_data'] and set(nets['rf_write_control']['signals'])=={'w_rd','rf_we'},'WB control/data source mixing')
baseline=read(WORK/'baseline_files.json')
for rel,m in baseline.items():need(sha(ROOT/rel)==m['sha256'],'Original changed before publish '+rel)
visual=read(WORK/'visual_review.json');comparison=read(WORK/'page_comparison.json')
need(visual['Word_sha256']==sha(WORK/'candidate.docx') and visual['PDF_sha256']==sha(WORK/'candidate.pdf'),'Visual review hash binding')
need(comparison['changed_page_numbers']==[1,9,10,11,18] and len(comparison['identical_page_numbers'])==41,'Rendered page comparison binding')
out={'status':'REFINEMENT_REVIEW_PASS','pages':len(pdf.pages),'landscape_pages':land,'headings':56,'toc_entries':56,'tables':32,'figures':10,'retained_figures_unchanged':8,'references_checked':len(refs),'original_files_unchanged':len(baseline),'Word_sha256':sha(WORK/'candidate.docx'),'PDF_sha256':sha(WORK/'candidate.pdf'),'RTL_TB_XDC_changed':False,'new_simulation':False,'new_synthesis':False,'route_box_collisions':0,'route_text_collisions':0,'visual_review':'PASS five changed pages inspected and 41 other pages identical to the earlier fully inspected render'}
(WORK/'structural_review.json').write_text(json.dumps(out,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps(out,ensure_ascii=False,indent=2))
