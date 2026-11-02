"""One-time content migration from the reviewed r2 Word, with stable section/caption IDs."""
from pathlib import Path
from io import BytesIO
import json,re,sys
from docx import Document
from docx.oxml.ns import qn
from source_validation import BASELINE,P,source_bytes,require

B=Path(__file__).resolve().parent
FIGURES={1:'架构图/01_CPU整体架构.png',2:'架构图/02_五级Datapath.png',11:'架构图/03_文件启动系统与停止观测.png',12:'架构图/04_EES331板级系统.png'}
def canonical_refs(text):
    text=re.sub(r'(图|表)\s*(\d+(?:\s*[、,，]\s*\d+)+)',lambda m:m[1]+re.sub(r'\s*[、,，]\s*','、'+m[1],m[2]),text)
    text=re.sub(r'(图|表)\s*(\d+)',lambda m:'[['+('F'if m[1]=='图'else'T')+m[2].zfill(2)+']]',text)
    text=re.sub(r'第?([1-4](?:\.\d+){1,3})\s*节',lambda m:'[[S:'+m[1]+']]',text)
    return text

def migrate(output):
    output=Path(output);assets=output/'assets'
    require(not(output/'sections.json').exists(),'Migration destination already exists; do not overwrite edited canonical content')
    require(not assets.exists()or not any(assets.iterdir()),'Migration assets already exist; refusing any overwrite')
    raw=source_bytes('CPU核心设计/16位流水线CPU核心设计文档_AC1候选版.docx');doc=Document(BytesIO(raw))
    styles={s.style_id:s.name for s in doc.styles}
    sections={};stack=[];counters=[0]*5;caption_counts={'F':0,'T':0};images=0
    output.mkdir(exist_ok=True);assets.mkdir(exist_ok=True)
    def runs(node):
        nonlocal images
        items=[];pending=[]
        def flush():
            if pending:items.append({'kind':'text','text':canonical_refs(''.join(pending))});pending.clear()
        for child in node:
            tag=child.tag.split('}')[-1]
            if tag in ['oMath','oMathPara']:
                flush();from lxml import etree
                items.append({'kind':'math','xml':etree.tostring(child,encoding='unicode')});continue
            if tag=='hyperlink':
                text=''.join(x.text or''for x in child.iter(qn('w:t')))
                rid=child.get(qn('r:id'))
                if rid:
                    flush();items.append({'kind':'link','text':text,'url':doc.part.rels[rid].target_ref})
                else:pending.append(text)
                continue
            if tag!='r':continue
            blips=list(child.iter(qn('a:blip')))
            if blips:
                flush();images+=1;part=doc.part.related_parts[blips[0].get(qn('r:embed'))]
                path=FIGURES.get(images)
                if path is None:
                    extension='.png'if part.content_type=='image/png'else'.jpg'
                    target=assets/(f'F{images:02d}'+extension);target.write_bytes(part.blob)
                    path=target.relative_to(P).as_posix()
                items.append({'kind':'image','figure':f'F{images:02d}','path':path})
                continue
            for element in child:
                local=element.tag.split('}')[-1]
                if local=='t':pending.append(element.text or'')
                elif local=='br':pending.append('\n')
                elif local=='tab':pending.append('\t')
        flush();return items
    for element in doc._element.body:
        if element.tag==qn('w:p'):
            pstyle=element.find('w:pPr/w:pStyle',doc._element.nsmap)
            style=styles.get(pstyle.get(qn('w:val')),'Normal')if pstyle is not None else'Normal'
            text=''.join(x.text or''for x in element.iter(qn('w:t')))
            if style.startswith('Heading '):
                level=int(style[-1]);counters[level-1]+=1
                for n in range(level,5):counters[n]=0
                key=text;require(key not in sections,'Duplicate legacy heading key: '+key)
                section={'title':text,'level':level,'old_number':'.'.join(map(str,counters[:level])),'children':[]};sections[key]=section
                while stack and stack[-1][0]>=level:stack.pop()
                if stack:sections[stack[-1][1]]['children'].append({'section':key})
                stack.append((level,key));continue
            if not stack:continue
            if style=='Caption':
                match=re.match(r'([图表])\s*(\d+)\s*(.*)',text)
                require(match is not None,'Unrecognized caption: '+text)
                prefix='F'if match[1]=='图'else'T';caption_counts[prefix]+=1
                require(int(match[2])==caption_counts[prefix],'Caption order differs')
                node={'kind':'caption','id':prefix+match[2].zfill(2),'title':canonical_refs(match[3])}
            else:
                contents=runs(element)
                if not contents:continue
                node={'kind':'paragraph','style':'Code'if style=='Code'else'Normal','runs':contents}
            sections[stack[-1][1]]['children'].append(node)
        elif element.tag==qn('w:tbl') and stack:
            from docx.table import Table
            table=Table(element,doc._body)
            widths=[round(col.width/914400,3)for col in table.columns]
            rows=[[canonical_refs('\n'.join(p.text for p in cell.paragraphs))for cell in row.cells]for row in table.rows]
            sections[stack[-1][1]]['children'].append({'kind':'table','caption_id':f'T{caption_counts["T"]:02d}','widths':widths,'rows':rows})
    require(images==12 and caption_counts=={'F':12,'T':39},'Baseline figures/tables lost during migration')
    result={'schema':1,'source_commit':BASELINE,'maintenance':'Section keys and caption IDs are stable anchors. Edit titles/paragraphs/rows here; chapter order is architecture.json. No paragraph offsets are used.','sections':sections}
    target=output/'sections.json';require(not target.exists(),'Migration destination already exists; do not overwrite edited canonical content')
    target.write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding='utf-8')
    print('BASELINE_CONTENT_MIGRATED sections='+str(len(sections))+' figures=12 tables=39')
if __name__=='__main__':migrate(B)
