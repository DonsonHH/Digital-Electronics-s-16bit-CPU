from pathlib import Path
from docx import Document
from docx.shared import Inches,Pt
from docx.oxml import OxmlElement
from docx.oxml.ns import qn
import json
WORK=Path(__file__).parent
doc=Document(WORK/'source.docx');p=list(doc.paragraphs);changes=[]
def replace(i,text):
 par=p[i];changes.append(dict(index=i,before=par.text,after=text))
 for ch in list(par._p):
  if ch.tag not in [qn('w:pPr'),qn('w:bookmarkStart'),qn('w:bookmarkEnd')]:par._p.remove(ch)
 par.add_run(text)
def caption(i,text):
 par=p[i];changes.append(dict(index=i,before=par.text,after='same SEQ/bookmark; '+text))
 end=None
 for ch in par._p:
  if ch.tag==qn('w:r') and any(x.get(qn('w:fldCharType'))=='end' for x in ch.iter(qn('w:fldChar'))):end=ch
 assert end is not None
 active=False
 for ch in list(par._p):
  if active and ch.tag==qn('w:r'):par._p.remove(ch)
  if ch is end:active=True
 par.add_run(' '+text)
 for r in par.runs:r.font.size=Pt(9.5)
 par.paragraph_format.space_before=Pt(0);par.paragraph_format.space_after=Pt(3);par.paragraph_format.line_spacing=1.0
def image_at(i,name):
 par=p[i]
 for ch in list(par._p):
  if ch.tag!=qn('w:pPr'):par._p.remove(ch)
 par.add_run().add_picture(str(WORK/'figures'/name),width=Inches(9.2))
 par.paragraph_format.space_before=Pt(0);par.paragraph_format.space_after=Pt(3);par.paragraph_format.line_spacing=1.0;par.paragraph_format.keep_with_next=True
def live_figure_refs(par):
 text=par.text
 for ch in list(par._p):
  if ch.tag not in [qn('w:pPr'),qn('w:bookmarkStart'),qn('w:bookmarkEnd')]:par._p.remove(ch)
 # The two leading figure references are semantic REF fields, as before.
 for token,target in [('图1','fig_cpu_overall'),('图2','fig_1')]:
  before,sep,text=text.partition(token)
  if not sep:raise AssertionError('Expected figure reference')
  par.add_run(before)
  for typ in ['begin','instruction','separate','value','end']:
   r=par.add_run()
   if typ=='instruction':e=OxmlElement('w:instrText');e.text=' REF '+target+' \\h ';e.set(qn('xml:space'),'preserve');r._r.append(e)
   elif typ=='value':r.text=token
   else:e=OxmlElement('w:fldChar');e.set(qn('w:fldCharType'),typ);r._r.append(e)
 par.add_run(text)

replace(2,'本文规定16位、顺序单发射五级流水线CPU的指令行为、数据通路、硬连线控制和验证方法。实现基线为v1.6-timing-AC1，ISA与固定单周期同步IM/DM契约保持不变。本次精修整体控制及五级数据通路主图，明确随行控制输入、实际前递与写回连线，以及目标计算和分支判定的独立职责。')
image_at(107,'01_CPU整体架构.png');image_at(110,'02_五级Datapath.png')
caption(108,'整体控制与数据通路架构。随行控制先输入各级控制逻辑，再与运行模式、有效资格及跨级仲裁共同产生使能。浅蓝边界同时关联数据、标签与控制；IFCU至WBCU为现有职责划分，对应见表14。')
caption(111,'五级Datapath详细连接。目标计算与分支判定分开；M/W前递、RF写回及Z反馈均标出源端。浅蓝带为既有流水边界，完整字段见表15；同步存储输出承担相应数据边界。')
replace(113,'图1展示控制意图经各级逻辑形成合格使能的过程；图2按实际连线追踪数据。相邻ADD→ADD相关由M非load结果前递到EX，最终仍在WB写RF；LDR→STR相关保持前端一拍，再从W前递，STR由Rd提供写数据、Rs加立即数形成地址；CMP→JZ由最近合格比较候选提供Z，Z只参与分支条件，取分支才取消年轻槽，u_target独立计算目标。rd_fwd/rs_fwd的默认源是ID/EX保存值；WB数据与RF写地址/使能分别返回，RF内部完成同址读旁路。')
live_figure_refs(p[113])
# Keep eleven mapping rows and the mature table layout; update only the two
# descriptions clarified by the new drawing.
doc.tables[13].cell(7,2).text='rd_fwd/rs_fwd各16；M非load > W的wb_data > ID/EX保存值；最近M load阻断旧W'
doc.tables[13].cell(9,2).text='z_effective送branch_req；M>W>保存Z，候选0覆盖旧1；不参与目标地址计算'
# Existing table cell style must survive replacing its text.
for row in [7,9]:
 for par in doc.tables[13].cell(row,2).paragraphs:
  par.paragraph_format.space_after=Pt(1);par.paragraph_format.line_spacing=1.0
  for r in par.runs:r.font.size=Pt(9)
if doc.settings.element.find(qn('w:doNotAutoCompressPictures')) is None:doc.settings.element.append(OxmlElement('w:doNotAutoCompressPictures'))
for sec in doc.sections:
 if sec.page_width>sec.page_height:
  sec.top_margin=Inches(.5);sec.bottom_margin=Inches(.5)
doc.save(WORK/'candidate.docx')
(WORK/'document_changes.json').write_text(json.dumps({'scope':'five requested diagram clarifications only; RTL/ISA/timing unchanged','changes':changes,'table_cells_changed':[[14,7,2],[14,9,2]],'figures_replaced':[1,2]},ensure_ascii=False,indent=2),encoding='utf-8')
print('WORD_REFINED',len(doc.tables),len(doc.inline_shapes),len(doc.sections))
