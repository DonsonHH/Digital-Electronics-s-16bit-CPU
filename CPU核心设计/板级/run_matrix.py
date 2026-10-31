"""Run or explicitly collect a fixed AC1 routed-performance matrix, without stale-pass fallback."""
from pathlib import Path
import argparse,datetime,hashlib,json,re,subprocess,sys,uuid
B=Path(__file__).resolve().parent;P=B.parent
sys.path.insert(0,str(B));sys.path.insert(0,str(P/'Vivado'))
from benchmark_programs import PROGRAMS,timing_profile
from verify_board_results import verify_attempt,require
from tool_config import add_tool_arguments,resolve_tools
from candidate_registry import CANDIDATES
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def main():
 parser=argparse.ArgumentParser(description=__doc__);add_tool_arguments(parser)
 parser.add_argument('--programs',nargs='+',choices=list(PROGRAMS),default=list(PROGRAMS))
 parser.add_argument('--include-run',type=Path,action='append',default=[])
 parser.add_argument('--collect-only',action='store_true')
 parser.add_argument('--candidate',choices=list(CANDIDATES),default='ac1')
 a=parser.parse_args();require(len(set(a.programs))==len(a.programs),'Duplicate requested programs')
 tools=resolve_tools(a.vivado_bin,python=sys.executable,config=a.config)
 out=P/'验证'/('performance_'+a.candidate+'_'+uuid.uuid4().hex);out.mkdir()
 record={'status':'RUNNING','stage':4 if a.candidate=='ac1' else 5,'candidate':a.candidate,'requested_programs':a.programs,'tools':tools,'script_sha256':sha(Path(__file__)),'rows':[],'source_recipe':None,'physical_board_validated':False,'started_at_utc':datetime.datetime.now(datetime.timezone.utc).isoformat()}
 try:
  runs={}
  for path in a.include_run:
   data=json.loads((path/'result.json').read_text(encoding='utf-8'));name=data['program']
   require(name in a.programs and name not in runs,'Unexpected/repeated included run');runs[name]=path.resolve()
  for name in a.programs:
   if name not in runs:
    require(not a.collect_only,'Required explicit run missing: '+name)
    print('MATRIX_START '+name,flush=True)
    command=[sys.executable,'-B','-X','utf8',str(B/'run_board.py'),'--mode','all','--program',name,'--candidate',a.candidate,'--vivado-bin',tools['vivado_bin']]
    log=out/(name+'.console.log')
    with log.open('wb') as target:rc=subprocess.run(command,cwd=B,stdout=target,stderr=subprocess.STDOUT).returncode
    text=log.read_text(encoding='utf-8',errors='replace');markers=re.findall(r'^BOARD_RECORD=(.+)$',text,re.M)
    require(rc==0 and len(markers)==1 and text.splitlines().count('BOARD_ATTEMPT_PASS scope=selected_native_checks_not_physical_board')==1,'Matrix native run failed: '+name)
    runs[name]=Path(markers[0].strip())
   path=runs[name];data=json.loads((path/'result.json').read_text(encoding='utf-8'));implementation=verify_attempt(path)
   require(data['program']==name and data['mode']=='all' and data.get('verification_revision') in ['board_benchmarks_v3','board_candidates_v4'] and data.get('selected_simulation')=='PASS' and data.get('candidate','ac1')==a.candidate,'Not a complete selected-program benchmark')
   c,n,s,r=timing_profile(name,a.candidate);observed=data['selected_result']
   require([observed[k] for k in ['cycles','completed','stalls','redirects']]==[c,n,s,r],'Benchmark count contract differs')
   # Only selected images and their independent expected data may vary.
   varying={'programs/dut_im.mem','programs/dut_dm.mem','programs/selected_events.mem','programs/selected_stores.mem','tb/selected_expected.svh'}
   recipe={key:value for key,value in data['input_sha256'].items() if key not in varying}
   if record['source_recipe'] is None:record['source_recipe']=recipe
   else:require(recipe==record['source_recipe'],'Common benchmark code/tool/RAM/debug recipe changed')
   row={'program':name,'attempt_relative':path.relative_to(P).as_posix(),'receipt_sha256':sha(path/'result.json'),'cycles':c,'completed':n,'stalls':s,'redirects':r,'stores':observed['stores'],'rf':observed['rf'],'flags':observed['flags'],'stop_pc':observed['stop_pc'],'CPI':c/n,'calculated_cpu_time_ns':c*implementation['period_ns'],'time_basis':'cycle calculation at routed100MHz, not a physical-board measurement','measured_board_time_ns':None,'implementation':implementation,'instruction_image_sha256':data['input_sha256']['programs/dut_im.mem'],'data_image_sha256':data['input_sha256']['programs/dut_dm.mem']}
   record['rows'].append(row);print('MATRIX_PASS '+name+' cycles='+str(c),flush=True)
  require(len(record['rows'])==len(a.programs),'Requested benchmark rows incomplete')
  record['status']=('FULL_BASELINE_PASS_PHYSICAL_PENDING' if a.candidate=='ac1' else 'FULL_CANDIDATE_PASS_PHYSICAL_PENDING') if set(a.programs)==set(PROGRAMS) else 'REQUESTED_SUBSET_PASS_PHYSICAL_PENDING'
 except BaseException as error:record.update(status='FAIL',error=str(error));raise
 finally:
  record['completed_at_utc']=datetime.datetime.now(datetime.timezone.utc).isoformat();(out/'result.json').write_text(json.dumps(record,ensure_ascii=False,indent=2),encoding='utf-8');print('MATRIX_RECORD='+str(out),flush=True)
if __name__=='__main__':main()
