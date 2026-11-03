"""Five-person English rehearsal script aligned to the numbered 24-page presentation."""
from pathlib import Path
import argparse,json,re
from docx import Document
from docx.shared import Inches,Pt,RGBColor
from docx.oxml import OxmlElement
from docx.oxml.ns import qn
from docx.enum.table import WD_CELL_VERTICAL_ALIGNMENT

B=Path(__file__).resolve().parent


def para(d,t,size=11,bold=False,keep_next=False):
    p=d.add_paragraph();p.paragraph_format.space_after=Pt(7);p.paragraph_format.keep_together=True;p.paragraph_format.keep_with_next=keep_next
    r=p.add_run(t);r.bold=bold;r.font.size=Pt(size);return p


def main():
    parser=argparse.ArgumentParser();parser.add_argument('--output',type=Path,required=True);a=parser.parse_args()
    c=json.loads((B/'content.json').read_text(encoding='utf-8'));e=json.loads((B/'evidence.json').read_text(encoding='utf-8'))
    d=Document();s=d.sections[0];s.page_width=Inches(8.27);s.page_height=Inches(11.69)
    s.top_margin=s.bottom_margin=Inches(.72);s.left_margin=s.right_margin=Inches(.78)
    for style in d.styles:
        if style.type==1:
            style.font.name='Arial';style.font.color.rgb=RGBColor(0,0,0)
            style.element.get_or_add_rPr().get_or_add_rFonts().set(qn('w:eastAsia'),'Microsoft YaHei')
    d.styles['Normal'].font.size=Pt(11);d.styles['Normal'].paragraph_format.line_spacing=1.1
    for name,size in [('Title',23),('Heading 1',17),('Heading 2',13)]:
        d.styles[name].font.size=Pt(size);d.styles[name].font.bold=True;d.styles[name].paragraph_format.keep_with_next=True
    d.add_paragraph('Pre6 CPU Integration and Verification','Title')
    para(d,'Group 2 English Script and Q&A',14,True)
    para(d,'24页连续正文  分级目录  CPU v1.6 / ISA v1.5 / AC1',11)
    para(d,f"正文{c['spoken_words']}个英文词；讲解预算14分钟，另留1分钟换页与交接。英文为正式讲稿，中文为理解与指图提示。",11)
    para(d,'章节：1 ISA；2设计流程；3架构与执行；4功能验证；5性能与权衡；6交付。PPT标题中的1.1、3.3.3等编号用于定位逻辑层级。',10.5)
    para(d,'计时为排练预算。五人完整试讲后按实际语速调整，先指图，再解释机制与结果。',10.5)
    d.add_heading('五人分工合作表',1)
    roles={who:[(i,row)for i,row in enumerate(c['main'],1)if row['speaker']==who]for who in 'ABCDE'}
    names={who:cfg['topic']for who,cfg in c['team'].items()}
    t=d.add_table(rows=1,cols=4)
    t.autofit=False
    for column,width in zip(t.columns,[.85,.55,2.85,2.46]):column.width=Inches(width)
    for cell,value in zip(t.rows[0].cells,['讲者 / 页码','预算','负责内容与准备','协作核对']):cell.text=value
    for who,items in roles.items():
        seconds=sum(x['seconds']for _,x in items);cells=t.add_row().cells
        cfg=c['team'][who]
        for cell,value in zip(cells,[f'{who}\nP{items[0][0]}–{items[-1][0]}',f'{seconds//60}:{seconds%60:02d}',names[who]+'\n'+cfg['prepare'],cfg['check']]):cell.text=value
    para(d,'合作顺序：先各自按本页准备，再完成表内交叉核对，最后A→B→C→D→E整组试讲；E记录总时长，每人检查自己的交接句。',10)
    for who,items in roles.items():
        heading=d.add_heading(f'Speaker {who}  {names[who]}',1);heading.paragraph_format.page_break_before=True
        for index,row in items:
            heading=d.add_heading(f"Slide {index}  {row['title']}",2)
            if row.get('reference_page')in [8,17,21]:heading.paragraph_format.page_break_before=True
            words=len(re.findall(r"[A-Za-z0-9]+(?:['.-][A-Za-z0-9]+)*",row['speech']))
            para(d,f"目标{row['seconds']}秒  英文{words}词",9.5,keep_next=True)
            para(d,row['speech'],11.5,keep_next=True)
            para(d,'中文指图提示：'+row['cue'],10)
    heading=d.add_heading('常见问题英文回答',1);heading.paragraph_format.page_break_before=True
    for question,answer in c['questions']:
        d.add_heading(question,2);para(d,answer,11)
    for question,answer in [
      ('How is the adder implemented in the final CPU?','The production arithmetic module uses a seventeen-bit plus expression to infer the FPGA carry chain. Its historical name is addsub16_cla. The standalone handwritten CLA modules remain reference designs.'),
      ('Why does the project opener use an English workspace?','The opener creates the working project in CPU_Pre6 to handle Vivado GUI and IP-generation path requirements. Source packages, programs, and presentation materials remain in the course folder.'),
      ('What changed to repair the GUI project?','The CPU RTL is unchanged. The integration wrappers supply consistent image filenames, while fresh writable working directories replace copied run caches. Both behavioral and synthesized CPU results are checked against the same expected events.')]:
        d.add_heading(question,2);para(d,answer,11)
    heading=d.add_heading('从D盘直接打开与验证',1);heading.paragraph_format.page_break_before=True
    d.add_heading('统一讲解口径',2)
    para(d,'中文图沿用已核对的原始版本，正文与口头汇报使用英文。VIO读取RF写回影子；物理S1在HALT后测试。周期换算时间采用100MHz设计时钟。逐拍内部证据来自XSim。',10.5)
    para(d,'R0读R zero，ISA/CPI逐字母读；0x1232读hexadecimal one two three two。指令05–07读zero-five to zero-seven。源码路径和哈希留作查阅。',10.5)
    d.add_heading('工程入口',2)
    steps=[
      '1. 在Pre6_CPU集成与验证/Vivado中双击Open_CPU_Project.cmd。入口自动创建并打开C:/Users/Donson/Documents/CPU_Pre6/CPU/project/pre6_cpu.xpr。无需手动搬目录。',
      '2. 默认copy_checksum。design top是pre6_cpu_top，simulation top是tb_pre6_cpu。Run Synthesis应完成且无错误；Behavioral Simulation与Post-Synthesis Functional Simulation应各得到55周期、35指令、16停顿、0重定向、8次store。',
      '3. 需要完整板级流程时双击Open_EES331_Project.cmd。工作工程位于CPU_Pre6/EES331，包含VIO和真实引脚约束，可综合、实现并生成bitstream。',
      '4. 在D盘Vivado目录运行 .\\run_tests.ps1 -Program all 验证五个程序；-Program copy_checksum -Mode full会同时检查综合前后行为。每次建立独立工作区，原始记录保存在验证记录。',
      '5. CPU波形Scope为tb_pre6_cpu/check/dut/u_cpu_system_inst/core，可添加x_valid/m_valid/w_valid、x_alu_a_sel/x_alu_b_sel、load_use、rd_fwd/rs_fwd及写使能。PPT和CSV的stall=observe_stall，是经RUN、reset、frontend_kill资格限定的load_use；本例C9两者均为1。CW_X/M/W是字段组称呼。',
      '6. GUI中的工作代码位于C盘对应工程的rtl目录；D盘源包用于可复现的基线测试。入口保留已有工作工程及本地修改。板级下载另按实物连接流程执行。'
    ]
    for text in steps:para(d,text,11)
    d.add_heading('排练检查',1)
    for text in ['按目录的1→2→3→4→5主线试讲；章节编号与PPT一致。','D重点解释baseline源码、预期与波形的对应关系，以及C6故障例中老WB同拍完成。','E把55→47解释为14.5%周期缩减、同频约1.17倍；LUT增量属于完整board top。','整组加入换页和指图后不超过15分钟。']:para(d,text,10.5)
    para(d,'设计基线：'+e['tag']+'。逐页原始来源见配套源文件/source_map.json和PPT备注。',9.5)
    for table in d.tables:
        borders=OxmlElement('w:tblBorders')
        for edge in ['top','left','bottom','right','insideH','insideV']:
            b=OxmlElement('w:'+edge);b.set(qn('w:val'),'single');b.set(qn('w:sz'),'4');b.set(qn('w:color'),'D9D9D9');borders.append(b)
        table._tbl.tblPr.append(borders)
        for i,row in enumerate(table.rows):
            trpr=row._tr.get_or_add_trPr();trpr.append(OxmlElement('w:cantSplit'))
            if i==0:trpr.append(OxmlElement('w:tblHeader'))
            for cell,width in zip(row.cells,[.85,.55,2.85,2.46]):
                cell.width=Inches(width);cell.vertical_alignment=WD_CELL_VERTICAL_ALIGNMENT.CENTER
                if i==0:
                    sh=OxmlElement('w:shd');sh.set(qn('w:fill'),'E8F0F5');cell._tc.get_or_add_tcPr().append(sh)
                for p in cell.paragraphs:
                    for r in p.runs:r.font.size=Pt(10);r.bold=i==0
    footer=s.footer.paragraphs[0];footer.alignment=2;footer.add_run('Pre6 Group 2  ')
    field=OxmlElement('w:fldSimple');field.set(qn('w:instr'),'PAGE');footer._p.append(field)
    for border in list(d.styles.element.iter(qn('w:pBdr'))):border.getparent().remove(border)
    for border in list(d.element.iter(qn('w:pBdr'))):border.getparent().remove(border)
    d.core_properties.title='Pre6 CPU Integration and Verification English Script';d.core_properties.version=c['revision']
    d.save(a.output);print('R3_WORD_READY '+str(a.output))


if __name__=='__main__':main()
