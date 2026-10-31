from pathlib import Path
from docx import Document
from docx.oxml.ns import qn
from pypdf import PdfReader
from PIL import Image
from lxml import etree as ET
import csv,hashlib,json,re,zipfile

WORK=Path(__file__).parent
ROOT=Path(r'D:\OneDrive - University of Glasgow\同步文件夹\大三上\Courses\数电')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def read(p):return json.loads(p.read_text(encoding='utf-8-sig'))
def need(ok,msg):
 if not ok:raise AssertionError(msg)
def norm(s):return re.sub(r'\s+','',s)
new=Document(WORK/'candidate.docx');old=Document(WORK/'source.docx')
need(len(new.tables)==32 and len(new.inline_shapes)==10,'Figures or tables lost')
need(len(new.sections)==3,'Mixed layout sections')
need([(round(s.page_width/914400,2),round(s.page_height/914400,2)) for s in new.sections]==[(8.5,11),(11,8.5),(8.5,11)],'Page orientation contract')
heads=[p for p in new.paragraphs if p.style.name.startswith('Heading')]
toc=[p for p in new.paragraphs if re.fullmatch(r'toc [123]',p.style.name,re.I)]
need(len(heads)==len(toc)==56,'Saved Word TOC cache not current')
with (WORK/'headings_pages.tsv').open(encoding='utf-8-sig',newline='') as f:hm=list(csv.DictReader(f,delimiter='\t'))
if 'position' in hm[0]:hm.sort(key=lambda r:int(r['position']))
need(len(hm)==56,'Native heading page map')
for par,row in zip(toc,hm):
 need(norm(par.text).startswith(norm(row['number']+row['heading'])) and norm(par.text).endswith(row['page']),'TOC title/page mismatch '+row['heading'])
need([(r['number'],r['page']) for r in hm if r['heading'] in ['整体控制与数据通路架构','五级数据通路详细连接']]==[('2.1.1','9'),('2.1.2','10')],'Figure heading hierarchy')
names=[b.get(qn('w:name')) for b in new._element.iter(qn('w:bookmarkStart'))]
need(len(names)==len(set(names)),'Duplicate bookmarks')
ids=[b.get(qn('w:id')) for b in new._element.iter(qn('w:bookmarkStart'))]
need(len(ids)==len(set(ids)),'Duplicate bookmark IDs')
for b in old._element.iter(qn('w:bookmarkStart')):
 name=b.get(qn('w:name'))
 if not name.startswith('_Toc'):need(name in names,'Lost semantic bookmark '+name)
refs=[]
for e in new._element.iter(qn('w:instrText')):
 m=re.search(r'\b(?:REF|PAGEREF)\s+([^\s]+)',e.text or '')
 if m:need(m[1] in names,'Broken REF '+m[1]);refs.append(m[1])
for e in new._element.iter(qn('w:hyperlink')):
 a=e.get(qn('w:anchor'))
 if a:need(a in names,'Broken hyperlink '+a)
figs=[p for p in new.paragraphs if p.style.name=='Caption' and re.match(r'图\s*\d+',p.text)]
tabs=[p for p in new.paragraphs if p.style.name=='Caption' and re.match(r'表\s*\d+',p.text)]
need([int(re.match(r'图\s*(\d+)',p.text)[1]) for p in figs]==list(range(1,11)),'Figure sequence')
need([int(re.match(r'表\s*(\d+)',p.text)[1]) for p in tabs]==list(range(1,33)),'Table sequence')
mapping={'fig_cpu_overall':1,'fig_1':2,'fig_2':3,'fig_hazard_network':4,'fig_3':5,'fig_4':6,'fig_5':7,'fig_6':8,'fig_7':9,'fig_interlock_trace':10}
for name,num in mapping.items():
 cap=next(p for p in figs if name in [b.get(qn('w:name')) for b in p._p.iter(qn('w:bookmarkStart'))])
 need(int(re.match(r'图\s*(\d+)',cap.text)[1])==num,'Semantic figure bookmark drift '+name)
for i,t in enumerate(old.tables):
 if i==13:continue
 need([[norm(c.text) for c in r.cells] for r in t.rows]==[[norm(c.text) for c in r.cells] for r in new.tables[i].rows],'Unrelated table changed '+str(i+1))
changed={x['index'] for x in read(WORK/'document_changes.json')['changes']}|{105,183}
newtext={norm(p.text) for p in new.paragraphs}
for i,p in enumerate(old.paragraphs):
 if i in changed or p.style.name.lower().startswith('toc ') or not p.text.strip():continue
 updated=re.sub(r'图([1-9]\d*)',lambda m:'图'+str(int(m[1])+1),p.text)
 need(norm(updated) in newtext,'Unrelated paragraph changed '+str(i)+' '+p.text[:60])
# Confirm eight retained non-datapath figures still have the original image bytes.
media=lambda d:[d.part.related_parts[s._inline.graphic.graphicData.pic.blipFill.blip.embed].blob for s in d.inline_shapes]
om=media(old);nm=media(new)
need(all(hashlib.sha256(b).digest() in [hashlib.sha256(x).digest() for x in nm] for b in om[1:]),'Retained figure media changed')
for n,i in [('01_CPU整体架构.png',0),('02_五级Datapath.png',1)]:need(nm[i]==(WORK/'figures'/n).read_bytes(),'Word figure differs from delivered PNG '+n)
need(len(new.tables[13].rows)==12,'Block/RTL map incomplete')
for phrase in ['实现基线 v1.6-timing-AC1','ISA v1.5','2026年10月31日','qualified_redirect','CTRL_X/M/W','m_access_fault','regfile4x16']:
 need(phrase in '\n'.join(p.text for p in new.paragraphs),'Missing contract text '+phrase)
pdf=PdfReader(WORK/'candidate.pdf');pages=len(pdf.pages)
land=[i+1 for i,p in enumerate(pdf.pages) if p.mediabox.width>p.mediabox.height]
need(land==[9,10],'Unexpected landscape or overflow page')
texts=[p.extract_text() for p in pdf.pages]
need(not re.search(r'Error!|错误[!！]|Reference source not found|未定义书签','\n'.join(texts),re.I),'Broken rendered field')
for i,t in enumerate(texts,1):need(len(t.strip())>70,'Near-empty page '+str(i))
need('图 1' in texts[8] and '图 2' in texts[9],'Captions split from figures')

sem=read(WORK/'figure_semantics.json')
for f in sem['figures']:
 svg=WORK/'figures'/f['file'];xml=ET.parse(str(svg));root=xml.getroot()
 xmlids=root.xpath('//@id');need(len(xmlids)==len(set(xmlids)),'Duplicate SVG IDs')
 need(not root.xpath('//*[local-name()="image"]'),'Raster image in editable SVG')
 need(len(root.xpath('//*[local-name()="text"]'))>20,'SVG native text lost')
 need(Image.open(svg.with_suffix('.png')).size==(3600,2250),'PNG dimensions')
 for node in f['nodes']:need(0<=node['x'] and node['x']+node['width']<=2400 and 0<=node['y'] and node['y']+node['height']<=1500,'SVG bounds')
overall=sem['figures'][0];nodes={n['id']:n for n in overall['nodes']};cu=nodes['pipeline_cu']
need(all(n['y']+n['height']<=cu['y']+cu['height'] for k,n in nodes.items() if k.startswith('ctrl_band_')),'Control band outside CU')
detail=sem['figures'][1];nets={n['id']:n for n in detail['nets']};need(nets['store_data_to_mem']['points'][-2][1]>nets['store_data_to_mem']['points'][-1][1],'STR arrow does not enter DM')
need(set(nets['x_pc_imm_to_target']['signals'])=={'x_pc','x_imm_ext'},'Target inputs absent')

before=read(WORK/'baseline_files.json')
for rel,meta in before.items():need(sha(ROOT/rel)==meta['sha256'],'Original workspace changed before publication '+rel)
visual=read(WORK/'visual_review.json')
need(visual['status']=='VISUAL_REVIEW_PASS' and visual['Word_sha256']==sha(WORK/'candidate.docx') and visual['PDF_sha256']==sha(WORK/'candidate.pdf') and visual['reviewed_pages']==list(range(1,pages+1)),'Visual review binding')
out={'status':'DOCUMENT_STRUCTURE_AND_SOURCE_REVIEW_PASS','pages':pages,'landscape_pages':land,'headings':len(heads),'toc_entries':len(toc),'tables':32,'figures':10,'preserved_tables':31,'preserved_non_datapath_figures':8,'references_checked':len(refs),'semantic_bookmarks':mapping,'RTL_TB_XDC_changed':False,'source_files_checked':len(before),'Word_sha256':sha(WORK/'candidate.docx'),'PDF_sha256':sha(WORK/'candidate.pdf'),'visual_review':'PASS all final 46 page PNGs inspected; see visual_review.json'}
(WORK/'structural_review.json').write_text(json.dumps(out,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps(out,ensure_ascii=False,indent=2))
