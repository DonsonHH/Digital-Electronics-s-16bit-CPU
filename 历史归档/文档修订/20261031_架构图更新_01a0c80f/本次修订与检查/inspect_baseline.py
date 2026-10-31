from pathlib import Path
from docx import Document
from lxml import etree as ET
import hashlib, json

WORK=Path(__file__).parent
ROOT=Path(r'D:\OneDrive - University of Glasgow\同步文件夹\大三上\Courses\数电')
CORE=ROOT/'CPU核心设计'
doc=Document(WORK/'source.docx')
lines=[]
for i,p in enumerate(doc.paragraphs):
    lines.append(f'P{i} [{p.style.name}] {p.text}')
    if p._p.xpath('.//w:bookmarkStart'):
        lines.append('BOOKMARK '+str([(b.get('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}name'), b.get('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}id')) for b in p._p.xpath('.//w:bookmarkStart')]))
    if p._p.xpath('.//w:drawing'):
        lines.append('DRAWING '+ET.tostring(p._p,encoding='unicode'))
for i,t in enumerate(doc.tables):
    lines.append(f'TABLE {i+1}\n'+'\n'.join(' | '.join(c.text for c in r.cells) for r in t.rows))
(WORK/'baseline_text.txt').write_text('\n'.join(lines),encoding='utf-8')
snapshot={}
for base in [CORE, ROOT/'Pre5_控制单元设计'/'Vivado']:
    for p in base.rglob('*'):
        if p.is_file() and not p.name.startswith('~$'):
            snapshot[p.relative_to(ROOT).as_posix()]={'size':p.stat().st_size,'sha256':hashlib.sha256(p.read_bytes()).hexdigest()}
(WORK/'baseline_files.json').write_text(json.dumps(snapshot,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps({'paragraphs':len(doc.paragraphs),'tables':len(doc.tables),'figures':len(doc.inline_shapes),'files':len(snapshot),'styles':list({p.style.name for p in doc.paragraphs if p.style.name.startswith('Heading')})},ensure_ascii=False))
print('SECTION',ET.tostring(doc.sections[0]._sectPr,encoding='unicode'))
