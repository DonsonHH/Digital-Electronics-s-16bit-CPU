"""Append evidence-bound board/performance/experiment sections to the mature core Word."""
from pathlib import Path
from io import BytesIO
import argparse,hashlib,json,subprocess
from docx import Document
from docx.oxml import OxmlElement
from docx.oxml.ns import qn
from docx.shared import Inches,Pt,RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_CELL_VERTICAL_ALIGNMENT
from verify_board_results import verify_attempt,require
B=Path(__file__).resolve().parent;P=B.parent;ROOT=P.parent
NAME='16位流水线CPU核心设计文档_AC1候选版.docx'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def read(p):return json.loads(Path(p).read_text(encoding='utf-8'))
def main():
 parser=argparse.ArgumentParser(description=__doc__)
 for name in ['baseline-matrix','forward-comparison','wb-matrix','wb-validation']:parser.add_argument('--'+name,type=Path,required=True)
 parser.add_argument('--output',type=Path,default=P/NAME);a=parser.parse_args()
 base,forward,wb,validation=[read(p) for p in [a.baseline_matrix,a.forward_comparison,a.wb_matrix,a.wb_validation]]
 require(base['status']=='FULL_BASELINE_PASS_PHYSICAL_PENDING' and len(base['rows'])==5,'Complete baseline required')
 require(forward['status']=='COMPARISON_ACCEPTED_PHYSICAL_PENDING','Forwarding experiment review missing')
 require(wb['status']=='FULL_CANDIDATE_PASS_PHYSICAL_PENDING' and wb['candidate']=='wb_mem' and len(wb['rows'])==5,'Complete WB/MEM matrix required')
 require(validation['status']=='PASS' and validation['candidate']=='wb_mem','WB/MEM mechanism validation missing')
 for matrix in [base,wb]:
  for row in matrix['rows']:
   path=P/row['attempt_relative'];require(sha(path/'result.json')==row['receipt_sha256'],'Matrix child changed');verify_attempt(path)
 wb_source=P/'实验/候选/wb_mem/datapath_core.sv'
 require(validation['candidate_rtl_sha256']==sha(wb_source),'Validated WB/MEM source differs from current candidate')
 for row in wb['rows']:require(read(P/row['attempt_relative']/'result.json')['input_sha256']['rtl/datapath_core.sv']==sha(wb_source),'Routed WB/MEM source differs')
 raw=subprocess.check_output(['git','show','5dfe09e:CPU核心设计/'+NAME],cwd=ROOT);doc=Document(BytesIO(raw));paragraphs=list(doc.paragraphs)
 paragraphs[1].text='实现 AC1板级与性能实验r2    CPU v1.6    ISA v1.5    文档修订 2026年11月1日'
 paragraphs[2].text='本文规定16位顺序单发射五级流水线CPU的ISA、数据通路、控制与验证。默认执行核心保持稳定AC1；本版完成EES-331板级时钟复位、JTAG观测与完整布局布线，固定五个性能工作负载，并独立评估前递MUX和WB到MEM候选。候选保留独立源码和周期契约，不覆盖原AC1及历史证据。'
 paragraphs[6].text='目标为课程EES-331、xc7z020clg484-1，外部100MHz接M19，S1接L18。ISA v1.5及默认AC1五级规则保持。完整实现STA、有限仿真与周期推算分别列出；课程板尚未接入，真实板测、物理按键和实测运行时间仍未验收。'
 for p in paragraphs:
  if p.text.startswith('已完成最小系统准备；下一阶段才建立'):
   p.text='已完成EES-331板级设计、同步复位、VIO观测、完整布局布线及五个固定工作负载的实现比较。实际板卡尚未接入；后续上板须确认目标、读取构建身份、结果和停止现场。当前未增加单步、暂停或可变延迟存储。'
  elif p.text.startswith('AC1限定功能接受覆盖'):
   p.text='AC1的有限功能接受覆盖合法/故障Opcode、地址保护、年轻取消、停顿/前递、WB停止边沿和同步复位。本版另有完整板级实现STA；未完成物理板测、全状态形式证明或完整算术穷举。可变延迟存储未实现，任何局部PASS均不扩大为这些范围的通过。'
 anchor=next(p for p in doc.paragraphs if p.style.name=='Heading 2' and p.text=='参考资料')
 def para(text,style='Normal',page=False):
  p=anchor.insert_paragraph_before(text,style);p.paragraph_format.page_break_before=page
  return p
 def table(headers,rows,widths,title,number):
  caption('表',number,title)
  t=doc.add_table(rows=1,cols=len(headers));t.autofit=False;t._element.getparent().remove(t._element);anchor._p.addprevious(t._element)
  for i,w in enumerate(widths):t.columns[i].width=Inches(w)
  for cell,value in zip(t.rows[0].cells,headers):cell.text=value
  for row in rows:
   for cell,value in zip(t.add_row().cells,row):cell.text=str(value)
  borders=OxmlElement('w:tblBorders')
  for name in ['top','left','bottom','right','insideH','insideV']:
   x=OxmlElement('w:'+name);x.set(qn('w:val'),'single');x.set(qn('w:sz'),'4');x.set(qn('w:color'),'D9D9D9');borders.append(x)
  t._tbl.tblPr.append(borders)
  for i,row in enumerate(t.rows):
   if i==0:row._tr.get_or_add_trPr().append(OxmlElement('w:tblHeader'))
   for j,cell in enumerate(row.cells):
    cell.width=Inches(widths[j]);cell.vertical_alignment=WD_CELL_VERTICAL_ALIGNMENT.CENTER
    shade=OxmlElement('w:shd');shade.set(qn('w:fill'),'E7EFF8' if i==0 else 'F5F7F9' if i%2==0 else 'FFFFFF');cell._tc.get_or_add_tcPr().append(shade)
    for p in cell.paragraphs:
     p.paragraph_format.space_after=Pt(3);p.paragraph_format.space_before=Pt(3);p.paragraph_format.line_spacing=1.05
     for r in p.runs:r.font.size=Pt(10);r.font.bold=i==0;r.font.color.rgb=RGBColor(0,0,0)
  para('')
 def caption(prefix,number,text):
  p=para('', 'Caption');p.paragraph_format.keep_with_next=True;p.add_run(prefix)
  f=OxmlElement('w:fldSimple');f.set(qn('w:instr'),'SEQ '+('Figure' if prefix=='图' else 'Table')+' \\* ARABIC');r=OxmlElement('w:r');x=OxmlElement('w:t');x.text=str(number);r.append(x);f.append(r);p._p.append(f);p.add_run(' '+text)
 para('EES331板级实现与性能实验','Heading 2',True)
 para('时钟复位与观测连接','Heading 3')
 para('ees331_top以BUFG分发M19的100MHz晶振，VIO与CPU应用逻辑共享时钟。S1为L18低有效输入；相关PL Bank为3.3V，LED为高电平点亮。板级仅有时钟、按键和8个LED逻辑IO。')
 p=para('');p.alignment=WD_ALIGN_PARAGRAPH.CENTER;p.add_run().add_picture(str(P/'架构图/04_EES331板级系统.png'),width=Inches(6.55));p.paragraph_format.keep_with_next=True
 caption('图',12,'EES-331板级结构。虚线内为同一application的逻辑分区；不新增CPU流水级。VIO不受CPU复位，能够在停止时读取完整现场。')
 para('复位请求先经三级同步，再寄存为有效core_reset；请求传递之前的合法写入可以完成，不能视作回滚。有效复位禁止当拍架构写入并清CPU和计数，DM保留。请求撤销后保持2^21个稳定周期（约20.97ms），再启动CPU；CPU执行时间不包含该等待。避免异步复位FF直接驱动RAM使能，原REQP-1840风险已在RTL中消除。')
 para('完整实现与时序覆盖','Heading 3')
 para('每次新建工程并显式保留programs路径；仿真与综合使用同一默认dut_im.mem/dut_dm.mem。工具版本必须确为2025.2，布局布线策略、逻辑RAM和VIO配置固定。检查setup、hold、pulse、四项厂商debug bus-skew、内部约束覆盖及十个实际IO；只有按钮到首级同步D和无同步接收器的LED使用用户false-path。')
 para('保留并按范围处理PDCN-1569和LUTAR-1（厂商debug hub）、RTSTAT-10（无负载）、ZPS7-1（仅PL/JTAG，实际启动待板测）及SYNTH-6（IM/DM固定一拍读，不另加输出流水级）。未降级DRC；新代码或影响CPU的异常范围不能自动接受。无矢量功耗估算未作为测量结果。')
 para('固定程序与性能基线','Heading 3',True)
 rows=[]
 for r in base['rows']:
  i=r['implementation'];rows.append([r['program'],f"{r['cycles']} / {r['completed']}",f"{r['stalls']} / {r['redirects']}",i['resources']['lut_total'],i['resources']['ff'],f"{i['timing']['wns_ns']:.3f} / {i['timing']['whs_ns']:.3f}"])
 table(['工作负载','周期 / N','stall / 跳转','LUT','FF','setup / hold ns'],rows,[1.35,0.8,0.9,0.6,0.65,1.25],'五个工作负载的完整实现基线',36)
 para('五个配置都使用2个BRAM18；面积采用routed utilization的Total LUTs，包含LUTRAM。每个程序的98项共同输入相同，选定镜像和独立gold数据是明确变量。程序不同可能导致常量优化及资源差异，候选比较必须使用同一程序成对评价。')
 para('复制校验程序包含35条动态指令：8次load/store复制，再读回8个目的字并累加。初值FFFF、0001、8000、7FFF、1234、A5A5、5A5A、0000，最终R1=1232，R0/R2=0，R3=32；最后store地址71、数据0且valid=1。AC1实际为55周期、16停顿，避免仅用最后一个复制字证明整段程序。')
 para('按已实现10ns时钟计算，五个程序时间为250、170、300、150、550ns。它们是执行周期推算，不是尚未进行的板上测量，也不含复位去抖、配置和JTAG等待。实际CPU时钟必须与布局布线配置和板卡时钟相符。')
 para('前递MUX组合候选','Heading 3')
 para('forward_onehot只替换operand_forward的数据MUX表达式；原if优先级和四态行为保持，M匹配load仍阻断旧W值，R0参与普通相关比较。原九套、独立48例及错误注入通过，五个程序完整公开逐拍轨迹一致。')
 table(['程序','LUT变化','setup裕量变化 ns','100MHz周期变化'],[[r['program'],r['LUT_delta'],f"{r['WNS_delta_ns']:+.3f}",0]for r in forward['rows']],[1.6,1.0,2.0,0.95],'前递MUX候选相对AC1',37)
 para(forward['recommendation'])
 para('WB到MEM存储数据候选','Heading 3',True)
 para('wb_mem在EX不消费尚未就绪的STR数据，只把必要资格与占位载荷传至MEM。优先复用m_rd表示STR数据源，增加一位m_store_pending；MEM检查当前WB是否为同名、有效、无故障、可写的load生产者，再选择已就绪wb_data。地址仍在EX使用可用Rs计算，基址相关保留一拍停顿。')
 para('EX例外必须匹配合法STR控制；未知或非法资格不能绕过blocked检查。MEM未就绪时禁止写DM并发内部故障原因5，地址越界保持原因4；较老MEM事件优先年轻EX，老WB继续完成。STR在MEM写一次，其有效标签继续WB，无RW/ZW/CVW。reset、取消和bubble均不能保留可产生副作用的pending。')
 bmap={r['program']:r for r in base['rows']}
 table(['程序','AC1周期 / stall','WB候选周期 / stall','周期推算差值 ns'],[[r['program'],f"{bmap[r['program']]['cycles']} / {bmap[r['program']]['stalls']}",f"{r['cycles']} / {r['stalls']}",(r['cycles']-bmap[r['program']]['cycles'])*10]for r in wb['rows']],[1.5,1.45,1.5,1.1],'WB到MEM候选的实际周期比较',38)
 para('该候选不要求旧时序CSV逐字节相同，而要求架构事件顺序、最终状态与候选新周期契约同时成立。故障/reset不机械套正常HALT公式：年轻STR减少停顿，不一定缩短较老fault自身排空时间。原冻结用例和历史记录保留原字节。')
 para('复跑入口与未完成事项','Heading 3')
 for text in ['python -B -X utf8 CPU核心设计/板级/run_matrix.py --candidate ac1','python -B -X utf8 CPU核心设计/板级/run_matrix.py --candidate forward_onehot','python -B -X utf8 CPU核心设计/板级/run_matrix.py --candidate wb_mem']:para(text,'Code')
 para('具体RTL、TB、模型、原始运行与review以对应实验JSON的输入指纹为准。所有已接受且未取消的指令仍按IF→ID→EX→MEM→WB组织；实验未引入FIFO/cache、单步、暂停或可变延迟存储。默认生产源码继续保持稳定AC1，候选源码隔离在实验目录。')
 para('硬件采集流程要求显式确认EES-331和完整JTAG目标；配置/CPU重启分开控制，先读构建身份，再比较两次停止快照。预期不完整的旧记录只能只读采集，不能启动运行验收。代码仅通过软件前置和仿真样本检查，当前没有真实板上功能、物理按键或直接计时测量的通过结论。')
 anchor.paragraph_format.page_break_before=True
 doc.core_properties.version='AC1-board-experiments-r2';doc.save(a.output)
 print('CORE_BOARD_DOCUMENT_UPDATED '+str(a.output))
if __name__=='__main__':main()
