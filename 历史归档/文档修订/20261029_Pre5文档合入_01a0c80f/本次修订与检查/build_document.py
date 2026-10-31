from pathlib import Path
from copy import deepcopy
from docx import Document
from docx.shared import Inches,Pt,RGBColor
from docx.oxml import OxmlElement
from docx.oxml.ns import qn
from docx.enum.table import WD_TABLE_ALIGNMENT,WD_CELL_VERTICAL_ALIGNMENT
import json,hashlib

WORK=Path(__file__).resolve().parent
ARCHIVE=Path(r'C:\Users\Donson\Documents\ChatGPT_CPU_归档\20261029_Pre5文档合入_01a0c80f')
SOURCE=ARCHIVE/'16位流水线CPU核心设计文档_AC1候选版.docx'
doc=Document(SOURCE);p=list(doc.paragraphs);old_tables=list(doc.tables)
changes=[]

def replace(index,text):
    paragraph=p[index];old=paragraph.text
    for child in list(paragraph._p):
        if child.tag not in (qn('w:pPr'),qn('w:bookmarkStart'),qn('w:bookmarkEnd')):paragraph._p.remove(child)
    paragraph.add_run(text)
    changes.append(dict(kind='paragraph',original_index=index,before=old,after=text))

def add_before(anchor,text,style='Normal'):
    paragraph=doc.add_paragraph(text,style)
    anchor._p.addprevious(paragraph._p)
    return paragraph

def heading_before(anchor,text):
    paragraph=add_before(anchor,text,'Heading 3')
    props=paragraph._p.get_or_add_pPr()
    template=p[146]._p.pPr.find(qn('w:numPr'))
    props.append(deepcopy(template))
    return paragraph

def caption_tail(index,tail):
    paragraph=p[index];last_end=None
    for child in paragraph._p:
        if child.tag==qn('w:r') and child.find('.//'+qn('w:fldChar')) is not None:
            if any(e.get(qn('w:fldCharType'))=='end' for e in child.iter(qn('w:fldChar'))):last_end=child
    if last_end is None:raise RuntimeError('Caption field absent')
    active=False
    for child in list(paragraph._p):
        if active and child.tag==qn('w:r'):paragraph._p.remove(child)
        if child is last_end:active=True
    paragraph.add_run(' '+tail)

def math_before(anchor):
    paragraph=add_before(anchor,'')
    math=OxmlElement('m:oMath')
    sup=OxmlElement('m:sSup');base=OxmlElement('m:e');power=OxmlElement('m:sup')
    def mr(parent,value):
        r=OxmlElement('m:r');t=OxmlElement('m:t');t.text=value;r.append(t);parent.append(r)
    mr(base,'Q');mr(power,'+');sup.extend([base,power]);math.append(sup);mr(math,' = F(Q, I)')
    paragraph._p.append(math);paragraph.add_run('    ')
    output=OxmlElement('m:oMath');mr(output,'O = G(Q, I)');paragraph._p.append(output)
    return paragraph

# This is a documentation revision; CPU version and ISA are deliberately fixed.
replace(0,'16位流水线CPU核心设计文档')
replace(1,'实现基线 v1.6-timing-AC1    ISA v1.5    文档修订 2026年10月29日')
replace(2,'本文规定16位、顺序单发射五级流水线CPU的指令行为、数据通路、硬连线控制和验证方法。实现基线为v1.6-timing-AC1，ISA与固定单周期同步IM/DM契约保持不变。本次文档修订合入Pre5已核对的CU逻辑模型、模式FSM输入输出及控制验证记录。')
replace(6,'当前源码位于CPU核心设计，验证协议为1.6-vtools-r1，执行包装采用job1生命周期修复。核心既有回归和Pre5同源复跑均已有有限功能通过记录；核心OOC估算为287 LUT、260 FF、WNS=+2.620ns、TNS=0。本版控制说明引用同一实现，文档修订不增加仿真、物理时序或板级验收结论。')

# Section 2.6: use the established CPU interfaces, not an unverified PPT image.
heading_before(p[167],'控制逻辑模型')
replace(167,'CU采用硬连线控制，由当前指令和流水状态共同决定本拍动作。正常RUN中，五级可同时处理不同指令；ALU为组合逻辑，IM/DM读延迟固定。图2用次态逻辑F、控制状态Q和输出逻辑G描述现有实现。')
math_before(p[168])
add_before(p[168],'F根据当前状态与输入计算下一控制状态，Q在时钟上升沿锁存，G在当前周期产生控制输出。I包括d_inst、取指故障、ALU非法标记、保存的Z与M/W比较候选、PC_fetch、MEM有效地址和rst；这些是逻辑输入集合，不是新增外部端口。')
add_before(p[168],'Q包含mode、各级valid/fault、X/M/W随行控制和寄存器标签；操作数、立即数、地址和结果数值由数据通路保存。G产生操作数及前递选择、PC/IM控制、DM访问资格、RF与标志写入资格，以及halted/fault。F和G可共享组合判定，逻辑划分不要求复制硬件。')
caption_tail(169,'硬连线CU的F/Q/G逻辑模型。Q反馈至F，当前输入同时参与F和G；图中方框表示现有控制职责。')
heading_before(p[170],'内部功能与信号归属')
old_tables[13].cell(2,0).text='操作数前递与Z来源选择'
old_tables[13].cell(2,2).text='operand_forward选择两路fwd/sel/blocked；core独立选择z_effective/z_fwd_sel'
replace(172,'d_/x_/m_/w_分别绑定ID/EX/MEM/WB。操作数前递由operand_forward完成，Z候选选择、load-use检测、事件仲裁和mode更新位于datapath_core.sv内部；WB→ID旁路位于regfile4x16。M的寄存故障资格用于前递，新的MEM访问故障进入年龄仲裁和写入保护，保持AC1的组合路径边界。')
heading_before(p[173],'本拍控制与时钟边沿')
add_before(p[173],'周期内先译码与判断资格，在结束上升沿更新相应流水载荷及架构状态。D级译码只形成意图；RW/ZW/CVW在有效、无故障的W槽才获准写RF或标志，MR/MW在完整地址合法的M槽才获准访问DM。mode的RUN/DRAIN允许合格老指令继续，最终停止态关闭新访问与写入。具体使能表达式与年龄优先级见3.5节。')
add_before(p[173],'PC由唯一的pc16状态寄存器保存。JUMP目标为ZExt(imm8)，JZ目标为low16(x_pc+1+SExt(imm8))，二者在EX由branch_target16生成；WB不再增加PC。完整CU的输出还依赖当前输入，不能由halted/fault的状态型输出推断整个CU都是纯Moore逻辑。')

# Section 3.7: the supervisor is a projection of Q, not the instruction pipeline.
heading_before(p[251],'运行模式与事件定义')
add_before(p[251],'模式FSM只展开控制状态Q中的mode字段。其五个合法编码为RUN=000、DRAIN_HALT=001、DRAIN_FAULT=010、HALTED=011、FAULTED=100。正常推进、load-use保持和分支取消均可发生在RUN内；它们不构成全局串行的取指至写回状态循环。')
add_before(p[251],'输入事件采用已获资格的内部判定：E=m_fault_event||x_fault_event，H=qualified_halt，D=drain_done。E包含有效MEM/EX故障；H已经排除复位、自身故障及更老MEM故障；D表示WB有效停止标记在本边沿被消费后，所有valid_next均为0。rst为同步高有效复位，优先于其他转移。')
caption_tail(252,'运行模式状态转移图。圆内O=(halted,fault)为当前状态输出；箭头标转移条件。所有状态在clk上升沿更新，rst优先。')
heading_before(p[253],'状态转移与当前输出')
add_before(p[253],'halted=(mode==HALTED)，fault=(mode==FAULTED)，这两个输出满足Moore定义。表24输出列为边沿前的当前值；进入目标状态后再按新mode解释输出。RUN不保证im_en恒为1，取指仍受互锁、事件与地址资格控制。')
caption_tail(253,'CU运行模式的完整转移与输出。除复位行外均取rst=0。')

table=doc.add_table(rows=1,cols=5);table.alignment=WD_TABLE_ALIGNMENT.CENTER;table.autofit=False
table.style=old_tables[23].style
rows=[
 ['当前mode','输入条件','下一mode','当前O','边沿动作与结果'],
 ['任意状态','rst=1','RUN','依当前态','清PC/RF/标志/valid，禁本拍写入；已写DM保留'],
 ['RUN 000','E=1','DRAIN_FAULT','0,0','禁止故障副作用，按年龄取消年轻槽'],
 ['RUN 000','E=0,H=1','DRAIN_HALT','0,0','停取指；老合格指令与停止标记继续'],
 ['RUN 000','E=0,H=0','RUN','0,0','正常推进、互锁或分支取消'],
 ['DRAIN_HALT 001','D=0','DRAIN_HALT','0,0','老合格指令与HALT标记继续'],
 ['DRAIN_HALT 001','D=1','HALTED','0,0','消费WB标记；边沿后O=1,0'],
 ['DRAIN_FAULT 010','D=0','DRAIN_FAULT','0,0','老合格指令与故障标记继续'],
 ['DRAIN_FAULT 010','D=1','FAULTED','0,0','消费WB标记；边沿后O=0,1'],
 ['HALTED 011','任意E/H/D','HALTED','1,0','保持停止，禁止访问与写入'],
 ['FAULTED 100','任意E/H/D','FAULTED','0,1','保持停止，禁止访问与写入'],
 ['101/110/111','任意E/H/D','FAULTED','0,0','非法模式禁访问/写入；本沿转故障停止']]
widths=[1.20,1.03,1.18,.57,2.72]
for i,row in enumerate(rows):
    cells=table.rows[0].cells if i==0 else table.add_row().cells
    for j,value in enumerate(row):
        cells[j].text=value;cells[j].width=Inches(widths[j]);cells[j].vertical_alignment=WD_CELL_VERTICAL_ALIGNMENT.CENTER
        tcPr=cells[j]._tc.get_or_add_tcPr();margins=OxmlElement('w:tcMar')
        for side in ('top','left','bottom','right'):
            el=OxmlElement('w:'+side);el.set(qn('w:w'),'70');el.set(qn('w:type'),'dxa');margins.append(el)
        tcPr.append(margins)
        shading=OxmlElement('w:shd');shading.set(qn('w:fill'),'17384D' if i==0 else 'F1F5F8' if i%2==0 else 'FFFFFF');tcPr.append(shading)
        for paragraph in cells[j].paragraphs:
            paragraph.paragraph_format.space_before=Pt(0);paragraph.paragraph_format.space_after=Pt(0)
            paragraph.paragraph_format.keep_with_next=False
            for run in paragraph.runs:
                run.font.name='Arial';run._r.get_or_add_rPr().rFonts.set(qn('w:eastAsia'),'微软雅黑')
                run.font.size=Pt(9);run.font.color.rgb=RGBColor.from_string('FFFFFF' if i==0 else '000000');run.bold=(i==0)
    trPr=table.rows[i]._tr.get_or_add_trPr();trPr.append(OxmlElement('w:cantSplit'))
    if i==0:trPr.append(OxmlElement('w:tblHeader'))
tblPr=table._tbl.tblPr;borders=OxmlElement('w:tblBorders')
for side in ('top','left','bottom','right','insideH','insideV'):
    el=OxmlElement('w:'+side);el.set(qn('w:val'),'single');el.set(qn('w:sz'),'4');el.set(qn('w:color'),'D9D9D9');borders.append(el)
tblPr.append(borders)
for col,width in zip(table.columns,widths):col.width=Inches(width)
old_tables[23]._tbl.addprevious(table._tbl);old_tables[23]._tbl.getparent().remove(old_tables[23]._tbl)

heading_before(p[255],'排空完成与复位返回')
add_before(p[255],'HALT/故障被接受时，E/H事件只启动排空，halted/fault仍为0。有效停止标记到WB且D=1的结束边沿，才分别进入HALTED或FAULTED。停止态在rst=0时保持，只有同步复位返回RUN；当前接口没有start/resume。若把当前输出重复写在状态转移边上，DRAIN到停止态的边仍标0,0，边沿后才变为1,0或0,1。')
add_before(p[255],'T07的实际记录：C4末接受EX中的HALT并取消年轻STR；C5末较老LDR仍可写R1=1234；C6末在WB消费HALT后才halted=1。T16中较老LDR的EA=0100，C4即阻断DM访问并取消年轻HALT，C5末消费故障标记后fault=1。两例独立起算周期；较老WB可写回指的是MEM故障检测当拍，T05另提供该同拍见证。')

# Keep historical execution identities and add the Pre5 evidence alongside them.
replace(266,'AC1实现入口为课程目录CPU核心设计/Vivado，保留13份RTL、9个TB入口及2份共享.svh。core集成流水控制、前递、保护和停止，sync_memories.v提供固定单周期同步封装。Pre5的CU结构与FSM说明对应这些既有逻辑；其13份生产RTL和全部TB与本核心包一致。')
heading_before(p[337],'核心既有验证记录')
heading_before(p[346],'Pre5控制验证记录')
add_before(p[346],'Pre5工程于2026年10月17日完成同源九套回归，attempt为440e0d7a-1244-4333-a4f8-5adf612f9833，绑定19次原生工具调用；记录保存在课程目录Pre5_控制单元设计/Vivado/验证记录下。覆盖65,536个二进制指令字、128个主回归程序与16次复位、2,550个冒险案例，以及131,072个前递控制组合（4个数据哨兵）。这些计数与核心既有覆盖口径一致。')
add_before(p[346],'同工程独立记录cpu_ac1_independent_glok75my包含48个案例、10次复位后重启见证和952行逐拍记录。结果CSV的58行包括复位重启后的第二轮，案例数仍为48。control_traces保存BASELINE、T01至T05、T07、T16、T17a、T18b及TRACE_LOAD_STR共11份逐边沿记录；pre_为边沿前值，post_为同时间戳更新稳定后的值。')
add_before(p[346],'2026年10月29日合入前，已按当前输入重新核验上述历史日志及指纹，重新解析两份原始VCD的4,824个上升沿，并核对全部11份CSV/JSON与关键FSM、复位和写入资格。该步骤是历史证据复核，没有产生新的XSim、综合或下板运行；现有功能通过范围仍是有限输入与程序集合。核心包和Pre5包的执行日期、入口及结果分别保留。')
replace(353,p[353].text.replace('job1最新记录','核心包内job1记录').replace('最新记录为','核心包内记录为'))
replace(394,'Pre5已完成控制结构、典型指令、运行模式FSM与有限验证的说明及复核，实现仍保持AC1。后续FPGA集成应在独立副本中固定真实板、顶层、时钟复位、程序装载与同步RAM，再绑定布局布线、DRC和setup/hold证据。控制协议或存储延迟若发生变化，须先修订相应契约并重新验证。')
replace(404,'课程方法依据包括CHA Lec 01-B的ISA到数据通路/CU流程、CHA Lec07-Sequential circuits analysis and design的F/Q/G及状态转移方法，以及第7次课.zip中的Lec18 RISC CPU Design-CU design。加减器、HDL、Testbench、性能与ISA/数据通路内容继续参考课程对应资料及《数字系统设计》第二版第4章、第7至8章。课程串行实验FSM用于理解方法，本CPU采用本文规定的五级并行、有效位与模式状态机。')

# Replace only the two already numbered figures, keeping all other images,
# bookmarks, captions and cross-reference field identities.
for shape_index,name,height in ((1,'cu_fqg',620/1600*6.7),(6,'mode_fsm',700/1600*6.7)):
    shape=doc.inline_shapes[shape_index]
    blip=shape._inline.graphic.graphicData.pic.blipFill.blip
    part=doc.part.related_parts[blip.embed]
    if part.content_type!='image/png':raise RuntimeError('Expected an existing PNG figure')
    part._blob=(WORK/(name+'.png')).read_bytes()
    shape.width=Inches(6.7);shape.height=Inches(height)
    shape._inline.docPr.set('descr','CU F/Q/G逻辑模型' if name=='cu_fqg' else 'CU五种运行模式、输入条件和Moore输出')

# Retain the document's heading numbering and style, with black headings.
for name in ('Title','Heading 1','Heading 2','Heading 3'):
    style=doc.styles[name];style.font.color.rgb=RGBColor(0,0,0);style.font.underline=False
for name in ('toc 1','toc 2','toc 3'):
    style=doc.styles[name]
    style.font.size=Pt(11)
    style.paragraph_format.space_before=Pt(0)
    style.paragraph_format.space_after=Pt(2)
    style.paragraph_format.line_spacing=Pt(16)
for paragraph in doc.paragraphs:
    if paragraph.style.name=='Title' or paragraph.style.name.startswith('Heading'):
        for run in paragraph.runs:run.font.color.rgb=RGBColor(0,0,0)
    if paragraph.style.name=='Normal' and paragraph._p.find('.//'+qn('w:drawing')) is not None:
        paragraph.paragraph_format.keep_with_next=True
settings=doc.settings._element
update=settings.find(qn('w:updateFields'))
if update is None:update=OxmlElement('w:updateFields');settings.append(update)
update.set(qn('w:val'),'true')
doc.core_properties.title='16位流水线CPU核心设计文档'
doc.core_properties.subject='AC1实现与ISA v1.5；Pre5控制说明文档修订2026-10-29'
doc.core_properties.comments='Documentation revision only; production RTL, ISA and pipeline timing unchanged.'
output=WORK/'candidate.docx';doc.save(output)
(WORK/'document_changes.json').write_text(json.dumps(dict(output=str(output),changes=changes,figures_replaced=[2,7],table_replaced=24,
    ISA_changed=False,production_RTL_changed=False,new_native_simulation=False),ensure_ascii=False,indent=2),encoding='utf-8')
print('DOCX_DRAFT_SAVED '+str(output)+' paragraphs='+str(len(doc.paragraphs))+' figures='+str(len(doc.inline_shapes))+' tables='+str(len(doc.tables)))
