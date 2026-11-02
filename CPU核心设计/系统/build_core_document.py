"""Apply the reviewed system-preparation increment to the pinned mature core Word."""
from pathlib import Path
from io import BytesIO
import argparse
import copy
import hashlib
import json
import re
import subprocess
import sys
from docx import Document
from docx.oxml import OxmlElement
from docx.oxml.ns import qn
from docx.enum.table import WD_CELL_VERTICAL_ALIGNMENT
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.shared import Inches, Pt, RGBColor

ROOT = Path(__file__).resolve().parents[2]
PACKAGE = ROOT / 'CPU核心设计'
NAME = '16位流水线CPU核心设计文档_AC1候选版.docx'
sys.path.insert(0,str(PACKAGE/'文档源'))
from document_guard import ensure_legacy_output


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def bound_receipts(system_path, tools_path):
    """Author only from explicitly selected, complete, current-source evidence."""
    system_path, tools_path = system_path.resolve(), tools_path.resolve()
    system = json.loads(system_path.read_text(encoding='utf-8'))
    tools = json.loads(tools_path.read_text(encoding='utf-8'))
    if system['status']!='PASS' or system.get('test')!='all':
        raise ValueError('System receipt must be an explicit full-scope PASS')
    required=['regression','independent','mutations','unknown','evidence','lifecycle']
    if tools['status']!='PASS' or tools.get('suites')!=required:
        raise ValueError('Tool receipt must be an explicit full six-suite PASS')
    if len(tools['steps'])!=6 or any(s['suite']!=n or s['exit']!=0 for s,n in zip(tools['steps'],required)):
        raise ValueError('Incomplete native tool suite steps')
    labels=['compile','elab_memory','memory','elab_system','system','synthesis','compile_mapped','elab_mapped','mapped','project']
    if [s['label'] for s in system['steps']]!=labels:
        raise ValueError('Incomplete system native step sequence')
    # Reconstruct the runners' actual current copy/glob inventories. Matching
    # only receipt-declared entries would overlook a newly added source file.
    inventory={}
    for group in ['rtl','tb','programs','constraints']:
        for file in (PACKAGE/'系统'/group).rglob('*'):
            if file.is_file():inventory[file.relative_to(PACKAGE/'系统').as_posix()]=file
    for file in (PACKAGE/'Vivado/rtl').iterdir():
        if file.is_file():inventory['rtl/'+file.name]=file
    for name in ['synth_system.tcl','create_project.tcl','run_system.py','generate_programs.py']:
        inventory[name]=PACKAGE/'系统'/name
    inventory['desktop_launch.py']=PACKAGE/'Vivado/desktop_launch.py'
    if set(system['input_sha256'])!=set(inventory):
        raise ValueError('System execution inventory differs from current source')
    tool_inventory={file.relative_to(PACKAGE/'Vivado').as_posix() for file in (PACKAGE/'Vivado').rglob('*')
        if file.is_file() and (file.suffix in ['.py','.ps1','.cmd'] or (file.parent.name=='verification' and file.suffix in ['.md','.json']))
        and not any(part in file.parts for part in ['project','__pycache__','时序记录','创建记录'])}
    if set(tools['source_sha256'])!=tool_inventory:
        raise ValueError('Tool execution inventory differs from current source')
    for name,digest in system['input_sha256'].items():
        rel=Path(name)
        source=inventory[name]
        if sha(source)!=digest or sha(system_path.parent/rel)!=digest:
            raise ValueError('Stale system input: '+name)
    for name,digest in tools['source_sha256'].items():
        if sha(PACKAGE/'Vivado'/name)!=digest:raise ValueError('Stale tool input: '+name)
    for step in tools['steps']:
        if sha(tools_path.parent/(step['suite']+'.console.log'))!=step['log_sha256']:
            raise ValueError('Tool console hash differs')
    for step in system['steps']:
        if step['exit']!=0 or sha(system_path.parent/(step['label']+'.console.log'))!=step['console_sha256']:
            raise ValueError('System native step is incomplete or changed')
    regression_log=(tools_path.parent/'regression.console.log').read_text(encoding='utf-8')
    archive=re.findall(r'^V16_VERIFIED_RESULTS=(.+)$',regression_log,re.M)
    if len(archive)!=1:raise ValueError('Bound regression archive missing')
    regression_path=PACKAGE/'验证记录'/Path(archive[0].strip()).name/'verification_results.json'
    regression=json.loads(regression_path.read_text(encoding='utf-8-sig'))
    if regression['status']!='PASS' or not regression['new_xsim_execution'] or regression['execution_binding']['native_subprocesses']!=19:
        raise ValueError('Regression receipt is not a fresh completed nine-suite run')
    for group in ['rtl','tb']:
        if set(regression[group+'_sha256'])!={p.name for p in (PACKAGE/'Vivado'/group).iterdir() if p.is_file()}:
            raise ValueError('Regression source inventory differs: '+group)
        for name,digest in regression[group+'_sha256'].items():
            if sha(PACKAGE/'Vivado'/group/name)!=digest:raise ValueError('Stale regression '+group+': '+name)
    return system_path,system,tools_path,tools


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--baseline', default='775350246d3806c9a09ac683edadf1a35e3e68bb')
    parser.add_argument('--system-receipt',type=Path,required=True)
    parser.add_argument('--tools-receipt',type=Path,required=True)
    parser.add_argument('--output',type=Path,default=PACKAGE/NAME)
    args = parser.parse_args()
    system_path,system,tools_path,tools=bound_receipts(args.system_receipt,args.tools_receipt)
    raw = subprocess.check_output(['git', 'show', args.baseline + ':CPU核心设计/' + NAME], cwd=ROOT)
    doc = Document(BytesIO(raw))
    original = list(doc.paragraphs)
    synthesis = system['synthesis']
    edits = {
        1:'实现 AC1系统准备r1    CPU v1.6    ISA v1.5    文档修订 2026年10月31日',
        2:'本文规定16位顺序单发射五级流水线CPU的指令行为、数据通路、硬连线控制与验证方法。本版在AC1执行路径之外增加文件初始化同步IM/DM、最小系统顶层及稳定停止和结果观测，保持ISA v1.5与原周期契约。开发入口为Git工作副本；Pre4与旧验证记录保留原身份。',
        6:'当前实现为AC1系统准备r1，目标课程EES-331、xc7z020clg484-1。原执行控制与算术路径不变，datapath_core追加只读观测和随行停止原因；sync_memories增加INIT_FILE，系统另有cpu_system。已重新执行有限功能回归、文件启动系统仿真、系统OOC综合和一例网表回放，结果见第四章系统集成记录；尚未布局布线或下板。',
        119:'表7列出原12项执行接口，合计87位；本版追加的只读观测接口另见第2.10节及系统集成表，不计入此87位。逻辑端口不等于FPGA外部引脚；cpu_system把执行接口接至片上IM/DM，无需无协议转换职责的Adapter。',
        197:'数据、控制、pc和valid属于同一条指令。下面列的是逻辑字段；同步RAM输出承担相应数据边界，不增加IR/MDR。本版X/M/W各增加3位reason诊断字段，随同一有效标签推进；它不反馈控制，也不改变原指令行为。',
        293:'非法mode的RTL默认分支进入FAULTED，不得自行回到RUN重新取指；mode_active同时阻断非法状态下的访问及写入。原九套回归检查可达状态、停止边沿和复位。本版系统另以受控仿真注入非法二进制mode，检查原因6及无指令PC的现场；不表示一般硬件容错。状态寄存器用非阻塞赋值，next-state及输出组合逻辑完整覆盖。',
        297:'当前开发入口为Git工作副本CPU核心设计。Vivado/rtl保留13个核心源码文件，Vivado/tb保留9个TB入口和2份共享.svh；系统/rtl另有cpu_system.sv。core仍集成原流水控制、前递、保护和停止，追加公开观测；sync_memories提供文件初始化同步存储。Pre5原包仍是观测扩展前快照，不再声称其13份RTL与当前文件逐字节相同。',
        298:'AC1相对冻结v1.6的原组合优化及72d99981、eae32d52等记录保留为历史。本轮仅在datapath_core追加观测输出、X/M/W原因字段和停止锁存，在sync_memories追加INIT_FILE及映射属性；其余11个核心RTL与基线7753502相同。原9套TB不改；独立48例的私有运行副本仅把原.*连接替换为12个执行端口的显式连接，断言与冻结镜像不变，并分别记录包内与执行后TB指纹。',
        299:'当前维护入口为Vivado/verify.py与系统/run_system.py，使用统一工具配置；每次执行保留新的attempt、源码镜像和原始日志。新失败不替换成旧PASS。verify_results.py的历史再校验不代表新运行XSim；当前回归、系统仿真、综合和工程启动各有实际执行记录。',
        300:'python -B -X utf8 .\\CPU核心设计\\Vivado\\verify.py --suite all',
        301:'python -B -X utf8 .\\CPU核心设计\\系统\\run_system.py --test all',
        425:'本轮文件启动baseline再次得到17周期、10个有效动态指令、1次load-use和1次taken分支；all_ops得到25周期、16条动态指令、1次停顿和2次重定向，综合网表回放相同。基准计数含填充、排空、有效STR与HALT，排除复位准备；不把OOC估算直接换算为已实现时钟。',
        429:'ISA、位宽、同步存储边沿、原前递/停顿/取消和架构副作用时刻保持。阶段0固定7753502基线与历史指纹；阶段1提取独立用例和统一工具；阶段2完成文件启动、停止观测及系统仿真/综合。工程位于独立分支，不覆盖Pre4、v1.5或旧v1.6证据。',
        430:'已完成最小系统准备；下一阶段才建立EES-331板级时钟复位、实际IO与启动配置，执行布局布线和setup/hold检查。当前不加入WB到MEM免停、单步、暂停、可变存储延迟或新ISA。',
        432:'观测扩展前AC1的历史core-only OOC结果为287 LUT、260 FF、15 CARRY4，器件xc7z020clg484-1、10 ns、top=datapath_core。这不是本轮含IM/DM和调试影子的系统资源；旧报告保持原输入快照和结论。',
        433:'历史AC1 core-only WNS=+2.620 ns；冻结v1.6的WNS=-1.580 ns等记录仍保留。本轮cpu_system的实际OOC结果及范围另列于系统集成记录。不同顶层、观测资源和存储配置不能直接当作等条件加法器性能比较；所有估算均未经布局布线。',
        437:'证据索引.json分别保留历史来源和本轮新执行。源码变化必须重跑受影响验证并绑定新指纹；只有历史校验不能生成fresh XSim结论。系统run_system.py的PASS表示所选有限检查完成，timing_closed、placed_and_routed、board_validated仍为false。',
    }
    for number, text in edits.items():
        original[number].text = text
    for text_node in original[117]._p.xpath('.//w:t'):
        if text_node.text=='核心外部接口':text_node.text='核心执行接口'
    for row in doc.tables[14].rows[2:]:
        row.cells[2].text += '；reason3仅诊断'

    def paragraph(anchor, text, style='Normal', page=False):
        p = anchor.insert_paragraph_before(text, style)
        if page:p.paragraph_format.page_break_before=True
        return p

    # Extend chapter 2 without disturbing the mature figure/table numbering.
    chapter3 = original[211]
    paragraph(chapter3, '文件启动与结果观测', 'Heading 2')
    paragraph(chapter3, 'cpu_system将13份核心RTL与一个系统顶层连接。IM_INIT_FILE和DM_INIT_FILE指向完整256×16字镜像；初始化仅在配置或仿真启动时发生。读请求一拍更新、禁用保持、DM写周期保持dout，reset禁止当拍写入但保留已提交DM。完整EA在核心检查后才截为物理8位地址。')
    paragraph(chapter3, '追加接口分为合格WB事件、实际stall/redirect、流水有效位、架构标志和稳定停止现场。WB有效标签包含STR/分支/HALT及故障token，不能等同RF写回或合法退休。系统由合格写回维护RF影子，由合格MEM写入保存最后store；两者不反馈执行。停止原因和公开接口见第四章系统集成部分。')

    anchor = original[438]
    paragraph(anchor, '系统集成与本轮验证', 'Heading 2', page=True)
    paragraph(anchor, '文件初始化与系统连接', 'Heading 3')
    paragraph(anchor, 'cpu_system为本轮仿真和综合的同一顶层。默认all_ops镜像覆盖14个合法Opcode，错误路径的store和非法指令必须取消。系统TB仅通过文件启动，不层次写入IM。')
    image = paragraph(anchor, '')
    image.alignment=WD_ALIGN_PARAGRAPH.CENTER
    shape=image.add_run().add_picture(str(PACKAGE/'架构图/03_文件启动系统与停止观测.png'),width=Inches(6.55))
    shape._inline.docPr.set('descr','cpu_system连接单拍同步IM和DM；只读观测不反馈执行，稳定停止在原WB排空边沿锁存。')
    image.paragraph_format.keep_with_next=True
    paragraph(anchor, '图11 文件启动系统与停止观测。IM/DM输出继续承担原D/W数据边界；框图不新增流水级。观测区域包含core的停止锁存，以及系统顶层中的RF写回影子、最后store记录。', 'Caption')
    paragraph(anchor, 'INIT_FILE只接受预先准备的256行四位十六进制文件。runner在启动工具前检查文件清单、哈希、字数与格式；更换镜像后重新生成独立工程和新attempt，不能沿用旧成功。系统同步高有效rst不是板上异步按键的直接接法，板级同步尚待实现。')

    def table(headers, rows, widths, caption):
        paragraph(anchor, caption, 'Caption').paragraph_format.keep_with_next=True
        t=doc.add_table(rows=1,cols=len(headers))
        t.autofit=False
        t._element.getparent().remove(t._element);anchor._p.addprevious(t._element)
        for i,w in enumerate(widths):t.columns[i].width=Inches(w)
        for i, value in enumerate(headers):t.rows[0].cells[i].text=value
        for data in rows:
            for cell,value in zip(t.add_row().cells,data):cell.text=str(value)
        borders=OxmlElement('w:tblBorders')
        for name in ['top','left','bottom','right','insideH','insideV']:
            edge=OxmlElement('w:'+name);edge.set(qn('w:val'),'single');edge.set(qn('w:sz'),'4');edge.set(qn('w:color'),'D9D9D9');borders.append(edge)
        t._tbl.tblPr.append(borders)
        for row_number,row in enumerate(t.rows):
            properties=row._tr.get_or_add_trPr()
            if row_number==0:properties.append(OxmlElement('w:tblHeader'))
            for column,cell in enumerate(row.cells):
                cell.width=Inches(widths[column]);cell.vertical_alignment=WD_CELL_VERTICAL_ALIGNMENT.CENTER
                shade=OxmlElement('w:shd');shade.set(qn('w:fill'),'E7EFF8' if row_number==0 else ('F5F7F9' if row_number%2==0 else 'FFFFFF'));cell._tc.get_or_add_tcPr().append(shade)
                margins=OxmlElement('w:tcMar')
                for side in ['top','bottom','left','right']:
                    edge=OxmlElement('w:'+side);edge.set(qn('w:w'),'65');edge.set(qn('w:type'),'dxa');margins.append(edge)
                cell._tc.get_or_add_tcPr().append(margins)
                for p in cell.paragraphs:
                    p.paragraph_format.space_after=Pt(2);p.paragraph_format.space_before=Pt(2);p.paragraph_format.line_spacing=1.05
                    if column==0:p.alignment=WD_ALIGN_PARAGRAPH.CENTER
                    for run in p.runs:run.font.size=Pt(10);run.font.bold=row_number==0;run.font.color.rgb=RGBColor(0,0,0)
        paragraph(anchor,'')

    paragraph(anchor, '稳定停止与公开结果接口', 'Heading 3', page=True)
    paragraph(anchor, '新增107位core观测输出不属于执行接口的87位；它们均无控制反馈。系统另暴露RF影子、MEM事件和最后store。载荷仅在各自valid或写使能有效时解释，不能把bubble中的旧数据当成事件。')
    table(['信号组','位宽与采样规则'],[
        ('WB事件','valid/fault/halt/store各1；rd2、pc16、data16、候选Z/C/V3；采样上升沿前的合格事件'),
        ('写入与流水','rf/z/cv_we各1；stall/redirect各1；fetch_pc16、{D,X,M,W} valid4、架构{Z,C,V}3'),
        ('稳定停止','stop_valid/stop_pc_valid各1、stop_pc16、stop_reason3；原drain_done边沿后保持至reset'),
        ('完成标签','last_completed_valid1、last_completed_pc16；只记录无故障合格WB，含STR和HALT'),
        ('系统结果','rf_snapshot64={R3,R2,R1,R0}；MEM en/we各1、addr/data各16；last_store_valid1、addr/data各16'),
    ],[1.2,5.35],'表33 系统公开观测接口')
    table(['原因','含义','PC规则'],[
        ('0','尚无停止现场','stop_valid=0'),('1','HALT','WB中HALT自身pc'),('2','非法Opcode B/F','故障指令pc'),
        ('3','取指越界','越界取指标签pc'),('4','数据EA越界','LDR/STR指令pc'),('5','内部控制非法或消费未就绪源','对应EX故障pc'),
        ('6','非法二进制mode的既有fail-safe','stop_pc_valid=0，无指令PC'),
    ],[0.55,3.15,2.85],'表34 停止原因编码')
    paragraph(anchor, 'reason按X→M→W随有效标签传递；MEM访存故障按年龄覆盖年轻EX事件。正常或指令故障停止在原drain_done边沿锁存w_pc，不使用PC_fetch；取消的年轻标签没有现场。reset清RF/flags、影子、流水有效位及现场，不清DM。原因5/6只做受控仿真注入验证，不代表一般硬件容错。')

    paragraph(anchor, '实际结果与验收边界', 'Heading 3')
    table(['检查','真实执行结果与范围'],[
        ('独立用例与回归','冻结48例、10个reset见证、58行结果；九套回归19个native步骤；五类mutant匹配预期失败；另有X/Z、证据和生命周期检查'),
        ('同步存储','7项公开端口检查：文件读、逐拍更新、禁用保持、写时保持与写后读'),
        ('系统程序','11个程序、12行完整epoch结果；全合法Opcode、控制/访存故障、年轻取消、HALT前老访存、两类reset与停止保持'),
        ('周期与网表','baseline=17/10（周期/动态指令），1停顿1跳转；all_ops=25/16，1停顿2跳转；all_ops网表回放完全同拍'),
        ('工程启动','实际创建14份RTL的Vivado工程，并经launch_simulation完成相同11程序检查'),
        ('系统OOC',f"Vivado 2025.2；xc7z020clg484-1；10 ns；{synthesis['lut']} LUT、{synthesis['ff']} FF、{synthesis['bram']} RAMB18、{synthesis['carry4']} CARRY4；WNS={synthesis['wns_ns']:+.3f} ns、TNS={synthesis['tns_ns']:.3f}、{synthesis['failing_endpoints']}失败端点"),
    ],[1.2,5.35],'表35 本轮系统与受影响验证')
    paragraph(anchor, '本轮完整工具复跑：'+tools_path.parent.relative_to(PACKAGE).as_posix()+'。系统仿真、综合、网表及工程检查：'+system_path.parent.relative_to(PACKAGE).as_posix()+'。各attempt保存输入镜像、指纹、实际日志和CSV；失败尝试保留FAIL，不被后续成功覆盖。')
    paragraph(anchor, '系统OOC含双存储、观测状态和结果影子，不能与旧core-only资源直接混比。OOC DRC仍有ZPS7-1 Warning；无完整IO约束、布局布线、实际setup/hold或下板。没有全状态形式证明、全算术穷举、可变延迟存储和硬件单步；本轮有限PASS不覆盖这些范围。')
    paragraph(anchor, '工具优先级为显式CLI、tools.local.json、CPU_VIVADO_BIN/CPU_PYTHON、PATH；共享示例为tools.example.json，个人路径不提交。仓库外当前目录也可用脚本绝对路径启动。系统工程以create_project.tcl生成至新目录；已有工程拒绝覆盖，镜像变化后重建。')
    # Figure/table numbers are appended after all mature counters. Give the new
    # captions real sequence fields, preserving the existing caption style.
    for p in doc.paragraphs:
        if p.style.name=='Caption' and p.text.startswith(('图11 ', '表33 ', '表34 ', '表35 ')):
            text=p.text;kind='Figure' if text[0]=='图' else 'Table';number=text[1:text.index(' ')]
            p.clear();p.add_run(text[0])
            field=OxmlElement('w:fldSimple');field.set(qn('w:instr'),f'SEQ {kind} \\* ARABIC')
            r=OxmlElement('w:r');value=OxmlElement('w:t');value.text=number;r.append(value);field.append(r);p._p.append(field)
            p.add_run(text[text.index(' '):])
    anchor.paragraph_format.page_break_before=True
    doc.core_properties.version='AC1-system-prep-r1'
    doc.core_properties.comments='ISA v1.5 and execution cycle contract retained; observation-only system increment.'
    target=args.output;ensure_legacy_output(target);doc.save(target)
    print('CORE_WORD_UPDATED '+str(target))


if __name__=='__main__':main()
