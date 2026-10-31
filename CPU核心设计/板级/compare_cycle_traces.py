"""Exact representative clock traces for a cycle-preserving combinational candidate."""
from pathlib import Path
import argparse,hashlib,json,re,subprocess,sys,uuid
B=Path(__file__).resolve().parent;P=B.parent;sys.path.insert(0,str(P/'Vivado'));sys.path.insert(0,str(B))
from tool_config import add_tool_arguments,resolve_tools
from benchmark_programs import PROGRAMS
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 parser=argparse.ArgumentParser(description=__doc__);add_tool_arguments(parser);parser.add_argument('--candidate',choices=['forward_onehot'],required=True);a=parser.parse_args();tools=resolve_tools(a.vivado_bin,python=sys.executable,config=a.config)
 out=P/'验证'/('traces_'+a.candidate+'_'+uuid.uuid4().hex);out.mkdir();result={'status':'RUNNING','candidate':a.candidate,'expected_programs':list(PROGRAMS),'rows':[],'scope':'Exact RTL clock trace equality, not physical hardware'}
 try:
  for program in PROGRAMS:
   runs={}
   for candidate in ['ac1',a.candidate]:
    log=out/(program+'_'+candidate+'.log');print('TRACE_START '+program+' '+candidate,flush=True)
    with log.open('wb') as output:rc=subprocess.run([sys.executable,'-B','-X','utf8',str(B/'run_board.py'),'--mode','simulate','--candidate',candidate,'--program',program,'--vivado-bin',tools['vivado_bin']],stdout=output,stderr=subprocess.STDOUT,cwd=B).returncode
    text=log.read_text(encoding='utf-8',errors='replace');paths=re.findall(r'^BOARD_RECORD=(.+)$',text,re.M)
    if rc or len(paths)!=1:raise RuntimeError('Clock-trace child failed')
    path=Path(paths[0].strip());r=json.loads((path/'result.json').read_text(encoding='utf-8'))
    if r['status']!='PASS' or r['candidate']!=candidate or r['program']!=program or r['selected_simulation']!='PASS':raise ValueError('Trace child identity/status wrong')
    if sha(path/'selected_trace.csv')!=r['selected_trace_sha256']:raise ValueError('Trace hash mismatch')
    runs[candidate]=path
   old=(runs['ac1']/'selected_trace.csv').read_text();new=(runs[a.candidate]/'selected_trace.csv').read_text()
   if old!=new:raise ValueError('Per-clock state/event/performance differs: '+program)
   result['rows'].append({'program':program,'clock_rows':len(old.splitlines())-1,'trace_sha256':sha(runs['ac1']/'selected_trace.csv'),'baseline_relative':runs['ac1'].relative_to(P).as_posix(),'candidate_relative':runs[a.candidate].relative_to(P).as_posix()});print('TRACE_IDENTICAL '+program,flush=True)
  if len(result['rows'])!=5:raise ValueError('Trace coverage incomplete')
  result['status']='PASS'
 except BaseException as error:result.update(status='FAIL',error=str(error));raise
 finally:
  (out/'result.json').write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding='utf-8');print('TRACE_COMPARISON_RECORD='+str(out),flush=True)
if __name__=='__main__':main()
