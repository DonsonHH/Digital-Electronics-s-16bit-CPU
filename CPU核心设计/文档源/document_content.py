"""Content identity across native Word field/TOC updates; formatting is reviewed separately."""
import hashlib,json,re
from docx.oxml.ns import qn

def body_content_digest(document):
    styles={s.style_id:s.name for s in document.styles};rows=[]
    for p in document._element.body.iter(qn('w:p')):
        style=p.find(qn('w:pPr')+'/'+qn('w:pStyle'))
        name=styles.get(style.get(qn('w:val')),'Normal')if style is not None else'Normal'
        if name.lower().startswith('toc '):continue
        if any(re.search(r'\bTOC\b',t.text or'')for t in p.iter(qn('w:instrText'))):continue
        text=''.join(t.text or''for t in p.iter()if t.tag in [qn('w:t'),qn('m:t')])
        text=re.sub(r'\s+',' ',text).strip()
        if text:rows.append([name if name.startswith('Heading ')or name in ['Code','Caption']else'Normal',text])
    return hashlib.sha256(json.dumps(rows,ensure_ascii=False,separators=(',',':')).encode('utf-8')).hexdigest()
