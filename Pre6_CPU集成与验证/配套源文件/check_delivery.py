"""Recheck published Pre6 artifacts and retained raw evidence; no native or hardware execution."""
from pathlib import Path
import argparse,csv,hashlib,io,json,posixpath,re,subprocess,zipfile
import xml.etree.ElementTree as ET
from datetime import datetime,timezone
from PIL import Image
from collect_v3 import actual_trace
from attempt_history import review_attempt_history
from baseline_evidence import source_bytes

B=Path(__file__).resolve().parent;OUT=B.parent;ROOT=OUT.parent
NS={'a':'http://schemas.openxmlformats.org/drawingml/2006/main',
    'p':'http://schemas.openxmlformats.org/presentationml/2006/main',
    'c':'http://schemas.openxmlformats.org/drawingml/2006/chart',
    'w':'http://schemas.openxmlformats.org/wordprocessingml/2006/main',
    's':'http://schemas.openxmlformats.org/spreadsheetml/2006/main'}


def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def load(p):return json.loads(p.read_text(encoding='utf-8-sig'))
def verify_hashes(root,items,frozen_document_baseline=None):
    for relative,digest in items.items():
        actual=hashlib.sha256(source_bytes(relative,frozen_document_baseline)).hexdigest()if frozen_document_baseline else sha(root/relative)
        assert actual==digest,relative


def validate_pass_attempt(path,record):
    assert record['kind']in ['cpu','board']and record['mode']in ['create','behavioral','synthesis','full']
    assert record['archived_input_sha256']and record['output_sha256']
    assert record['physical_board_execution']is False
    log=(path.parent/'outputs/vivado.log').read_text(encoding='utf-8',errors='replace')
    assert f"PRE6_R3_FLOW_COMPLETE kind={record['kind']} mode={record['mode']}"in log
    assert not re.search(r'(?m)^ERROR:|^CRITICAL WARNING:|^Fatal:',log)
    if record['mode']=='create':return
    assert '$finish called at time'in log
    keys=['CYCLES','N','STALLS','REDIRECTS','STORES'];expected=record['expected']
    label='PRE6_CPU_PASS'if record['kind']=='cpu'else'PRE6_BOARD_SIM_PASS'
    values=' '.join(f'{k}={expected[v]}'for k,v in zip(['cycles','completed','stalls','redirects','stores'],keys))
    marker=f"{label} program={record['program']} {values}"
    epochs=2 if record['kind']=='cpu'and record['mode']in ['synthesis','full']else 1
    assert len(re.findall('^'+re.escape(marker)+'$',log,re.M))==epochs
    assert record['native_checked_epochs']==epochs
    if record['kind']=='cpu':
        trace=actual_trace(path.parent)
        assert len(trace['rows'])==expected['CYCLES']and trace['rf']==expected['rf']and trace['flags']==expected['flags']
        if record['mode']in ['synthesis','full']:assert record['synthesis']==record['post_synthesis_functional']=='PASS'
    elif record['mode']=='full':
        assert record['implementation']=='PASS'and record['bitstream']=='GENERATED_NOT_PROGRAMMED'
        assert any(name.endswith('.bit')for name in record['output_sha256'])


def write_failure(path,error):
    path.parent.mkdir(parents=True,exist_ok=True)
    path.write_text(json.dumps(dict(status='FAIL',checked_utc=datetime.now(timezone.utc).isoformat(),
                    error=repr(error),scope='Current delivery check failed; any earlier PASS is superseded.'),ensure_ascii=False,indent=2)+'\n',encoding='utf-8')


def start_report(path):
    path.parent.mkdir(parents=True,exist_ok=True)
    path.write_text(json.dumps(dict(status='RUNNING',checked_utc=datetime.now(timezone.utc).isoformat(),
                    scope='Current check has not completed; earlier PASS is superseded.'),indent=2)+'\n',encoding='utf-8')


def main():
    parser=argparse.ArgumentParser();parser.add_argument('--with-course',action='store_true');args=parser.parse_args()
    start_report(B/'核对/delivery_check.json')
    e,c,m=map(load,[B/'evidence.json',B/'content.json',B/'source_map.json'])
    assert subprocess.check_output(['git','rev-parse',e['tag']+'^{}'],cwd=ROOT,text=True).strip()==e['baseline_commit']
    for relative,digest in e['input_sha256'].items():
        assert hashlib.sha256(source_bytes(relative,e['baseline_commit'])).hexdigest()==digest,relative
        blob=subprocess.check_output(['git','show',e['baseline_commit']+':'+Path(relative).as_posix()],cwd=ROOT)
        assert hashlib.sha256(blob).hexdigest()==digest,relative
    verify_hashes(ROOT,e['additional_source_sha256'])
    assert len(c['main'])==len(m)==24 and c['backup']==[] and c['revision']=='Pre6-r5'
    assert sum(r['seconds']for r in c['main'])==840 and c['buffer_seconds']==60
    assert c['main'][1]['title']=='Contents'
    assert [r['code']for r in c['main'][2:]]==['1.1','1.2','2.1','3.1','3.1.1','3.1.2','3.2','3.2.1','3.3','3.3.1','3.3.2','3.3.3','3.3.4','3.3.5','4.1','4.2','4.3','5.1','5.2','5.3','5.4','6.1']
    expected=[('all_ops',16,1,2,25),('baseline',10,1,1,17),('loop',18,0,4,30),('memory_copy',7,2,1,15),('copy_checksum',35,16,0,55)]
    assert [tuple(r[k]for k in ['program','N','S','R','C'])for r in e['programs']]==expected
    assert all(r['C']==r['N']+4+r['S']+2*r['R']for r in e['programs'])
    for row in m:
        assert row['sources']
        verify_hashes(ROOT,{r['relative']:r['sha256']for r in row['sources']},frozen_document_baseline=e['baseline_commit'])
    assert all('REFERENCE'in m[i-1]['source_groups']for i in [17,18,19])
    with (ROOT/'CPU核心设计/验证/hardware_ac1_20261102_3dw9zgb5/button_snapshots.tsv').open(encoding='utf-8-sig',newline='')as f:
        assert list(csv.DictReader(f,fieldnames=['label','timestamp_ms','state256_hex','perf160_hex'],delimiter='\t'))==e['raw_button']
    ppt=OUT/'Pre6_Group2_CPU_Integration_EN.pptx';word=OUT/'Pre6_英文讲稿与答辩.docx'
    finalized=load(B/'核对/presentation-finalization.json')
    assert sha(ppt)==finalized['finalSha256']
    assert finalized['packageIntegrity']['finding_count']==finalized['presentationLayout']['finding_count']==0
    ppstats=(B/'核对/native_powerpoint.txt').read_text(encoding='utf-8-sig')
    assert all(s in ppstats for s in ['SLIDES=24','NATIVE_TABLES=18','NATIVE_CHARTS=2','PRIVATE_COPY_SAVE_REOPEN=PASS'])
    word_pages=int(re.search(r'PAGES=(\d+)',(B/'核对/native_word.txt').read_text(encoding='utf-8-sig'))[1]);assert word_pages>0
    chart_points=0
    with zipfile.ZipFile(ppt)as z:
        slides=sorted([n for n in z.namelist()if re.fullmatch(r'ppt/slides/slide\d+\.xml',n)],key=lambda n:int(re.search(r'(\d+)\.xml',n)[1]))
        notes=[n for n in z.namelist()if re.fullmatch(r'ppt/notesSlides/notesSlide\d+\.xml',n)]
        assert len(slides)==len(notes)==24
        tables=0;chart_owners=[]
        for i,name in enumerate(slides,1):
            xml=ET.fromstring(z.read(name));tables+=len(xml.findall('.//a:tbl',NS))
            visible=' '.join(t.text or''for t in xml.findall('.//a:t',NS))
            assert c['main'][i-1]['title']in visible and xml.get('show','1')!='0'
            if i==4:assert 'Rd and Rs (Rs1 and Rs2)'in visible
            if i==19:
                assert '35 + 4 + 16 + 2×0 = 55'in visible
                photos=xml.findall('.//p:pic',NS)
                assert len(photos)==1
                rid=photos[0].find('.//a:blip',NS).get('{http://schemas.openxmlformats.org/officeDocument/2006/relationships}embed')
                relationships=ET.fromstring(z.read('ppt/slides/_rels/slide19.xml.rels'))
                target=next(row.get('Target')for row in relationships if row.get('Id')==rid)
                part=target.lstrip('/')if target.startswith('/')else posixpath.normpath(posixpath.join('ppt/slides',target))
                assert hashlib.sha256(z.read(part)).hexdigest()==sha(B/'图源/r3/EES331_平台图_手册.png')
                transform=photos[0].find('p:spPr/a:xfrm',NS)
                assert int(transform.get('rot','0'))==180*60000 and all(transform.get(k,'0')in ['0','false']for k in ['flipH','flipV'])
            assert not re.search(r'[\u4e00-\u9fff]',visible),name
            if xml.findall('.//c:chart',NS):chart_owners.append(i)
            note=ET.fromstring(z.read(f'ppt/notesSlides/notesSlide{i}.xml'))
            text='\n'.join(t.text or''for t in note.findall('.//a:t',NS))
            assert c['main'][i-1]['speech']in text
            assert all(r['relative']in text and r['sha256']in text for r in m[i-1]['sources'])
        assert tables==18 and chart_owners==[21,23]
        chart_names=sorted([n for n in z.namelist()if '/charts/'in n and '/_rels/'not in n and n.endswith('.xml')])
        assert len(chart_names)==2
        expected_series=[[[r['N']for r in e['programs']],[4]*5,[r['S']for r in e['programs']],[2*r['R']for r in e['programs']]],[[15,55],[14,47]]]
        for name,wanted in zip(chart_names,expected_series):
            chart=ET.fromstring(z.read(name));series=chart.findall('.//c:ser',NS);assert len(series)==len(wanted)
            rels=ET.fromstring(z.read(posixpath.dirname(name)+'/_rels/'+posixpath.basename(name)+'.rels'))
            external=chart.find('c:externalData',NS)
            rid=external.get('{http://schemas.openxmlformats.org/officeDocument/2006/relationships}id')
            target=next(x.get('Target')for x in rels if x.get('Id')==rid)
            book_path=target.lstrip('/')if target.startswith('/')else posixpath.normpath(posixpath.join(posixpath.dirname(name),target))
            with zipfile.ZipFile(io.BytesIO(z.read(book_path)))as book:
                sheet=ET.fromstring(book.read('xl/worksheets/sheet1.xml'))
                cells={x.get('r'):float(x.find('s:v',NS).text)for x in sheet.findall('.//s:c',NS)if x.find('s:v',NS)is not None}
            for s,values in zip(series,wanted):
                assert [float(v.text)for v in s.findall('c:val/c:numRef/c:numCache/c:pt/c:v',NS)]==values
                formula=s.find('c:val/c:numRef/c:f',NS).text
                match=re.search(r'!\$?([A-Z]+)\$?(\d+):\$?([A-Z]+)\$?(\d+)$',formula);assert match,formula
                col,start,other,end=match.groups();assert col==other
                assert [cells[f'{col}{i}']for i in range(int(start),int(end)+1)]==values
                chart_points+=len(values)
        images=[n for n in z.namelist()if n.startswith('ppt/media/')]
        assert len(images)==9
        embedded=set()
        for n in images:
            blob=z.read(n);assert blob;Image.open(io.BytesIO(blob)).verify();embedded.add(hashlib.sha256(blob).hexdigest())
        for name in ['CPU_整体架构_中文.png','CPU_五级Datapath_中文.png','ISA_官网编码表.png','baseline_waveform.png']:
            assert sha(B/'图源/r3'/name)in embedded,name
    with zipfile.ZipFile(word)as z:
        xml=ET.fromstring(z.read('word/document.xml'));paragraphs=[''.join(t.text or''for t in p.findall('.//w:t',NS))for p in xml.findall('.//w:p',NS)]
        assert all(row['speech']in paragraphs for row in c['main'])
        assert all(answer in paragraphs for _,answer in c['questions'])
        assert any('Run Synthesis应完成且无错误'in p for p in paragraphs)
        assert any('stall=observe_stall'in p and 'frontend_kill'in p for p in paragraphs)
        for who,cfg in c['team'].items():
            assert any(cfg['prepare']in p for p in paragraphs)and any(cfg['check']in p for p in paragraphs),who
    timing=[]
    for i,r in enumerate(c['main'],1):
        words=len(re.findall(r"[A-Za-z0-9]+(?:['.-][A-Za-z0-9]+)*",r['speech']))
        timing.append(dict(slide=i,speaker=r['speaker'],budget_seconds=r['seconds'],words=words,speech_seconds_at_105wpm=round(words/105*60,1)))
    assert sum(r['words']for r in timing)==c['spoken_words'] and 1200<=c['spoken_words']<=1350
    package=OUT/'Vivado';inventory=load(package/'source_manifest.json')
    verify_hashes(package,inventory['sha256'])
    for name,source in inventory['source_mapping'].items():assert sha(package/name)==sha(ROOT/source),name
    ports=load(package/'rtl/pre6_cpu_top.port-map.json');assert len(ports['ports'])==len(ports['mappings'])==34
    raw=load(B/'核对/运行核对.json');verify_hashes(B,raw['sha256'])
    acceptance=raw['project_acceptance']
    for row in acceptance['records']:
        relative=(package/row['relative']).relative_to(ROOT).as_posix()
        blob=subprocess.check_output(['git','show',acceptance['source_commit']+':'+relative],cwd=ROOT)
        assert hashlib.sha256(blob).hexdigest()==row['sha256'],relative
    history=review_attempt_history(package,acceptance['records'],validate_pass_attempt)
    if history['status']!='PASS':raise RuntimeError('Latest attempt has no PASS: '+json.dumps(history['latest_nonpass'],ensure_ascii=False))
    targeted=raw['R5_targeted_execution'];targeted_path=OUT/targeted['result']
    assert sha(targeted_path)==targeted['sha256']
    targeted_result=load(targeted_path)
    assert targeted_result['status']=='PASS'and targeted_result['actual']==targeted['actual']
    runs=history['validated_passes']
    assert history['published_acceptance_records']==8
    assert {r['program']for r in runs if r['kind']=='cpu'and r['mode']=='behavioral'}>={r[0]for r in expected}
    core=load(B/'核对/运行证据/core_replay/result.json')
    assert core['status']=='PASS'and len(core['steps'])==6 and all(r['exit']==0 for r in core['steps'])
    verify_hashes(ROOT/'CPU核心设计/Vivado',core['source_sha256'])
    for step in core['steps']:assert sha(B/f"核对/运行证据/core_replay/{step['suite']}.console.log")==step['log_sha256']
    cpu=(B/'核对/运行证据/cpu_gui/native.log').read_text(encoding='utf-8',errors='replace')
    assert all(x in cpu for x in ['GUI_BEHAVIORAL_PASS=first','GUI_BEHAVIORAL_PASS=after_reset','GUI_SYNTHESIS_PASS=first','GUI_SYNTHESIS_PASS=after_reset','GUI_POST_SYNTH_PASS'])
    assert cpu.count('PRE6_CPU_PASS program=copy_checksum cycles=55 completed=35 stalls=16 redirects=0 stores=8')==3
    board=(B/'核对/运行证据/ees331_gui/native.log').read_text(encoding='utf-8',errors='replace')
    assert 'GUI_BOARD_TIMING setup=1.530 hold=0.073'in board and 'PRE6_BOARD_GUI_ACCEPTANCE_COMPLETE'in board
    assert all(not re.search(r'(?m)^ERROR:|^CRITICAL WARNING:|^Fatal:',log)for log in [cpu,board])
    review=load(B/'核对/render_review.json')
    assert review['PPT_native_pages_reviewed']==24 and review['Word_native_pages_reviewed']==word_pages
    assert review['deliverable_sha256']=={ppt.name:sha(ppt),word.name:sha(word)}
    course_count=0
    if args.with_course:
        course=Path(r'D:/OneDrive - University of Glasgow/同步文件夹/大三上/Courses/数电')
        for p in OUT.rglob('*'):
            if p.is_file()and '__pycache__'not in p.parts and not p.name.startswith('~$')and p.name!='delivery_check.json':
                assert sha(p)==sha(course/p.relative_to(ROOT)),str(p.relative_to(ROOT));course_count+=1
    report=dict(status='PASS',revision=c['revision'],frozen_inputs=len(e['input_sha256']),slides=24,notes=24,native_tables=18,editable_charts=2,chart_workbooks=2,chart_numeric_points=chart_points,embedded_images=9,
                production_RTL_unchanged=len(inventory['source_mapping']),port_mappings=34,source_refs='PASS',speech_note_word_alignment='PASS',native_project_runs=runs,attempt_history=history,core_replay_suites=core['suites'],GUI_CPU_repeat_and_post_synthesis='PASS',GUI_board_bitstream='GENERATED_NOT_PROGRAMMED',new_physical_board_execution=False,
                timing_model=dict(words=c['spoken_words'],speech_budget_seconds=840,buffer_seconds=60,human_rehearsal='not performed',slides=timing),team=c['team'],course_files_compared=course_count,deliverable_sha256=review['deliverable_sha256'])
    (B/'核对/delivery_check.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print(json.dumps({k:report[k]for k in ['status','revision','slides','native_tables','editable_charts','chart_numeric_points','course_files_compared']},ensure_ascii=False))


if __name__=='__main__':
    try:main()
    except Exception as error:
        write_failure(B/'核对/delivery_check.json',error)
        raise
