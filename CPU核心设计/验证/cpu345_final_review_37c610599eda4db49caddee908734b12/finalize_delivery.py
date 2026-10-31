"""Record this delivery after native Word visual QA; do not rerun HDL/device jobs."""
from pathlib import Path
import datetime,hashlib,json,re,shutil,subprocess,sys,uuid
from docx import Document
from pypdf import PdfReader
ROOT=Path(sys.argv[1]).resolve();QA=Path(__file__).resolve().parent;P=ROOT/'CPU核心设计'
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def read(p):return json.loads(Path(p).read_text(encoding='utf-8'))
def run(args,log):
    result=subprocess.run([sys.executable,'-B','-X','utf8']+list(map(str,args)),cwd=ROOT,stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
    log.write_bytes(result.stdout)
    if result.returncode:raise RuntimeError('Final check failed: '+str(args[0]))
    return dict(exit=result.returncode,console_sha256=sha(log))
base=P/'验证/performance_ac1_9b449e40f5d44bd78936f207953b77d6/result.json'
fwd=P/'实验/前递候选比较.json';wb=P/'实验/WB_MEM候选比较.json'
run([P/'板级/compare_forward_results.py','--baseline',base,'--candidate',P/'验证/performance_forward_onehot_64e1934ab4654bd58c4063cfbd0583ec/result.json',
     '--core-trial',P/'验证/cpu345_coretrial_mhffl2fp/result.json','--traces',P/'验证/traces_forward_onehot_e9d25b820522486fa3f5c4ea44a2bbc5/result.json',
     '--output',QA/'forward_recomputed.json'],QA/'forward_recheck.console.log')
assert read(QA/'forward_recomputed.json')==read(fwd)
run([P/'板级/compare_wb_results.py','--baseline',base,'--candidate',P/'验证/performance_wb_mem_9107d27100194667a0734312336b3952/result.json',
     '--validation',P/'验证/wb_mem_validation_0uubusdk/result.json','--guards',P/'验证/wb_mem_guards_ih7si0_i/result.json','--output',QA/'wb_recomputed.json'],QA/'wb_recheck.console.log')
assert read(QA/'wb_recomputed.json')==read(wb)
history=read(P/'验证/阶段0基线.json')
for name,digest in history['immutable_history_sha256'].items():
    assert sha(ROOT/name)==digest,name
for name,digest in history['tb_sha256'].items():
    assert sha(P/'Vivado/tb'/name)==digest,name
phase2=read(P/'验证/cpu_system_n0r4buws/result.json')['input_sha256']
production=list((P/'Vivado/rtl').glob('*'))+list((P/'系统/rtl').glob('*'))
production=[p for p in production if p.is_file()]
assert len(production)==14
for path in production:assert sha(path)==phase2['rtl/'+path.name],str(path)
doc=P/'16位流水线CPU核心设计文档_AC1候选版.docx';pdf=ROOT/'docs/16位流水线CPU核心设计文档_AC1候选版.pdf'
document=Document(doc);reader=PdfReader(pdf)
qa=read(QA/'final_qa.json')
assert qa['word_sha256']==sha(doc) and qa['pdf_sha256']==sha(pdf)
assert len(reader.pages)==qa['pages']==54 and len(document.tables)==39 and len(document.inline_shapes)==12
assert len(read(QA/'changed_pages.json'))==4
qa.update(status='PASS_NATIVE_WORD_AND_VISUAL_QA',render_engine='Microsoft Word',visual_pages_checked=54,
          raster_comparison='50 final pages pixel-identical to inspected iteration; final pages47/51/52/53 opened separately',
          changed_pages_checked=[47,51,52,53],
          page_png_sha256={p.name:sha(p)for p in sorted((QA/'delivery_pages').glob('*.png'))},
          page_png_location=str(QA/'delivery_pages'),packaged_renderer='Unavailable: LibreOffice soffice.exe missing; diagnosed in saved log, native Word fallback completed',
          builder_sha256=sha(P/'板级/update_core_document.py'))
record=P/'验证'/('cpu345_final_review_'+uuid.uuid4().hex);record.mkdir()
tests={}
tests['board_tools']=run(['-m','unittest','discover','-s',P/'板级/tests','-v'],record/'board_tools.console.log')
tests['wb_lifecycle']=run([P/'实验/test_wb_receipts.py','-v'],record/'wb_lifecycle.console.log')
tests['document_binding']=run([P/'实验/test_core_document_binding.py','-v'],record/'document_binding.console.log')
for name in ['native_word_delivery.log','native_word_stats_delivery.txt','packaged_renderer.log','forward_recheck.console.log','wb_recheck.console.log']:
    shutil.copy2(QA/name,record/name)
(record/'document_qa.json').write_text(json.dumps(qa,ensure_ascii=False,indent=2),encoding='utf-8')
review=dict(status='OFFLINE_STAGES_3_TO_5_REVIEWED_PHYSICAL_PENDING',base_commit='5dfe09ec153c4807d418efecbf7f2cf3c25d419e',
            independent_axes=dict(spec='Findings fixed and closed',standards='Findings fixed and closed'),
            immutable_history_files=len(history['immutable_history_sha256']),production_RTL_unchanged=14,original_TB_unchanged=len(history['tb_sha256']),
            python_tests=tests,python_test_count=15,
            comparison_recomputed_exactly=[fwd.relative_to(P).as_posix(),wb.relative_to(P).as_posix()],
            native_programming_or_physical_run_performed=False,
            limitations=['EES-331 not connected','No physical reset/boot/JTAG result acceptance','No measured board execution time','Scoped vendor DRC/methodology warnings retained','Bounded simulation; no all-state formal proof'],
            resolved_findings=['Fatal exit0 handled with explicit log terminals','Interrupted/timeout negative results rejected','Guard RTL/mutants bound to all13 candidate sources','Word arguments bound to comparison graph','Illegal/X EX late qualification checked','Four-state data claim narrowed','Stale board-reset wording and pagination corrected'],
            document_qa_sha256=sha(record/'document_qa.json'),finalized_at_utc=datetime.datetime.now(datetime.timezone.utc).isoformat())
(record/'result.json').write_text(json.dumps(review,ensure_ascii=False,indent=2),encoding='utf-8')
shutil.copy2(__file__,record/'finalize_delivery.py')
index=read(P/'证据索引.json');index['document_revision_history'].append(index['current_document'])
index['candidate']='AC1-board-experiments-r2'
index['current_document']=dict(relative=doc.relative_to(P).as_posix(),CPU='v1.6',candidate='AC1-board-experiments-r2',ISA='v1.5',revision_date='2026-11-01',
                             sha256=sha(doc),pdf_relative_to_repository=pdf.relative_to(ROOT).as_posix(),pdf_sha256=sha(pdf),pages=54,toc_entries=68,tables=39,figures=12,landscape_pages=[9,10],
                             sections_updated=['Preface and stale stage2 boundary wording','4.11 clarified as stage2 system evidence','4.12 EES-331 board implementation and five-program baseline','4.12 isolated forwarding and WB/MEM comparisons','4.13 board manual reference'],
                             production_RTL_changed=False,ISA_changed=False,default_execution_cycles_changed=False,new_routed_implementation=True,physical_board_validated=False)
index['stage3_to_5']=dict(status=review['status'],stage3_review_relative='验证/阶段3复核.json',baseline_pointer='实验/性能基线.json',
                       forward_comparison='实验/前递候选比较.json',wb_mem_comparison='实验/WB_MEM候选比较.json',
                       final_review_relative=(record/'result.json').relative_to(P).as_posix(),document_qa_relative=(record/'document_qa.json').relative_to(P).as_posix(),
                       default_candidate='ac1',separate_candidates=['forward_onehot','wb_mem'],board='EES-331',part='xc7z020clg484-1',clock_period_ns=10,
                       accepted_offline_program_pairs=10,physical_board_connected=False,physical_board_validated=False,measured_board_time_ns=None,
                       WB_mem_validation=dict(original_ISA_cases=48,reset_witnesses=10,new_cases=2005,exact_cycle_normal_cases=2002,per_clock_fault_cases=3,seeded_stress_programs=64,protocol_guard_cases=12,detected_mutants=6))
figures=index['architecture_figures']
if isinstance(figures,dict):figures['board_system_r2']=dict(svg='架构图/04_EES331板级系统.svg',png='架构图/04_EES331板级系统.png',svg_sha256=sha(P/'架构图/04_EES331板级系统.svg'),png_sha256=sha(P/'架构图/04_EES331板级系统.png'),word_figure=12)
else:raise ValueError('Unexpected figure index schema')
(P/'证据索引.json').write_text(json.dumps(index,ensure_ascii=False,indent=2),encoding='utf-8')
manifest=read(P/'文件SHA256.json')
names=subprocess.check_output(['git','ls-files','-z','--cached','--others','--exclude-standard','--','CPU核心设计'],cwd=ROOT).decode('utf-8').split('\0')
paths=sorted({ROOT/n for n in names if n and n!='CPU核心设计/文件SHA256.json'})
manifest.update(scope='Current AC1-board-experiments-r2 package, including immutable historical files and explicit fresh evidence; physical board remains pending',
                verified_at_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),files={p.relative_to(P).as_posix():sha(p)for p in paths})
(P/'文件SHA256.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding='utf-8')
print('FINAL_REVIEW_RECORD='+str(record))
print('DELIVERY_COUNTS history='+str(review['immutable_history_files'])+' current_package_files='+str(len(paths))+' Word=54pages PythonTests=15')
