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
from source_validation import P,ROOT,BASELINE,read,require,sha,source_bytes,check_rtl_contract,extract_examples

B=Path(__file__).resolve().parent;NAME='16位流水线CPU核心设计文档_AC1候选版.docx'
REF=re.compile(r'\[\[(F\d+|T\d+|S:[\d.]+)\]\]')

class Compiler:
    def __init__(self,plan,legacy,content,examples):
        self.plan,self.legacy,self.content,self.examples=plan,legacy,content,examples
        self.doc=Document(BytesIO(source_bytes(plan['baseline_document'])))
        section=deepcopy(self.doc.sections[0]._sectPr)
        for node in list(self.doc._element.body):self.doc._element.body.remove(node)
        self.doc._element.body.append(section)
        self.counters=[0]*4;self.labels={};self.old_sections={};self.caption_counts={'F':0,'T':0};self.references=[];self.bookmark_id=1000;self.rendered_sections=set();self.section_numbers={};self.landscape=False
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
        numbering.append(abstract);num=OxmlElement('w:num');num.set(qn('w:numId'),str(num_id));item=OxmlElement('w:abstractNumId');item.set(qn('w:val'),str(abstract_id));num.append(item);numbering.append(num);self.num_id=num_id
        for level in range(1,5):
            style=self.doc.styles['Heading '+str(level)];style.font.color.rgb=RGBColor(0,0,0)
            style.paragraph_format.keep_with_next=True
            if level==4:style.font.size=Pt(11)
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
        label='.'.join(map(str,self.counters[:level]));p=self.doc.add_heading(text,level)
        p.paragraph_format.page_break_before=page
        if self.landscape:p.paragraph_format.space_before=Pt(0);p.paragraph_format.space_after=Pt(6)
        prop=p._p.get_or_add_pPr();num=prop.get_or_add_numPr();num.get_or_add_ilvl().val=level-1;num.get_or_add_numId().val=self.num_id
        self.bookmark(p,key);self.labels[key]=label;self.section_numbers[key]=label
        if old:self.old_sections[old]=key
        return p
    def alias(self,old,key):self.old_sections[old]=key
    @staticmethod
    def normalize(text):
        for old,new in [('CTRL_X','CW_X'),('CTRL_M','CW_M'),('CTRL_W','CW_W'),('本轮完整工具复跑','阶段1至2的完整工具复跑'),('实际板卡尚未接入','实物验收已按用户要求延期'),('课程板尚未接入','实物验收已按用户要求延期'),('课程板尚未连接','实物验收已按用户要求延期'),('当前没有真实板上功能','当前尚无本CPU的真实板上功能')]:text=text.replace(old,new)
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
                if re.fullmatch(r'[\d.+/ %—:-]+',str(value)):p.alignment=WD_ALIGN_PARAGRAPH.CENTER
                for run in p.runs:run.font.size=Pt(10);run.font.bold=i==0;run.font.color.rgb=RGBColor(0,0,0)
        self.doc.add_paragraph().paragraph_format.space_after=Pt(2)
    def image(self,path,figure):
        p=self.doc.add_paragraph();p.alignment=WD_ALIGN_PARAGRAPH.CENTER;p.paragraph_format.keep_with_next=True;p.paragraph_format.space_after=Pt(3)
        p.paragraph_format.space_before=Pt(0);p.paragraph_format.line_spacing=1.0
        width=9.0 if figure in ['F01','F02'] else 6.6
        p.add_run().add_picture(str(P/path),width=Inches(width))
    def nodes(self,nodes,base_level=2,target_level=2):
        for node in nodes:
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
                elif node['caption_id']=='T15':self.table([['边界','数据','元数据与标签','CW','保存位置']]+self.plan['payload'],[.65,1.65,1.55,1.05,1.95],'T15')
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
        self.doc.add_paragraph('16位流水线CPU核心设计文档','Title')
        p=self.paragraph('默认AC1    CPU v1.6    ISA v1.5    架构版r3    2026年11月2日');self.bookmark(p,'DOC_ROOT')
        for text in [
          '本规范从指令契约、数据与状态边界、流水控制和系统验证四个层次描述一颗16位顺序单发射五级CPU。datapath_core沿用历史名称，实际包含数据通路和硬连线流水控制。设计目标是让每条指令的数据、控制意图、有效标签及副作用形成可检查的完整链条。',
          '所有被接受且未取消的指令沿IF→ID→EX→MEM→WB传递。RF和flags在WB写入；STR在MEM写DM一次，并继续保留有效WB完成标签。Stall延长停留，bubble以valid=0表示，分支和故障按年龄取消年轻指令。五级并行工作，与全局五个运行模式不是同一概念。',
          '默认生产实现固定为已验证AC1。one-hot前递和WB到MEM为两个隔离实验，后者使用自己的停顿契约；本架构整理不更改ISA、生产RTL或周期。RF影子、停止现场和VIO为观察逻辑，不参与执行。',
          '课程目标为EES-331、xc7z020clg484-1、M19/100MHz。离线功能与布局布线结果按证据范围列出；实板验收由用户延期，目标对应未确认的尝试不计CPU验证通过。',
          'RF为寄存器组，IM/DM为指令/数据存储，CU为控制职责，CW为随行操作意图。数据宽16位，指令定长16位，地址以16位字为单位；机器字与寄存器值默认十六进制。']:
            self.paragraph(text)
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
        self.paragraph('两图描述默认AC1；图中的前递选择与MUX可由同一RTL模块实现。WB到MEM候选的差异单列于性能实验，不改变此处默认load-use规则。数据与控制共用既有四个逻辑边界，图上的分层不增加寄存器。')
    def system(self):
        self.new('SYSTEM');self.alias('2.10','SYSTEM');self.alias('4.11','SYSTEM')
        self.reuse('文件启动与结果观测',body_only=True)
        self.reuse('最小系统集成与阶段2验证',body_only=True)
    def board(self):
        self.new('BOARD');self.alias('4.12','BOARD')
        self.reuse('时钟复位与观测连接',level=3)
        self.reuse('完整实现与时序覆盖',level=3)
    def verification(self):
        self.new('VERIFICATION')
        self.table([['层次','权威证据','本轮状态与限度'],
          ['源码与职责','14份默认RTL字节等于0d888cc；CW字段和时序块所有权核对','无RTL变更；控制集合不是新增总线或模块'],
          ['当前独立ISA检查','新XSim：48例、10复位见证、58结果、952逐拍行','本轮真实重跑；五个正文例直接来自该CSV'],
          ['原九套回归','0d888cc已存绑定源码的9套/19原生步骤','沿用原始执行身份，不声称本轮重跑九套'],
          ['文件启动系统','已存11程序/12 epoch、同步RAM契约、网表和工程启动','与当前14份源码一致；原结果范围保持'],
          ['板级实现与候选','AC1及两候选各五程序的已存完整布局布线','软件/硬件输入未改，不重新宣称执行P&R'],
          ['实板','用户延期；未确认目标的配置尝试已排除','没有EES-331功能或实测时间PASS']],[1.1,3.0,2.75],'N_EVIDENCE','分层验证与当前证据状态')
        self.reuse('自检查测试方法',level=3)
        self.reuse('既有实现与验证证据',level=3)
        self.reuse('统一五级与冒险验证结果',level=3)
        self.reuse('覆盖范围与集成验收',level=3)
        self.reuse('CPU功能验证程序',level=3)
    def performance(self):
        self.new('PERFORMANCE');self.reuse('CPU性能验证',level=3)
        self.table([['对象','LUT / FF / BRAM18','时序与适用范围'],
          ['历史core-only AC1','287 / 260 / 0','历史OOC WNS +2.620ns；观测扩展前，不能当整机资源'],
          ['文件启动cpu_system','376 / 431 / 2','已存系统OOC WNS +1.363ns；含IM/DM和影子'],
          ['含VIO板级AC1','五程序LUT1082～1160；FF2822～2826；BRAM18均2','完整布线setup WNS +1.434～+2.101ns；不是实物时钟或时间测量']],[1.45,2.5,2.9],'N_RESOURCE_SCOPE','三种资源和时序统计边界')
        self.reuse('固定程序与性能基线',level=3)
    def experiments(self):
        self.new('EXPERIMENTS');self.reuse('前递MUX组合候选',level=3);self.reuse('WB到MEM存储数据候选',level=3)
    def reproduce(self):
        self.new('REPRODUCE');self.alias('4.9','DESIGN_FLOW');self.alias('4.10','REPRODUCE');self.alias('4.12.6','REPRODUCE')
        self.reuse('实现验收条件',body_only=True,filter_prefixes=('观测扩展前AC1','历史AC1','课程EES-331'))
    def worked_examples(self):
        self.heading('五个实例贯通数据 CW与当拍动作',2,'CLOCKED_EXAMPLES');self.alias('3.1','CLOCKED_EXAMPLES')
        self.reuse('周期编号与PC更新',body_only=True)
        self.paragraph('以下表格使用当前默认源码新生成的独立48例CSV。阶段列以有效标签和pc读取；IF列为实际im_en请求地址。写入值由TB逐边沿与独立ISA预期比较，控制意图解释据ISA和RTL，不冒充未记录的CW总线波形。列头表示结束边沿之前所在阶段，最后一列说明该边沿动作。')
        comments={
          'DOC_ADD_ADD':'C4第一条ADD在M、第二条ADD在X，最近M非load结果可直接前递；不等待RF在C5写入，也不增加停顿。最终R0=0003、R2=0007。',
          'DOC_LOAD_STR':'C3仅保持IF/ID并给下一拍X插bubble，LDR继续进M；C5的STR从W取得load数据，C6写DM，C7仍保留STR的WB标签。默认AC1共8拍；候选的7拍属于独立新契约。',
          'DOC_CMP_JZ':'JZ在X使用M中最近CMP的候选Z=1，无需等待架构Z写回。pc2的STR被取消，不得写DM；CMP仍在WB更新Z。目标pc3的HALT按完整路径停止。',
          'DOC_STR_HALT':'C4老STR写DM且年轻HALT在X接受停止，老指令不能被HALT取消；STR在C5继续有效WB但不再写DM，HALT在C6的WB结束边沿使核心停止。',
          'MEM_FAULT_OVER_BRANCH':'C6的M级LDR完整EA=0100，访问被禁止，年轻X级JUMP不获重定向；更老W级ADD仍写R0与C/V。故障标签继续W，在C7消费后FAULTED。故障不会回滚已经完成的更老写入。'}
        for example in self.examples['examples']:
            self.heading(example['title'],3,example['id'])
            self.paragraph('初始RF：'+', '.join(f'R{i}={v:04X}'for i,v in enumerate(example['initial_rf']))+'；初始Z/C/V='+''.join(map(str,example['initial_flags']))+'。这是TB列明的用例初值，不是新增ISA指令。')
            if example['case']=='DOC_LOAD_STR':self.paragraph('DM[0020]=0007；STR的独立基址为R1=0021。')
            for text in example['instructions']:self.paragraph(text,'Code')
            self.table([['周期','IF','ID','EX','MEM','WB','结束边沿与动作']]+example['rows'],[.45,.5,.72,.72,.72,.72,2.95],'N_'+example['id'],example['case']+'实际逐拍过程')
            self.paragraph(comments[example['case']])
    def finish(self):
        for field,key in self.references:
            if key.startswith('S:'):
                old=key[2:];require(old in self.old_sections,'Unresolved old section reference: '+old);target=self.old_sections[old];value=self.labels[target]
            else:target=key;require(target in self.labels,'Unresolved caption reference: '+target);value=self.labels[target]
            field.set(qn('w:instr'),'REF ARCH_'+target+(' \\w'if key.startswith('S:')else'')+' \\h');field.find('.//'+qn('w:t')).text=value
        require(self.caption_counts['F']==12 and self.caption_counts['T']>=39,'Mature figures or tables were lost')
        self.doc.core_properties.title='16位流水线CPU核心设计文档';self.doc.core_properties.version=self.plan['revision'];self.doc.core_properties.identifier='architecture-schema-1'
        return self.doc
    def build(self):
        self.cover()
        introductions={
          'CH1':'先定义可观察的指令行为、接口和设计依赖。数据通路、译码、控制和TB都必须实现同一版本的ISA，不能混用早期Pre4映射。',
          'CH2':'本章说明值从哪里来、何时就绪、存在哪里。控制职责用于说明连接，详细动作和仲裁在第三章展开。',
          'CH3':'本章从控制模型与所有权，进入ID意图及CW传播，再说明前递、保持、取消和停止。全局模式只管理运行资格，不能把五状态当成五级执行序列。',
          'CH4':'以完整系统层次组织实现、功能及性能证据。历史、有限输入、当前新运行与尚未完成的实物验收分别说明。'}
        for n,chapter in enumerate(self.plan['chapters'],1):
            self.heading(chapter['title'],1,chapter['id'],old=str(n),page=True);self.paragraph(introductions[chapter['id']])
            for section in chapter['sections']:
                kind=section['kind'];key=section['id']
                if kind=='reuse':self.reuse(section['heading'],level=section.get('level',2),title=section.get('title'),key=key)
                elif kind=='new':self.new(key)
                elif kind=='examples':self.worked_examples()
                else:getattr(self,kind)()
        return self.finish()

def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--independent-run',type=Path,required=True);parser.add_argument('--output',type=Path,default=P/NAME);parser.add_argument('--proof-output',type=Path)
    a=parser.parse_args();plan=read(B/'architecture.json');legacy=read(B/'sections.json');content=read(B/'content.json')
    rtl=check_rtl_contract(plan);examples=extract_examples(plan,a.independent_run)
    compiler=Compiler(plan,legacy,content,examples);doc=compiler.build();doc.save(a.output)
    image_paths={r['path']for section in legacy['sections'].values()for node in section['children']for r in node.get('runs',[])if r['kind']=='image'}
    image_paths.update('架构图/'+n+'.svg'for n in ['01_CPU整体架构','02_五级Datapath','03_文件启动系统与停止观测'])
    proof={'status':'AUTHORED_PENDING_NATIVE_WORD_AND_VISUAL_QA','revision':plan['revision'],'source_files':{p.name:sha(p)for p in[B/'architecture.json',B/'sections.json',B/'content.json',B/'build_core_document.py',B/'source_validation.py']},'figure_sources':{name:sha(P/name)for name in sorted(image_paths)},'production_rtl_sha256':rtl,'examples':examples,'section_numbers':compiler.section_numbers,'caption_labels':compiler.labels,'old_section_targets':compiler.old_sections,'word_sha256_before_native_update':sha(a.output),'new_native_execution_claim':'independent48 only; not a new9-suite/P&R/board run','hardware_access_performed':False}
    if a.proof_output:a.proof_output.write_text(json.dumps(proof,ensure_ascii=False,indent=2),encoding='utf-8')
    print('ARCHITECTURE_WORD_AUTHORED '+str(a.output))
if __name__=='__main__':main()
