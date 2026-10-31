"""Compare explicit routed matrices only after functional and exact-cycle evidence passes."""
from pathlib import Path
import argparse,hashlib,json
from verify_board_results import verify_attempt,require
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 p=argparse.ArgumentParser(description=__doc__)
 for name in ['baseline','candidate','core-trial','traces','output']:p.add_argument('--'+name,type=Path,required=True)
 a=p.parse_args();require(not a.output.exists(),'Comparison output must be new')
 base=json.loads(a.baseline.read_text(encoding='utf-8'));cand=json.loads(a.candidate.read_text(encoding='utf-8'));core=json.loads(a.core_trial.read_text(encoding='utf-8'));traces=json.loads(a.traces.read_text(encoding='utf-8'))
 require(base['status']=='FULL_BASELINE_PASS_PHYSICAL_PENDING' and base['candidate']=='ac1','Explicit complete baseline required')
 require(cand['status']=='FULL_CANDIDATE_PASS_PHYSICAL_PENDING' and cand['candidate']=='forward_onehot','Explicit complete forwarding candidate required')
 names={'all_ops','baseline','loop','memory_copy','copy_checksum'}
 require(len(base['rows'])==5 and len(cand['rows'])==5 and {r['program'] for r in base['rows']}==names and {r['program'] for r in cand['rows']}==names,'Five unique workload pairs required')
 require(core['status']=='PASS' and core['candidate']=='forward_onehot' and [s['suite'] for s in core['steps']]==['regression','independent','mutations','unknown'] and all(s['exit']==0 for s in core['steps']),'Full candidate functional acceptance missing')
 require(traces['status']=='PASS' and len(traces['rows'])==5 and {r['program'] for r in traces['rows']}==names,'Exact cycle comparison missing')
 package=a.baseline.resolve().parents[2]
 for row in traces['rows']:
  first=package/row['baseline_relative']/'selected_trace.csv';second=package/row['candidate_relative']/'selected_trace.csv'
  require(sha(first)==row['trace_sha256'] and first.read_bytes()==second.read_bytes(),'Trace equality evidence changed')
 b={r['program']:r for r in base['rows']};rows=[]
 for candidate in cand['rows']:
  old=b[candidate['program']];old_path=package/old['attempt_relative'];new_path=package/candidate['attempt_relative']
  old_r=json.loads((old_path/'result.json').read_text(encoding='utf-8'));new_r=json.loads((new_path/'result.json').read_text(encoding='utf-8'))
  require(sha(old_path/'result.json')==old['receipt_sha256'] and sha(new_path/'result.json')==candidate['receipt_sha256'],'Matrix child receipt changed')
  old_impl,new_impl=verify_attempt(old_path),verify_attempt(new_path)
  old_hw=old_r['hardware_input_sha256'];new_hw=new_r['hardware_input_sha256']
  require(set(old_hw)==set(new_hw),'Hardware recipe inventory changed')
  delta=[name for name in old_hw if old_hw[name]!=new_hw[name]]
  require(delta==['rtl/operand_forward.v'] or set(delta)=={'rtl/operand_forward.v'},'Not a single forwarding-file hardware variable')
  require(new_hw['rtl/operand_forward.v']==core['executed_RTL_sha256']['operand_forward.v'],'Functional and routed candidate differ')
  for key in ['cycles','completed','stalls','redirects','stores','rf','flags','stop_pc']:
   require(old[key]==candidate[key],'Combinational candidate changed architecture/cycles: '+key)
  rows.append({'program':candidate['program'],'cycles':candidate['cycles'],'baseline_LUT':old_impl['resources']['lut_total'],'candidate_LUT':new_impl['resources']['lut_total'],'LUT_delta':new_impl['resources']['lut_total']-old_impl['resources']['lut_total'],
   'FF_delta':new_impl['resources']['ff']-old_impl['resources']['ff'],'baseline_WNS_ns':old_impl['timing']['wns_ns'],'candidate_WNS_ns':new_impl['timing']['wns_ns'],'WNS_delta_ns':new_impl['timing']['wns_ns']-old_impl['timing']['wns_ns'],
   'baseline_WHS_ns':old_impl['timing']['whs_ns'],'candidate_WHS_ns':new_impl['timing']['whs_ns'],'cpu_time_delta_ns_at100MHz':0})
 result={'status':'COMPARISON_ACCEPTED_PHYSICAL_PENDING','candidate':'forward_onehot','hardware_variable':'rtl/operand_forward.v only; images and board/debug/constraints/implementation recipe identical for each pair','functional_suites':'Original9/independent48/mutations/unknown PASS','exact_cycle_programs':5,'rows':rows,
  'recommendation':'Preserve stable AC1; candidate has no cycle-time benefit at fixed100MHz. Assess recorded LUT/margin trade-off rather than assuming one-hot is better.','source_receipt_sha256':{str(f.resolve()):sha(f) for f in [a.baseline,a.candidate,a.core_trial,a.traces]},'physical_board_validated':False}
 a.output.write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding='utf-8');print('FORWARD_SINGLE_VARIABLE_COMPARISON_PASS')
if __name__=='__main__':main()
