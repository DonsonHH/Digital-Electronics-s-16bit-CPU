"""Static Word/cross-reference/source validation; visual QA remains a separate mandatory gate."""
from pathlib import Path
import argparse,json,re,zipfile
from lxml import etree
from docx import Document
from source_validation import P,read,require,sha,check_rtl_contract
from document_content import body_content_digest
B=Path(__file__).resolve().parent

def validate(path,proof_path=None):
    plan=read(B/'architecture.json');check_rtl_contract(plan);doc=Document(path)
    require(doc.core_properties.version==plan['revision'],'Word revision does not match architecture source')
    h1=[p.text for p in doc.paragraphs if p.style.name=='Heading 1']
    require(h1==[chapter['title']for chapter in plan['chapters']],'The four top-level chapters differ')
    xml=etree.fromstring(zipfile.ZipFile(path).read('word/document.xml'));ns={'w':'http://schemas.openxmlformats.org/wordprocessingml/2006/main','m':'http://schemas.openxmlformats.org/officeDocument/2006/math'}
    names=xml.xpath('//w:bookmarkStart/@w:name',namespaces=ns);require(len(names)==len(set(names)),'Duplicate Word bookmark names')
    required={'ARCH_DOC_ROOT','ARCH_OVERVIEW','ARCH_PAYLOAD','ARCH_CONTROL_LAYERS','ARCH_CW_CLASSIFICATION','ARCH_SYSTEM','ARCH_BOARD','ARCH_VERIFICATION','ARCH_PERFORMANCE','ARCH_EXPERIMENTS'}|{'ARCH_'+e['id']for e in plan['examples']}
    require(required<=set(names),'Required architecture anchors are missing')
    instructions=xml.xpath('//w:instrText/text()|//w:fldSimple/@w:instr',namespaces=ns)
    refs=re.findall(r'(?<![A-Z])REF\s+(\w+)',' '.join(instructions));require(set(refs)<=set(names),'Cross-reference target missing')
    table_fields=[s for s in instructions if re.search(r'\bSEQ\s+Table\b',s)];figure_fields=[s for s in instructions if re.search(r'\bSEQ\s+Figure\b',s)]
    require(len(table_fields)==len(doc.tables)==50,'Mature/new tables lost or duplicated')
    require(len(figure_fields)==len(doc.inline_shapes)==12,'Mature figures lost or duplicated')
    text=''.join(xml.xpath('//w:t/text()',namespaces=ns))
    for bad in ['[[','ARCH_PENDING','错误!','未找到引用源','Error!','原if优先级和四态行为保持','RF影子、停止现场和VIO为观察逻辑，不参与执行']:
        require(bad not in text,'Unresolved or inaccurate document content: '+bad)
    require(not re.search(r'表\d+[、，,]\d',text),'Unanchored member in a multiple-table reference')
    require('VIO的独立复位输出' in text and 'core_reset' in text,'VIO reset control was incorrectly merged into passive observation')
    require(len(xml.xpath('//m:oMath',namespaces=ns))>=1,'Native Word equation was lost')
    if proof_path:
        proof=read(proof_path)
        for name,digest in proof['source_files'].items():require(sha(B/name)==digest,'Document authoring input changed: '+name)
        for name,digest in proof['figure_sources'].items():require(sha(P/name)==digest,'Document figure source changed: '+name)
        require(body_content_digest(doc)==proof['word_body_content_sha256'],'Word body no longer matches the authored architecture content')
    return dict(status='STATIC_WORD_CHECKS_PASS_VISUAL_QA_SEPARATE',chapters=h1,tables=len(doc.tables),figures=len(doc.inline_shapes),reference_fields=len(refs),toc_entries=sum(p.style.name.lower().startswith('toc ')for p in doc.paragraphs),section_count=len(doc.sections),hardware_access_performed=False)

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--document',type=Path,required=True);p.add_argument('--proof',type=Path);p.add_argument('--output',type=Path);a=p.parse_args();r=validate(a.document,a.proof)
    if a.output:a.output.write_text(json.dumps(r,ensure_ascii=False,indent=2),encoding='utf-8')
    print(json.dumps(r,ensure_ascii=False))
if __name__=='__main__':main()
