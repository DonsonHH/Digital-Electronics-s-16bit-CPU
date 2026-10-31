from pathlib import Path
from copy import deepcopy
from docx import Document
from docx.shared import Inches,Pt,RGBColor
from docx.oxml import OxmlElement
from docx.oxml.ns import qn
from docx.enum.text import WD_ALIGN_PARAGRAPH,WD_LINE_SPACING
from docx.enum.table import WD_TABLE_ALIGNMENT,WD_CELL_VERTICAL_ALIGNMENT
import json,re

WORK=Path(__file__).parent
doc=Document(WORK/'source.docx');p=list(doc.paragraphs)
changes=[]
def replace(index,text):
 par=p[index];old=par.text
 for ch in list(par._p):
  if ch.tag not in [qn('w:pPr'),qn('w:bookmarkStart'),qn('w:bookmarkEnd')]:par._p.remove(ch)
 par.add_run(text);changes.append({'index':index,'before':old,'after':text})
def before(anchor,text='',style='Normal'):
 par=doc.add_paragraph(text,style);anchor._p.addprevious(par._p);return par
def compact(par,pt=10):
 par.paragraph_format.space_before=Pt(0);par.paragraph_format.space_after=Pt(3)
 par.paragraph_format.line_spacing=1.0
 for r in par.runs:r.font.size=Pt(pt)
def heading3(anchor,title):
 par=before(anchor,title,'Heading 3')
 numbering=p[123]._p.pPr.find(qn('w:numPr'))
 if numbering is not None:par._p.get_or_add_pPr().append(deepcopy(numbering))
 compact(par,12);par.paragraph_format.keep_with_next=True
 return par
def tail(par,text):
 end=None
 for ch in par._p:
  if ch.tag==qn('w:r') and any(x.get(qn('w:fldCharType'))=='end' for x in ch.iter(qn('w:fldChar'))):end=ch
 assert end is not None
 active=False
 for ch in list(par._p):
  if active and ch.tag==qn('w:r'):par._p.remove(ch)
  if ch is end:active=True
 par.add_run(' '+text)
def add_picture(par,name):
 for ch in list(par._p):
  if ch.tag!=qn('w:pPr'):par._p.remove(ch)
 par.add_run().add_picture(str(WORK/'figures'/name),width=Inches(9.3))
 par.alignment=WD_ALIGN_PARAGRAPH.CENTER;compact(par)
 par.paragraph_format.keep_with_next=True
def section_on(par,sect):
 props=par._p.get_or_add_pPr()
 old=props.find(qn('w:sectPr'))
 if old is not None:props.remove(old)
 props.append(deepcopy(sect))
def live_refs(par,targets):
 text=par.text
 for ch in list(par._p):
  if ch.tag not in [qn('w:pPr'),qn('w:bookmarkStart'),qn('w:bookmarkEnd')]:par._p.remove(ch)
 regex=re.compile('|'.join(re.escape(x) for x in targets));pos=0
 for m in regex.finditer(text):
  par.add_run(text[pos:m.start()])
  begin=OxmlElement('w:fldChar');begin.set(qn('w:fldCharType'),'begin');par.add_run()._r.append(begin)
  instr=OxmlElement('w:instrText');instr.set(qn('xml:space'),'preserve');instr.text=' REF '+targets[m[0]]+' \\h ';par.add_run()._r.append(instr)
  sep=OxmlElement('w:fldChar');sep.set(qn('w:fldCharType'),'separate');par.add_run()._r.append(sep)
  par.add_run(m[0]);end=OxmlElement('w:fldChar');end.set(qn('w:fldCharType'),'end');par.add_run()._r.append(end)
  pos=m.end()
 par.add_run(text[pos:])

# Increment literal figure mentions across run boundaries. Preserve formatting
# and leave SEQ/REF cached results to Word (a numeric run need not be a field).
literal_ref_updates=[]
for par in doc._element.iter(qn('w:p')):
 segments=[];parts=[];offset=0;depth=0
 for e in par.iter():
  if e.tag==qn('w:fldChar'):
   typ=e.get(qn('w:fldCharType'))
   if typ=='begin':depth+=1
   elif typ=='end':depth=max(0,depth-1)
  elif e.tag==qn('w:t'):
   txt=e.text or '';segments.append((offset,offset+len(txt),e,depth>0));parts.append(txt);offset+=len(txt)
 whole=''.join(parts)
 for m in reversed(list(re.finditer(r'图\s*([1-9]\d*)',whole))):
  start,end=m.span(1);hits=[z for z in segments if z[0]<end and z[1]>start]
  if not hits or any(z[3] for z in hits):continue
  number=str(int(m[1])+1)
  for j,(a,b,e,inside) in enumerate(hits):
   lo=max(start-a,0);hi=min(end-a,b-a)
   e.text=(e.text or '')[:lo]+(number if j==0 else '')+(e.text or '')[hi:]
  literal_ref_updates.append({'before':m[0],'after':'图'+number,'paragraph':whole[:100]})

replace(1,'实现基线 v1.6-timing-AC1    ISA v1.5    文档修订 2026年10月31日')
replace(2,'本文规定16位、顺序单发射五级流水线CPU的指令行为、数据通路、硬连线控制和验证方法。实现基线为v1.6-timing-AC1，ISA与固定单周期同步IM/DM契约保持不变。本次补全整体控制架构与五级数据通路主图，保留已核对的CU逻辑模型、模式FSM及控制验证记录。')

# The preceding section remains portrait. Only the two figure pages are landscape.
portrait=deepcopy(doc.sections[0]._sectPr)
def set_nextpage(sect):
 t=sect.find(qn('w:type'))
 if t is None:t=OxmlElement('w:type');sect.insert(0,t)
 t.set(qn('w:val'),'nextPage')
 return sect
set_nextpage(portrait)
landscape=deepcopy(portrait)
for ref in list(landscape):
 if ref.tag in [qn('w:footerReference'),qn('w:headerReference')]:landscape.remove(ref)
sz=landscape.find(qn('w:pgSz'));sz.set(qn('w:w'),'15840');sz.set(qn('w:h'),'12240');sz.set(qn('w:orient'),'landscape')
marg=landscape.find(qn('w:pgMar'))
for k,v in {'top':'936','bottom':'936','left':'1080','right':'1080'}.items():marg.set(qn('w:'+k),v)
section_on(p[102],portrait)
compact(p[103],14);p[103].paragraph_format.keep_with_next=True

h1=heading3(p[104],'整体控制与数据通路架构')
fig1=before(p[104]);add_picture(fig1,'01_CPU整体架构.png')
# Reuse the established SEQ field pattern, but keep the original fig_1 bookmark
# exclusively attached to the detailed datapath. Bookmark names are semantic.
newcap=deepcopy(p[105]._p)
from docx.text.paragraph import Paragraph
p[104]._p.addprevious(newcap);cap1=Paragraph(newcap,p[104]._parent)
newid=str(max(int(b.get(qn('w:id'))) for b in doc._element.iter(qn('w:bookmarkStart')))+1)
for b in cap1._p.iter(qn('w:bookmarkStart')):b.set(qn('w:name'),'fig_cpu_overall');b.set(qn('w:id'),newid)
for b in cap1._p.iter(qn('w:bookmarkEnd')):b.set(qn('w:id'),newid)
tail(cap1,'整体控制与数据通路架构。上层负责运行模式、本条指令动作及跨级协调，下层为对应数据通路。IFCU至WBCU是现有控制职责分区，实体与信号对应见表14；CTRL为同一流水边界内的随行控制。')
compact(cap1,9.5);cap1.paragraph_format.keep_with_next=False

h2=heading3(p[104],'五级数据通路详细连接')
h2.paragraph_format.page_break_before=True
add_picture(p[104],'02_五级Datapath.png')
tail(p[105],'五级Datapath详细连接。M/W/Z/R为同网连接标记；结果16位与eq/C/V三位合计19位。四个虚线边界不新增寄存器；I为扩展立即数，完整载荷见表15；无点交叉不连接。')
compact(p[105],9.5);p[105].paragraph_format.keep_with_next=False

# Close the landscape section immediately after its caption, then return to
# portrait for all ordinary explanatory text (including the rest of section2.1).
land_end=before(p[106]);compact(land_end,1)
land_end.paragraph_format.line_spacing_rule=WD_LINE_SPACING.EXACTLY
land_end.paragraph_format.line_spacing=Pt(1);land_end.paragraph_format.space_after=Pt(0)
section_on(land_end,landscape)
replace(106,'图1用于辨认控制职责，图2用于追踪数据。IF把PC_fetch送往IM；ID译码、读RF并扩展立即数；EX先分别转发真实Rd/Rs，再经MUX送入ALU，并选择最新Z及形成分支目标；MEM按完整EA访问DM；WB选择结果写RF，并按资格写Z/C/V。图中同字母标记连接同一信号组：M为非load的m_exec_value，W为wb_data（RF旁路另带w_rd/rf_we），Z为M/W比较候选及保存Z，R为qualified_redirect与branch_target。')
replace(107,'ALU结果与有效地址共用exec_value，因为一条指令不会同时需要二者；STR独立保存已前递Rd为store_data，Rs用于基址。IM寄存输出就是D级指令数据，DM寄存输出就是W级加载数据；不再串接IR/MDR。load_use只保持PC/ID并向EX插入bubble，后端继续。分支在EX重定向但自身继续到WB；STR在MEM仅写一次，WB有效而不写入。HALT/fault标记排空至WB，Reset取消在途载荷并禁止当拍写入。')

# Replace the existing interface table (table14), rather than adding a report.
rows=json.loads((WORK/'block_signal_map.json').read_text(encoding='utf-8'))['rows']
old=doc.tables[13]
t=doc.add_table(rows=1,cols=3);t.style=old.style;t.alignment=WD_TABLE_ALIGNMENT.CENTER;t.autofit=False
head=['图中方框与实际实现','输入与反馈','输出与动作']
shortimpl={'core内部状态与组合逻辑':'core内部状态与组合逻辑','core内部组合逻辑＋pc16 u_pc':'core组合逻辑＋pc16','isa_decode u_decode＋core资格逻辑':'isa_decode＋core资格','core内部组合逻辑':'core组合逻辑','operand_forward u_forward':'operand_forward','regfile4x16 u_rf 内部组合逻辑':'regfile4x16内部旁路','core内寄存器＋外部同步RAM输出':'core寄存器＋外部同步RAM输出'}
data=[head]+[[r['block']+'\n'+shortimpl[r['implementation']],r['inputs'],r['outputs']] for r in rows]
widths=[1.65,2.5,2.8]
for i,row in enumerate(data):
 cells=t.rows[0].cells if i==0 else t.add_row().cells
 for j,txt in enumerate(row):
  cell=cells[j];cell.text=txt;cell.width=Inches(widths[j]);cell.vertical_alignment=WD_CELL_VERTICAL_ALIGNMENT.CENTER
  tc=cell._tc.get_or_add_tcPr();sh=OxmlElement('w:shd');sh.set(qn('w:fill'),'193B57' if i==0 else ('F1F5F8' if i%2 else 'FFFFFF'));tc.append(sh)
  mar=OxmlElement('w:tcMar')
  for side in ['top','left','bottom','right']:
   e=OxmlElement('w:'+side);e.set(qn('w:w'),'65');e.set(qn('w:type'),'dxa');mar.append(e)
  tc.append(mar)
  for par in cell.paragraphs:
   compact(par,9);par.paragraph_format.space_after=Pt(1);par.paragraph_format.keep_with_next=False
   for r in par.runs:r.font.color.rgb=RGBColor.from_string('FFFFFF' if i==0 else '000000');r.bold=(i==0)
 tr=t.rows[i]._tr.get_or_add_trPr();tr.append(OxmlElement('w:cantSplit'))
 if i==0:tr.append(OxmlElement('w:tblHeader'))
for col,w in zip(t.columns,widths):col.width=Inches(w)
borders=OxmlElement('w:tblBorders')
for name in ['top','left','bottom','right','insideH','insideV']:
 e=OxmlElement('w:'+name)
 for k,v in {'val':'single','sz':'4','color':'D9D9D9'}.items():e.set(qn('w:'+k),v)
 borders.append(e)
t._tbl.tblPr.append(borders)
old._tbl.addprevious(t._tbl);old._tbl.getparent().remove(old._tbl)
tail(p[183],'图中方框与RTL输入输出对应。core指datapath_core.sv内部逻辑，IFCU至WBCU不表示新增五个独立控制器。')
replace(185,'d_/x_/m_/w_分别绑定ID/EX/MEM/WB。d_ctrl及CTRL_X/M/W是表12、13、15中既有控制字段的图示集合，不是新增总线或寄存器；上层控制带与下层数据共用四个流水边界。图1的FB为反馈组，UPD为valid_next/取消/保持组。操作数前递由operand_forward完成，WB→ID旁路位于regfile4x16，Z来源选择、load-use检测、年龄仲裁和mode更新均位于core内部。M寄存m_fault用于前递，新m_access_fault只进入访问保护、故障载荷及年龄取消，不接回前递数据MUX。')
live_refs(p[106],{'图1':'fig_cpu_overall','图2':'fig_1'})
live_refs(p[185],{'图1':'fig_cpu_overall'})

# Keep sections linked to the original footer, and continue page numbering.
for sec in doc.sections:
 pn=sec._sectPr.find(qn('w:pgNumType'))
 if pn is not None:pn.attrib.pop(qn('w:start'),None)
doc.settings.element.append(OxmlElement('w:updateFields'))
doc.settings.element[-1].set(qn('w:val'),'true')
if doc.settings.element.find(qn('w:doNotAutoCompressPictures')) is None:doc.settings.element.append(OxmlElement('w:doNotAutoCompressPictures'))
doc.save(WORK/'candidate.docx')
(WORK/'document_changes.json').write_text(json.dumps({'date':'2026-10-31','scope':'two architecture figures, section2.1/table14 and necessary figure references; no RTL change','changes':changes,'literal_figure_references_updated':literal_ref_updates,'new_bookmark':'fig_cpu_overall','original_datapath_bookmark':'fig_1'},ensure_ascii=False,indent=2),encoding='utf-8')
print('WORD_BUILT',len(doc.tables),'tables',len(doc.inline_shapes),'figures',len(doc.sections),'sections')
