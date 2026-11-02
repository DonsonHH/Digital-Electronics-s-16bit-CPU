"""Check the published Pre6 files against frozen evidence; never runs CPU or hardware."""
from pathlib import Path
import csv
import hashlib
import io
import json
import re
import subprocess
import xml.etree.ElementTree as ET
import zipfile

B = Path(__file__).resolve().parent
OUT = B.parent
ROOT = OUT.parent
NS = {
    'a': 'http://schemas.openxmlformats.org/drawingml/2006/main',
    'p': 'http://schemas.openxmlformats.org/presentationml/2006/main',
    'c': 'http://schemas.openxmlformats.org/drawingml/2006/chart',
    'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main',
    's': 'http://schemas.openxmlformats.org/spreadsheetml/2006/main',
}


def digest(p):
    return hashlib.sha256(Path(p).read_bytes()).hexdigest()


def load(name):
    return json.loads((B / name).read_text(encoding='utf-8'))


def main():
    e, c, source_map = load('evidence.json'), load('content.json'), load('source_map.json')
    baseline = e['baseline_commit']
    assert subprocess.check_output(
        ['git', 'rev-parse', e['tag'] + '^{}'], cwd=ROOT, text=True).strip() == baseline
    for name, expected in e['input_sha256'].items():
        assert digest(ROOT / name) == expected, name
        frozen = subprocess.check_output(['git', 'show', baseline + ':' + Path(name).as_posix()], cwd=ROOT)
        assert hashlib.sha256(frozen).hexdigest() == expected, name
    assert len(source_map) == 20 and all(row['sources'] for row in source_map)
    assert len(c['main']) == 12 and len(c['backup']) == 8
    assert sum(row['seconds'] for row in c['main']) == 840 and c['buffer_seconds'] == 60
    expected_programs = [
        ('all_ops', 16, 1, 2, 25), ('baseline', 10, 1, 1, 17),
        ('loop', 18, 0, 4, 30), ('memory_copy', 7, 2, 1, 15),
        ('copy_checksum', 35, 16, 0, 55),
    ]
    assert [tuple(row[k] for k in ['program', 'N', 'S', 'R', 'C']) for row in e['programs']] == expected_programs
    assert all(r['C'] == r['N'] + 4 + r['S'] + 2 * r['R'] for r in e['programs'])
    tsv = ROOT / 'CPU核心设计/验证/hardware_ac1_20261102_3dw9zgb5/button_snapshots.tsv'
    with tsv.open(encoding='utf-8-sig', newline='') as f:
        assert list(csv.DictReader(f, fieldnames=['label', 'timestamp_ms', 'state256_hex', 'perf160_hex'], delimiter='\t')) == e['raw_button']
    ppt = OUT / 'Pre6_Group2_CPU_Integration_EN.pptx'
    word = OUT / 'Pre6_英文讲稿与答辩.docx'
    finalization = load('核对/presentation-finalization.json')
    assert digest(ppt) == finalization['finalSha256']
    assert finalization['packageIntegrity']['finding_count'] == 0
    assert finalization['presentationLayout']['finding_count'] == 0
    for name in ['01_CPU整体架构.svg', '02_五级Datapath.svg', '03_文件启动系统与停止观测.svg', '04_EES331板级系统.svg']:
        assert digest(B / '图源' / name) == e['input_sha256']['CPU核心设计/架构图/' + name]
    assert 'PRIVATE_COPY_SAVE_REOPEN=PASS' in (B / '核对/native_powerpoint.txt').read_text(encoding='utf-8-sig')
    assert 'PAGES=10' in (B / '核对/native_word.txt').read_text(encoding='utf-8-sig')
    with zipfile.ZipFile(ppt) as z:
        slides = sorted((n for n in z.namelist() if re.fullmatch(r'ppt/slides/slide\d+\.xml', n)), key=lambda n: int(re.search(r'(\d+)\.xml', n)[1]))
        notes = [n for n in z.namelist() if re.fullmatch(r'ppt/notesSlides/notesSlide\d+\.xml', n)]
        assert len(slides) == len(notes) == 20
        tables, charts = 0, []
        for i, name in enumerate(slides, 1):
            xml = ET.fromstring(z.read(name))
            tables += len(xml.findall('.//a:tbl', NS))
            visible = ' '.join(t.text or '' for t in xml.findall('.//a:t', NS))
            assert (c['main'] + c['backup'])[i-1]['title'] in visible
            assert not re.search(r'[\u4e00-\u9fff]', visible), name
            note = ET.fromstring(z.read(f'ppt/notesSlides/notesSlide{i}.xml'))
            note_text = '\n'.join(t.text or '' for t in note.findall('.//a:t', NS))
            cfg = (c['main'] + c['backup'])[i-1]
            assert cfg.get('speech', cfg.get('answer')) in note_text
            for ref in source_map[i-1]['sources']:
                assert ref['relative'] in note_text and ref['sha256'] in note_text
        for name in z.namelist():
            if name.endswith('.xml') and '/charts/' in name and '/_rels/' not in name:
                xml = ET.fromstring(z.read(name))
                if xml.tag == '{' + NS['c'] + '}chartSpace':
                    charts.append(xml)
        assert tables == 16 and len(charts) == 1
        expected_series = [[r['N'] for r in e['programs']], [4]*5,
                           [r['S'] for r in e['programs']], [2*r['R'] for r in e['programs']]]
        series = charts[0].findall('.//c:ser', NS)
        assert len(series) == 4
        for xml, expected in zip(series, expected_series):
            assert [int(v.text) for v in xml.findall('c:val/c:numRef/c:numCache/c:pt/c:v', NS)] == expected
        embeds = [n for n in z.namelist() if n.startswith('ppt/embeddings/') and n.endswith('.xlsx')]
        assert len(embeds) == 1
        with zipfile.ZipFile(io.BytesIO(z.read(embeds[0]))) as book:
            cells = ET.fromstring(book.read('xl/worksheets/sheet1.xml'))
            values = {el.attrib['r']: int(el.find('s:v', NS).text) for el in cells.findall('.//s:c', NS) if el.find('s:v', NS) is not None}
            for col, expected in zip('BDFH', expected_series):
                assert [values[f'{col}{row}'] for row in range(2, 7)] == expected
        assert not any(n.startswith('ppt/media/') for n in z.namelist()), 'Unexpected raster substitute'
    with zipfile.ZipFile(word) as z:
        xml = ET.fromstring(z.read('word/document.xml'))
        paragraphs = [''.join(t.text or '' for t in p.findall('.//w:t', NS)) for p in xml.findall('.//w:p', NS)]
        assert all(row['speech'] in paragraphs for row in c['main'])
        assert all(row['answer'] in paragraphs for row in c['backup'])
        assert all(answer in paragraphs for _, answer in c['questions'])
    timing = []
    for row in c['main']:
        words = len(re.findall(r"[A-Za-z0-9]+(?:['.-][A-Za-z0-9]+)*", row['speech']))
        timing.append(dict(slide=len(timing)+1, speaker=row['speaker'], budget_seconds=row['seconds'], words=words,
                           speech_seconds_at_105wpm=round(words/105*60, 1),
                           pointer_pause_budget_at_105wpm=round(row['seconds']-words/105*60, 1)))
    assert sum(x['words'] for x in timing) == c['spoken_words'] == 1199
    report = dict(status='pass', frozen_inputs=len(e['input_sha256']), slides=20, main=12, backup=8,
                  native_tables=tables, editable_charts=1, chart_workbooks=1, numeric_chart_points=20,
                  note_parts=20, speech_note_word_alignment='pass', source_refs='pass',
                  new_CPU_simulation=False, new_hardware_execution=False,
                  timing_model=dict(words=1199, speech_budget_seconds=840, buffer_seconds=60,
                                    human_rehearsal='not performed', slides=timing),
                  deliverable_sha256={ppt.name: digest(ppt), word.name: digest(word)})
    out = B / '核对/delivery_check.json'
    out.parent.mkdir(exist_ok=True)
    out.write_text(json.dumps(report, ensure_ascii=False, indent=2)+'\n', encoding='utf-8')
    print(json.dumps({k: report[k] for k in ['status', 'frozen_inputs', 'slides', 'native_tables', 'editable_charts', 'speech_note_word_alignment']}, ensure_ascii=False))


if __name__ == '__main__':
    main()
