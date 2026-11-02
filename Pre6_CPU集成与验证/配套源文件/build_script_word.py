"""Create the group rehearsal script from the same content used by PPT notes."""
from pathlib import Path
import argparse,json,re
from docx import Document
from docx.shared import Inches,Pt,RGBColor
from docx.oxml import OxmlElement
from docx.oxml.ns import qn
B=Path(__file__).resolve().parent
def ptext(doc,text,size=11,bold=False):
 p=doc.add_paragraph();p.paragraph_format.space_after=Pt(7)
 r=p.add_run(text);r.bold=bold;r.font.size=Pt(size);return p
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--output',type=Path,required=True);a=ap.parse_args()
 c=json.loads((B/'content.json').read_text(encoding='utf-8'));e=json.loads((B/'evidence.json').read_text(encoding='utf-8'))
 d=Document();sec=d.sections[0];sec.page_width=Inches(8.27);sec.page_height=Inches(11.69);sec.top_margin=sec.bottom_margin=Inches(.72);sec.left_margin=sec.right_margin=Inches(.78)
 for style in d.styles:
  if style.type==1:
   style.font.name='Arial';style.font.color.rgb=RGBColor(0,0,0)
   style.element.get_or_add_rPr().get_or_add_rFonts().set(qn('w:eastAsia'),'Microsoft YaHei')
 d.styles['Normal'].font.size=Pt(11);d.styles['Normal'].paragraph_format.line_spacing=1.13
 for n,size in [('Title',23),('Heading 1',17),('Heading 2',13),('Heading 3',11.5)]:
  d.styles[n].font.size=Pt(size);d.styles[n].font.bold=True
  d.styles[n].paragraph_format.keep_with_next=True
 d.add_paragraph('Pre6 CPU Integration and Verification','Title')
 ptext(d,'Group 2 English script and Q&A',14,True)
 ptext(d,'五人正式排练版  CPU v1.6  ISA v1.5  默认AC1',11)
 ptext(d,'正文12页  备用8页  讲解14分钟  交接与停顿缓冲1分钟',11)
 ptext(d,f"正文约{c['spoken_words']}个英文词。英文段落为正式讲稿；中文为理解与指图提示。页面编号与PPT一致。",11)
 ptext(d,'时间为排练预算，字数估算不能代替五人实际排练。先计时完整试讲，再在本预算内调整停顿和语速。',11)
 d.add_heading('五人分工与计时',1)
 roles={'A':('ISA与设计流程',[1,2,3]),'B':('整机与数据通路',[4,5]),'C':('控制协作与数据冒险',[6,7]),'D':('控制流与功能证据',[8,9,10]),'E':('性能分析与总结',[11,12])}
 t=d.add_table(rows=1,cols=4);t.rows[0].cells[0].text='讲者';t.rows[0].cells[1].text='负责内容';t.rows[0].cells[2].text='PPT页码';t.rows[0].cells[3].text='预算'
 for who,(name,ids)in roles.items():
  secs=sum(c['main'][i-1]['seconds']for i in ids);cells=t.add_row().cells
  for cell,v in zip(cells,[who,name,', '.join(map(str,ids)),f'{secs//60}:{secs%60:02d}']):cell.text=v
 d.add_heading('统一讲解口径',1)
 ptext(d,'ISA以当前v1.5为准；全局五状态与五级流水分开讲。STR在MEM写一次，WB保留有效标签。实板RF是写回影子，原始逐拍轨迹来自仿真。S1板测在CPU停止后进行。周期来自实板VIO，时间按100MHz设计频率换算。',10.5)
 ptext(d,'重点发音：ISA逐字母读；R0读R zero；0x1232读hexadecimal one two three two；CPI逐字母读。英文正文不读SHA256、文件路径或中文提示。',10.5)
 for who,(name,ids)in roles.items():
  d.add_page_break();d.add_heading(f'Speaker {who}  {name}',1)
  for i in ids:
   slide=c['main'][i-1];words=len(re.findall(r"[A-Za-z0-9]+(?:['.-][A-Za-z0-9]+)*",slide['speech']))
   d.add_heading(f"Slide {i}  {slide['title']}",2)
   ptext(d,f"目标{slide['seconds']}秒  英文{words}词  页面目标：{slide['goal']}",9.5)
   ptext(d,slide['speech'],11.5)
   ptext(d,'中文指图提示：'+slide['cue'],10)
   if i in [6,7,11]:ptext(d,'排练重点：先指明图中对象或时钟周期，再解释原因和结果；不要逐行念信号名。',10)
 d.add_page_break();d.add_heading('备用页答辩提示',1)
 for j,s in enumerate(c['backup'],13):
  d.add_heading(f"Slide {j}  {s['title']}",2);ptext(d,s['answer'],11);ptext(d,'中文提示：'+s['cue'],10)
 d.add_page_break();d.add_heading('常见问题英文回答',1)
 for question,answer in c['questions']:
  d.add_heading(question,2);ptext(d,answer,11)
 d.add_heading('五人排练与交付检查',1)
 for v in ['A、B、C、D、E依次试讲，交接句已写入英文正文。','先按14分钟讲解预算演练，再加入换页和交接，整组不超过15分钟。','C要能讲清C3保持/C4 bubble/C5前递/C6写DM/C7 STR WB/C8 HALT。','D要能解释本次实板采样与仿真逐拍证据的区别。','E要能现场带入C=N+4+S+2R并解释CPI，不把不同工作量总周期直接排名。','如超时，先压缩逐项枚举和备用内容，保留控制协作、典型冲突和性能推导。']:
  ptext(d,v,10.5)
 ptext(d,'设计来源：'+e['tag']+'，提交'+e['baseline_commit']+'。逐页来源和文件指纹见配套源文件/source_map.json；PPT备注也包含相同来源。',9.5)
 for table in d.tables:
  table.autofit=False
  for ri,row in enumerate(table.rows):
   for cell in row.cells:
    tc=cell._tc.get_or_add_tcPr();borders=OxmlElement('w:tcBorders')
    for side in ['top','left','bottom','right']:
     b=OxmlElement('w:'+side);b.set(qn('w:val'),'single');b.set(qn('w:sz'),'4');b.set(qn('w:color'),'D9D9D9');borders.append(b)
    tc.append(borders)
    if ri==0:
     shade=OxmlElement('w:shd');shade.set(qn('w:fill'),'E8F0F5');tc.append(shade)
    for para in cell.paragraphs:
     for run in para.runs:run.font.size=Pt(10);run.bold=ri==0
 footer=sec.footer.paragraphs[0];footer.alignment=2
 footer.add_run('Pre6 Group 2  ');field=OxmlElement('w:fldSimple');field.set(qn('w:instr'),'PAGE');footer._p.append(field)
 d.core_properties.title='Pre6 CPU Integration and Verification English Script';d.core_properties.subject='Five-speaker14-minute script with1-minute buffer and bounded evidence-based Q&A';d.core_properties.version='Pre6-r1'
 d.save(a.output);print('SCRIPT_WORD_CREATED='+str(a.output))
if __name__=='__main__':main()
