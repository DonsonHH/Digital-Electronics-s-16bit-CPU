"""Compile the single core Word from explicit architecture/content anchors, never paragraph offsets."""
from pathlib import Path
from io import BytesIO
from copy import deepcopy
import argparse,hashlib,json,re
from lxml import etree
from docx import Document
from docx.oxml import OxmlElement
from docx.oxml.ns import qn
from docx.shared import Inches,Pt,RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_CELL_VERTICAL_ALIGNMENT
from docx.enum.section import WD_SECTION_START,WD_ORIENT
from source_validation import P,ROOT,BASELINE,read,require,sha,source_bytes,check_rtl_contract,extract_examples,verify_board_validation
from document_content import body_content_digest

B=Path(__file__).resolve().parent;NAME='16位流水线CPU核心设计文档_AC1候选版.docx'
REF=re.compile(r'\[\[([FT]\d+|N_[A-Z0-9_]+|S:[A-Z0-9_.]+)\]\]',re.I)

class Compiler:
    def __init__(self,plan,legacy,content,examples):
        self.plan,self.legacy,self.content,self.examples=plan,legacy,content,examples
        self.doc=Document(BytesIO(source_bytes(plan['baseline_document'])))
        section=deepcopy(self.doc.sections[0]._sectPr)
        for node in list(self.doc._element.body):self.doc._element.body.remove(node)
        self.doc._element.body.append(section)
        if self.doc.settings.element.find(qn('w:doNotAutoCompressPictures'))is None:self.doc.settings.element.append(OxmlElement('w:doNotAutoCompressPictures'))
        self.counters=[0]*4;self.labels={};self.old_sections={};self.caption_counts={'F':0,'T':0};self.references=[];self.bookmark_id=1000;self.rendered_sections=set();self.section_numbers={};self.landscape=False
        self.appendix=False
        self.portrait(self.doc.sections[0]);self.configure_numbering()
    def configure_numbering(self):
        numbering=self.doc.part.numbering_part.element
        abstract_id=max([int(n.get(qn('w:abstractNumId')))for n in numbering.findall(qn('w:abstractNum'))]+[0])+1
        num_id=max([int(n.get(qn('w:numId')))for n in numbering.findall(qn('w:num'))]+[0])+1
        abstract=OxmlElement('w:abstractNum');abstract.set(qn('w:abstractNumId'),str(abstract_id))
        for level in range(4):
            lvl=OxmlElement('w:lvl');lvl.set(qn('w:ilvl'),str(level))
            for tag,value in [('start','1'),('numFmt','decimal'),('lvlText','.'.join('%'+str(n+1)for n in range(level+1))),('lvlJc','left')]:
                item=OxmlElement('w:'+tag);item.set(qn('w:val'),value);lvl.append(item)
            abstract.append(lvl)
        for tag,value in reversed([('nsid','A16C0001'),('multiLevelType','multilevel'),('tmpl','A16C1001')]):
            item=OxmlElement('w:'+tag);item.set(qn('w:val'),value);abstract.insert(0,item)
        first_num=numbering.find(qn('w:num'))
        if first_num is None:numbering.append(abstract)
        else:first_num.addprevious(abstract)
        num=OxmlElement('w:num');num.set(qn('w:numId'),str(num_id));item=OxmlElement('w:abstractNumId');item.set(qn('w:val'),str(abstract_id));num.append(item)
        cleanup=numbering.find(qn('w:numIdMacAtCleanup'))
        if cleanup is None:numbering.append(num)
        else:cleanup.addprevious(num)
        self.num_id=num_id
        appendix=deepcopy(abstract);appendix.set(qn('w:abstractNumId'),str(abstract_id+1))
        appendix.find(qn('w:nsid')).set(qn('w:val'),'A16C0002')
        appendix.find(qn('w:tmpl')).set(qn('w:val'),'A16C1002')
        first=appendix.find(qn('w:lvl'))
        first.find(qn('w:numFmt')).set(qn('w:val'),'upperLetter')
        first.find(qn('w:lvlText')).set(qn('w:val'),'附录%1')
        numbering.find(qn('w:num')).addprevious(appendix)
        num=OxmlElement('w:num');num.set(qn('w:numId'),str(num_id+1));item=OxmlElement('w:abstractNumId');item.set(qn('w:val'),str(abstract_id+1));num.append(item)
        if cleanup is None:numbering.append(num)
        else:cleanup.addprevious(num)
        self.appendix_num_id=num_id+1
        for level in range(1,5):
            style=self.doc.styles['Heading '+str(level)];style.font.color.rgb=RGBColor(0,0,0)
            style.paragraph_format.keep_with_next=True
            if level==4:style.font.size=Pt(11)
        for style in self.doc.styles:
            if style.name.lower().startswith('toc '):
                style.font.size=Pt(10.5);style.font.color.rgb=RGBColor(0,0,0)
                style.paragraph_format.space_before=Pt(0);style.paragraph_format.space_after=Pt(1)
                style.paragraph_format.line_spacing=Pt(14.5)
    @staticmethod
    def portrait(section):
        section.orientation=WD_ORIENT.PORTRAIT;section.page_width=Inches(8.5);section.page_height=Inches(11)
        section.left_margin=section.right_margin=section.top_margin=section.bottom_margin=Inches(.75)
    def orientation(self,landscape):
        self.landscape=landscape
        section=self.doc.add_section(WD_SECTION_START.NEW_PAGE)
        self.portrait(section)
        if landscape:
            section.orientation=WD_ORIENT.LANDSCAPE;section.page_width=Inches(11);section.page_height=Inches(8.5)
            section.top_margin=section.bottom_margin=Inches(.6)
        pg=section._sectPr.find(qn('w:pgNumType'))
        if pg is not None:pg.attrib.pop(qn('w:start'),None)
    def bookmark(self,p,key,run_end=None):
        self.bookmark_id+=1;start=OxmlElement('w:bookmarkStart');start.set(qn('w:id'),str(self.bookmark_id));start.set(qn('w:name'),'ARCH_'+key)
        end=OxmlElement('w:bookmarkEnd');end.set(qn('w:id'),str(self.bookmark_id))
        if run_end is None:
            p._p.insert(1 if p._p.pPr is not None else 0,start);p._p.append(end)
        else:p._p.insert(1 if p._p.pPr is not None else 0,start);run_end.addnext(end)
    def heading(self,text,level,key,old=None,page=False):
        self.counters[level-1]+=1
        for n in range(level,4):self.counters[n]=0
        parts=list(map(str,self.counters[:level]))
        if self.appendix:parts[0]=chr(64+self.counters[0])
        label='.'.join(parts);p=self.doc.add_heading(text,level)
        p.paragraph_format.page_break_before=page
        if self.landscape:p.paragraph_format.space_before=Pt(0);p.paragraph_format.space_after=Pt(6)
        prop=p._p.get_or_add_pPr();num=prop.get_or_add_numPr();num.get_or_add_ilvl().val=level-1;num.get_or_add_numId().val=self.appendix_num_id if self.appendix else self.num_id
        self.bookmark(p,key);self.labels[key]=label;self.section_numbers[key]=label
        if old:self.old_sections[old]=key
        return p
    def alias(self,old,key):self.old_sections[old]=key
    @staticmethod
    def normalize(text):
        for old,new in [('CTRL_X','CW_X'),('CTRL_M','CW_M'),('CTRL_W','CW_W'),('本轮完整工具复跑','阶段1至2的完整工具复跑'),('实际板卡尚未接入','该阶段记录未包含实板验收'),('课程板尚未接入','该阶段记录未包含实板验收'),('课程板尚未连接','该阶段记录未包含实板验收'),('当前没有真实板上功能','该历史记录未包含真实板上功能')]:text=text.replace(old,new)
        return text
    def add_text(self,p,text):
        position=0
        for match in REF.finditer(text):
            p.add_run(self.normalize(text[position:match.start()]));key=match[1]
            if key.startswith('S:'):p.add_run('第')
            f=OxmlElement('w:fldSimple');f.set(qn('w:instr'),'REF ARCH_PENDING \\h');r=OxmlElement('w:r');t=OxmlElement('w:t');t.text=key;r.append(t);f.append(r);p._p.append(f);self.references.append((f,key));position=match.end()
            if key.startswith('S:'):p.add_run('节')
        p.add_run(self.normalize(text[position:]))
    def paragraph(self,text='',style='Normal'):
        p=self.doc.add_paragraph(style=style);self.add_text(p,text);return p
    def caption(self,key,title):
        prefix='F'if key.startswith('F')else'T';self.caption_counts[prefix]+=1;number=self.caption_counts[prefix]
        p=self.doc.add_paragraph(style='Caption');p.paragraph_format.keep_with_next=True;p.add_run('图'if prefix=='F'else'表')
        if self.landscape:p.paragraph_format.space_before=Pt(0);p.paragraph_format.space_after=Pt(4);p.paragraph_format.line_spacing=1.0
        f=OxmlElement('w:fldSimple');f.set(qn('w:instr'),'SEQ '+('Figure'if prefix=='F'else'Table')+' \\* ARABIC');r=OxmlElement('w:r');text=OxmlElement('w:t');text.text=str(number);r.append(text);f.append(r);p._p.append(f)
        self.bookmark(p,key,run_end=f);p.add_run(' ');self.add_text(p,title);self.labels[key]=('图'if prefix=='F'else'表')+str(number)
    def table(self,rows,widths,key,title=None):
        if title is not None:self.caption(key,title)
        widths=list(widths);total=sum(widths)
        if total>6.9:widths=[w*6.9/total for w in widths]
        require(all(len(row)==len(widths)for row in rows),'Ragged source table: '+key)
        table=self.doc.add_table(rows=0,cols=len(widths));table.autofit=False
        for col,w in zip(table.columns,widths):col.width=Inches(w)
        borders=OxmlElement('w:tblBorders')
        for side in ['top','left','bottom','right','insideH','insideV']:
            node=OxmlElement('w:'+side);node.set(qn('w:val'),'single');node.set(qn('w:sz'),'4');node.set(qn('w:color'),'D9D9D9');borders.append(node)
        table._tbl.tblPr.append(borders)
        for i,values in enumerate(rows):
            row=table.add_row();row._tr.get_or_add_trPr().append(OxmlElement('w:cantSplit'))
            if i==0:row._tr.get_or_add_trPr().append(OxmlElement('w:tblHeader'))
            for j,(cell,value)in enumerate(zip(row.cells,values)):
                cell.width=Inches(widths[j]);cell.vertical_alignment=WD_CELL_VERTICAL_ALIGNMENT.CENTER
                shade=OxmlElement('w:shd');shade.set(qn('w:fill'),'E7EFF8'if i==0 else'F5F7F9'if i%2==0 else'FFFFFF');cell._tc.get_or_add_tcPr().append(shade)
                p=cell.paragraphs[0];self.add_text(p,str(value));p.paragraph_format.space_after=p.paragraph_format.space_before=Pt(3);p.paragraph_format.line_spacing=1.05
                if i==0 or ((len(rows)<=6 or key.startswith('N_EX_')) and i<len(rows)-1):p.paragraph_format.keep_with_next=True
                if re.fullmatch(r'[\d.+/ %—:-]+',str(value)):p.alignment=WD_ALIGN_PARAGRAPH.CENTER
                size=9 if key.startswith('N_EX_') and 1<=j<=5 else 10
                for run in p.runs:run.font.size=Pt(size);run.font.bold=i==0;run.font.color.rgb=RGBColor(0,0,0)
        self.doc.add_paragraph().paragraph_format.space_after=Pt(2)
    def image(self,path,figure):
        p=self.doc.add_paragraph();p.alignment=WD_ALIGN_PARAGRAPH.CENTER;p.paragraph_format.keep_with_next=True;p.paragraph_format.space_after=Pt(3)
        p.paragraph_format.space_before=Pt(0);p.paragraph_format.line_spacing=1.0
        width=9.0 if figure in ['F01','F02'] else 6.6
        p.add_run().add_picture(str(P/path),width=Inches(width))
    def nodes(self,nodes,base_level=2,target_level=2):
        for index,node in enumerate(nodes):
            if 'section'in node:
                child=self.legacy['sections'][node['section']];level=child['level']-base_level+target_level
                self.reuse(node['section'],level=level);continue
            kind=node['kind']
            if kind=='paragraph':
                if not node['runs']:continue
                if any(r['kind']=='image'for r in node['runs']):
                    for r in node['runs']:
                        if r['kind']=='image':self.image(r['path'],r['figure'])
                    continue
                p=self.doc.add_paragraph(style=node['style'])
                if node['style']=='Code':
                    following=nodes[index+1] if index+1<len(nodes) else {}
                    p.paragraph_format.keep_with_next=following.get('style')=='Code'
                for r in node['runs']:
                    if r['kind']=='text':self.add_text(p,r['text'])
                    elif r['kind']=='math':p._p.append(etree.fromstring(r['xml'].encode('utf-8')))
                    elif r['kind']=='link':
                        rid=self.doc.part.relate_to(r['url'],'http://schemas.openxmlformats.org/officeDocument/2006/relationships/hyperlink',is_external=True)
                        link=OxmlElement('w:hyperlink');link.set(qn('r:id'),rid);run=OxmlElement('w:r');prop=OxmlElement('w:rPr');style=OxmlElement('w:rStyle');style.set(qn('w:val'),'Hyperlink');prop.append(style);run.append(prop);text=OxmlElement('w:t');text.text=r['text'];run.append(text);link.append(run);p._p.append(link)
            elif kind=='caption':
                title={'T14':'控制所有权与RTL对应','T15':'数据 CW与元数据的级间载荷','T35':'文件启动系统与已存工具验证'}.get(node['id'],node['title']);self.caption(node['id'],title)
            elif kind=='table':
                if node['caption_id']=='T14':self.table([['职责/对象','信息或意图来源','仲裁与资格','实际驱动与边沿']]+self.plan['ownership'],[1.15,1.8,1.75,2.15],'T14')
                elif node['caption_id']=='T15':self.table([['边界','数据','元数据与标签','CW','保存位置']]+self.plan['payload'],[.8,1.65,1.55,1.05,1.8],'T15')
                else:self.table(node['rows'],node['widths'],node['caption_id'])
            else:raise ValueError('Unknown content node: '+kind)
    def reuse(self,source,level=2,title=None,key=None,body_only=False,filter_prefixes=()):
        section=self.legacy['sections'][source];key=key or'S_'+hashlib.sha256(source.encode()).hexdigest()[:12]
        if not body_only:
            require(source not in self.rendered_sections,'Legacy section rendered twice: '+source);self.rendered_sections.add(source)
            self.heading(title or section['title'],level,key,old=section['old_number'])
        nodes=[]
        for node in section['children']:
            text=''.join(r.get('text','')for r in node.get('runs',[]))
            if not filter_prefixes or not text.startswith(filter_prefixes):nodes.append(node)
        self.nodes(nodes,section['level'],level)
    def new(self,key,level=2):
        content=self.content[key];self.heading(content['title'],content.get('level',level),key)
        for text in content.get('paragraphs',[]):self.paragraph(text)
        if 'table'in content:
            t=content['table'];self.table(t['rows'],t['widths'],t['id'],t['title'])
        for text in content.get('code',[]):self.paragraph(text,'Code')
    def cover(self):
        self.doc.styles['Title'].font.color.rgb=RGBColor(0,0,0)
        self.doc.add_paragraph('16位流水线CPU核心设计文档','Title')
        p=self.paragraph('默认AC1    CPU v1.6    ISA v1.5    架构版r5    2026年11月3日');self.bookmark(p,'DOC_ROOT')
        for text in [
          '本规范描述面向EES-331教学平台的16位哈佛结构处理器。CPU采用顺序单发射、硬连线控制和五级流水线，以明确的指令契约组织运算、存储和控制流，并使数据、操作意图与有效标签保持一致。',
          '指令沿IF、ID、EX、MEM、WB推进。独立的同步IM和DM提供固定一拍读接口，级间载荷保存本条指令后续需要的信息。已就绪依赖通过前递解决，加载依赖通过互锁等待；跳转和故障按指令年龄取消年轻工作，停止标签随流水排空。',
          '第一章定义指令与接口契约，第二章搭建数据通路和状态边界，第三章说明流水控制，第四章给出系统实现、功能证据和性能取舍。附录保存版本迁移、运行来源及复现入口。机器字、字地址和寄存器值默认用十六进制表示；程序周期及计数默认用十进制。']:
            self.paragraph(text)
        self.table([
          ['术语','本文含义'],
          ['AC1','当前默认实现的版本标识，CPU v1.6、ISA v1.5'],
          ['IF / ID / EX / MEM / WB','取指、译码读源、执行、访存、写回五个阶段'],
          ['D / X / M / W','分别与ID、EX、MEM、WB绑定的载荷或信号前缀'],
          ['RF / IM / DM','寄存器组、指令存储器、数据存储器'],
          ['CU / DP / CW','控制职责、数据通路、随指令传递的操作意图字段集合'],
          ['valid / bubble / stall / flush','有效标签、无效空槽、保持等待、取消年轻指令']
        ],[2.0,4.8],'N_TERMS','术语与阅读约定')
        self.doc.add_paragraph('目录','FrontHeading').paragraph_format.page_break_before=True
        p=self.doc.add_paragraph();begin=OxmlElement('w:fldChar');begin.set(qn('w:fldCharType'),'begin');r=OxmlElement('w:r');r.append(begin);p._p.append(r)
        instr=OxmlElement('w:instrText');instr.set(qn('xml:space'),'preserve');instr.text=' TOC \\o "1-3" \\h \\z \\u ';r=OxmlElement('w:r');r.append(instr);p._p.append(r)
        separate=OxmlElement('w:fldChar');separate.set(qn('w:fldCharType'),'separate');r=OxmlElement('w:r');r.append(separate);p._p.append(r);p.add_run('目录由Word更新')
        end=OxmlElement('w:fldChar');end.set(qn('w:fldCharType'),'end');r=OxmlElement('w:r');r.append(end);p._p.append(r)
    def overview(self):
        self.new('OVERVIEW');self.alias('2.1','OVERVIEW')
        self.orientation(True)
        tail=[]
        for i,source in enumerate(['整体控制与数据通路架构','五级数据通路详细连接']):
            section=self.legacy['sections'][source]
            self.heading(section['title'],3,'OVERVIEW_'+str(i),old=section['old_number'])
            end=next(n+1 for n,node in enumerate(section['children'])if node.get('kind')=='caption'and node['id']=='F0'+str(i+1))
            self.nodes(section['children'][:end],3,3)
            tail.extend(section['children'][end:])
            if i==0:self.doc.add_page_break()
        self.orientation(False)
        self.nodes(tail,3,3)
    def stage_contract(self):
        self.reuse('统一五级执行契约',title='架构状态与统一五级执行',key='STAGE_CONTRACT')
        self.new('SINGLE_STATE',level=3)
    def control(self):
        self.heading('硬连线控制与随行操作意图',2,'CONTROL_LAYERS',old='2.6')
        self.reuse('控制逻辑模型',level=3)
        self.new('CW_CLASSIFICATION',level=3)
        self.reuse('译码控制表',level=3,key='DECODE',title='ID译码与指令操作意图')
        self.new('INTENT_ACTION',level=3)
    def implementation(self):
        self.reuse('源码边界与连接约定',title='RTL模块组织与连接',key='SOURCE')
        self.reuse('内部功能与信号归属',level=3,title='逻辑职责与实际RTL映射')
        self.reuse('目标数据通路的连接片段',level=3,key='CONNECTIONS',title='数据通路与控制连接')
    def system(self):
        self.new('SYSTEM');self.alias('2.10','SYSTEM');self.alias('4.11','SYSTEM')
        self.reuse('文件初始化与系统连接',level=3)
        self.reuse('稳定停止与公开结果接口',level=3)
    def board(self):
        self.new('BOARD');self.alias('4.12','BOARD')
        self.reuse('时钟复位与观测连接',level=3)
        self.reuse('完整实现与时序覆盖',level=3)
    def verification(self):
        content=self.content['VERIFICATION']
        self.heading(content['title'],2,'VERIFICATION')
        for paragraph in content['paragraphs']:self.paragraph(paragraph)
        self.reuse('自检查测试方法',level=3)
        self.heading('单元与流水覆盖总览',3,'COVERAGE')
        self.nodes(self.legacy['sections']['统一五级与冒险验证结果']['children'][:2])
        self.reuse('单元输入与状态覆盖',body_only=True)
        self.heading('流水时序与指令执行检查',3,'PIPELINE_VERIFICATION')
        self.nodes(self.legacy['sections']['统一五级与冒险验证结果']['children'][2:])
        self.reuse('核心既有验证记录',body_only=True)
        self.reuse('流水相关与停止测试',level=4)
        self.reuse('全部指令的执行覆盖',level=4)
        self.reuse('CPU功能验证程序',level=3,title='文件启动整机验证')
        self.reuse('实际结果与验收边界',body_only=True)
        self.heading('EES331实板功能验证',3,'BOARD_VERIFICATION')
        self.paragraph('五个默认AC1已布线镜像分别在EES-331运行。每个程序读取两份原始VIO快照，核对构建身份、稳定终态和计数；随后在checksum正常停止后实际操作S1，检查复位清零与松开后重启。')
        t=self.content['VERIFICATION']['table'];self.table(t['rows'],t['widths'],t['id'],t['title'])
        self.paragraph('RF观测值来自写回影子。板上稳定快照与仿真内部逐拍记录分别对应终态、计数和控制时序；原始VIO、S1及仿真记录的来源见附录。')
    def performance(self):
        self.new('PERFORMANCE');self.reuse('CPU性能验证',level=3)
        self.table([['对象','LUT / FF / BRAM18','时序与适用范围'],
          ['历史core-only AC1','287 / 260 / 0','历史OOC WNS +2.620ns；观测扩展前，不能当整机资源'],
          ['文件启动cpu_system','376 / 431 / 2','已存系统OOC WNS +1.363ns；含IM/DM和影子'],
          ['含VIO板级AC1','五程序LUT1082～1160；FF2822～2826；BRAM18均2','完整布线setup WNS +1.434～+2.101ns；不是实物时钟或时间测量']],[1.45,2.5,2.9],'N_RESOURCE_SCOPE','三种资源和时序统计边界')
        self.paragraph('两项OOC均使用15个CARRY4。系统OOC的TNS为0.000ns、失败端点为0；完整板级的setup和hold分别按下表布线报告读取。')
        self.reuse('固定程序与性能基线',level=3)
    def experiments(self):
        self.new('EXPERIMENTS');self.reuse('前递MUX组合候选',level=3);self.reuse('WB到MEM存储数据候选',level=3)
    def reproduce(self):
        self.new('REPRODUCE');self.alias('4.9','DESIGN_FLOW');self.alias('4.10','REPRODUCE');self.alias('4.12.6','REPRODUCE')
    def worked_examples(self):
        self.heading('跨级协同的逐拍实例',2,'CLOCKED_EXAMPLES');self.alias('3.1','CLOCKED_EXAMPLES')
        self.paragraph('以下五例依次展示前递、加载等待、比较分支、HALT排空和故障年龄仲裁。阶段列表示周期结束边沿前的有效指令，IF列为实际取指请求；最后一列给出该边沿动作。初值统一由测试台在首条取指前建立，记录来源见附录。')
        comments={
          'DOC_ADD_ADD':'C4第一条ADD在M、第二条ADD在X，最近M非load结果可直接前递；不等待RF在C5写入，也不增加停顿。最终R0=0003、R2=0007。',
          'DOC_LOAD_STR':'C3保持IF/ID并给下一拍EX插入bubble，LDR继续进入MEM；C5的STR从W取得load数据，C6写DM，C7消费STR的有效WB标签，随后HALT于C8完成。因此相邻加载依赖只增加一拍等待。',
          'DOC_CMP_JZ':'JZ在X使用M中最近CMP的候选Z=1，无需等待架构Z写回。pc2的STR被取消，不得写DM；CMP仍在WB更新Z。目标pc3的HALT按完整路径停止。',
          'DOC_STR_HALT':'C4老STR写DM且年轻HALT在X接受停止，老指令不能被HALT取消；STR在C5继续有效WB但不再写DM，HALT在C6的WB结束边沿使核心停止。',
          'MEM_FAULT_OVER_BRANCH':'C6的M级LDR完整EA=0100，访问被禁止，年轻X级JUMP不获重定向；更老W级ADD仍写R0与C/V。故障标签继续W，在C7消费后FAULTED。故障不会回滚已经完成的更老写入。'}
        for example in self.examples['examples']:
            self.heading(example['title'],3,example['id'])
            self.paragraph('初始RF：'+', '.join(f'R{i}={v:04X}'for i,v in enumerate(example['initial_rf']))+'；初始Z/C/V='+''.join(map(str,example['initial_flags']))+'。')
            if example['case']=='DOC_LOAD_STR':self.paragraph('DM[0020]=0007；STR的独立基址为R1=0021。')
            for text in example['instructions']:self.paragraph(text,'Code')
            self.table([['周期','IF','ID','EX','MEM','WB','结束边沿与动作']]+example['rows'],[.45,.5,.72,.72,.72,.72,2.95],'N_'+example['id'],example['title']+'逐拍过程')
            self.paragraph(comments[example['case']])
    def finish(self):
        for field,key in self.references:
            if key.startswith('S:'):
                old=key[2:];target=self.old_sections.get(old,old);require(target in self.section_numbers,'Unresolved section reference: '+old);value=self.labels[target]
            else:target=key;require(target in self.labels,'Unresolved caption reference: '+target);value=self.labels[target]
            field.set(qn('w:instr'),'REF ARCH_'+target+(' \\w'if key.startswith('S:')else'')+' \\h');field.find('.//'+qn('w:t')).text=value
        require(self.caption_counts['F']==12 and self.caption_counts['T']>=39,'Mature figures or tables were lost')
        self.doc.core_properties.title='16位流水线CPU核心设计文档';self.doc.core_properties.version=self.plan['revision'];self.doc.core_properties.identifier='architecture-schema-1'
        self.doc.core_properties.comments='Default AC1 five-program and physical S1 acceptance; ISA/pipeline unchanged; no independent frequency, wall-time or experimental-board acceptance.'
        return self.doc
    def build(self):
        self.cover()
        introductions={
          'CH1':'先从程序员视角规定资源、编码和状态变化，再说明核心接口及同步存储的边沿契约。后续数据通路、控制与验证均以本章为依据。',
          'CH2':'本章沿数据的产生、保存和消费展开：先看五级拓扑与部件，再建立流水边界和状态更新规则，最后用典型指令追踪完整路径。',
          'CH3':'先说明单条指令如何携带操作意图，再处理多条在途指令的数据依赖，随后说明跳转、故障和停止如何按年龄协调，并以逐拍实例贯通这些机制。',
          'CH4':'从RTL连接进入片上系统和板级实现，再按单元、流水、系统与实板组织功能证据，最后说明性能基线与两个候选的工程取舍。'}
        def emit(section):
            kind=section['kind'];key=section['id']
            if kind=='reuse':self.reuse(section['heading'],level=section.get('level',2),title=section.get('title'),key=key)
            elif kind=='new':self.new(key)
            elif kind=='examples':self.worked_examples()
            else:getattr(self,kind)()
        for n,chapter in enumerate(self.plan['chapters'],1):
            self.heading(chapter['title'],1,chapter['id'],old=str(n),page=True);self.paragraph(introductions[chapter['id']])
            for section in chapter['sections']:emit(section)
        self.appendix=True;self.counters=[0]*4
        for appendix in self.plan.get('appendices',[]):
            self.heading(appendix['title'],1,appendix['id'],page=True)
            for section in appendix['sections']:emit(section)
        return self.finish()

def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--independent-run',type=Path,required=True);parser.add_argument('--output',type=Path,default=P/NAME);parser.add_argument('--proof-output',type=Path)
    a=parser.parse_args();plan=read(B/'architecture.json');legacy=read(B/'sections.json');content=read(B/'content.json')
    rtl=check_rtl_contract(plan);examples=extract_examples(plan,a.independent_run);board=verify_board_validation(plan)
    compiler=Compiler(plan,legacy,content,examples);doc=compiler.build();doc.save(a.output)
    image_paths={r['path']for section in legacy['sections'].values()for node in section['children']for r in node.get('runs',[])if r['kind']=='image'}
    image_paths.update('架构图/'+n+'.svg'for n in ['01_CPU整体架构','02_五级Datapath','03_文件启动系统与停止观测'])
    proof={'status':'AUTHORED_PENDING_NATIVE_WORD_AND_VISUAL_QA','revision':plan['revision'],'source_files':{p.name:sha(p)for p in[B/'architecture.json',B/'sections.json',B/'content.json',B/'build_core_document.py',B/'source_validation.py']},'figure_sources':{name:sha(P/name)for name in sorted(image_paths)},'production_rtl_sha256':rtl,'examples':examples,'section_numbers':compiler.section_numbers,'caption_labels':compiler.labels,'old_section_targets':compiler.old_sections,'word_sha256_before_native_update':sha(a.output),'new_native_execution_claim':'independent48 only; not a new9-suite/P&R/board run','hardware_access_performed':False}
    proof['source_files']['canonical_outputs.json']=sha(B/'canonical_outputs.json')
    proof['source_files']['document_content.py']=sha(B/'document_content.py')
    proof['word_body_content_sha256']=body_content_digest(doc)
    proof['board_validation']=board
    proof['new_native_execution_claim']='Read-only authoring; consumes prior independent48 and the recorded five-program/S1 physical run. No new XSim or P&R from this command.'
    proof['csv_binding']='Byte equality to same13-RTL frozen48 output digests pinned in0d888cc package manifest'
    if a.proof_output:a.proof_output.write_text(json.dumps(proof,ensure_ascii=False,indent=2),encoding='utf-8')
    print('ARCHITECTURE_WORD_AUTHORED '+str(a.output))
if __name__=='__main__':main()
