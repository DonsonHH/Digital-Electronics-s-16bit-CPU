"""Accept a single-core-file WB/MEM experiment only with bound ISA/cycle/guard evidence."""
from pathlib import Path
import argparse,csv,hashlib,json,re,sys
from verify_board_results import verify_attempt,require
B=Path(__file__).resolve().parent;P=B.parent;sys.path.insert(0,str(P/'实验'))
from run_wb_validation import adapted_checker,directed_cases
from run_wb_guards import TB,MUTANTS
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def read(p):return json.loads(Path(p).read_text(encoding='utf-8'))

def native_receipt(root,label):
    receipt=read(root/(label+'_execution.json'))
    require(type(receipt['exit_code']) is int and receipt['exit_code'] in (0,1) and receipt['error'] is None,'Native attempt did not finish normally')
    require(sha(root/(label+'_console.log'))==receipt['console_sha256'],'Native console changed')
    for name,digest in receipt['input_sha256'].items():require(sha(root/name)==digest,'Executed candidate input changed: '+name)
    console=(root/(label+'_console.log')).read_text(encoding='utf-8',errors='replace')
    require('Vivado Simulator v2025.2' in console and not re.search(r'(?m)^ERROR:',console),'Native compile/elaboration/version failure')
    return receipt

def verify_validation(path,guards_path):
    data,guards=read(path),read(guards_path);root,gr=path.parent,guards_path.parent
    candidate=sha(P/'实验/候选/wb_mem/datapath_core.sv')
    for d,script in [(data,'run_wb_validation.py'),(guards,'run_wb_guards.py')]:
        require(d['status']=='PASS' and d['candidate']=='wb_mem' and d['candidate_rtl_sha256']==candidate,'WB/MEM validation source/status differs')
        require(d['runner_sha256']==sha(P/'实验'/script),'WB/MEM validation runner changed')
    expected_labels=json.loads((P/'Vivado/verification/test_manifest.json').read_text())['frozen_independent48']['labels']
    for key,count,resets,labels in [('frozen48',48,10,expected_labels),('directed',2005,0,[c['label']for c in directed_cases()])]:
        suite=data[key];run=root/(key+'_execution');log=(run/'private.log').read_text(encoding='utf-8',errors='replace')
        require(suite['status']=='PASS' and suite['cases']==count and suite['rows']==count+resets and suite['reset_witnesses']==resets,'Validation suite coverage differs')
        receipt=native_receipt(run,'candidate');require(receipt['exit_code']==0,'Positive native attempt failed')
        require((run/'tb_adversarial.sv').read_text()==adapted_checker(key=='frozen48'),'Executed checker differs from reviewed candidate checker')
        for name,field in [('private.log','log_sha256'),('independent_results.csv','results_sha256'),('independent_cycles.csv','cycles_sha256')]:require(sha(run/name)==suite[field],'Validation output changed')
        terminal=f'ADVERSARIAL_PASS cases={count} reset_witnesses={resets} failures=0 oracle=external_python memory=independent_sync'
        require(log.splitlines().count(terminal)==1 and '$finish called at time' in log and not re.search(r'(?m)^Fatal:|^ERROR:',log),'Validation terminal failed')
        with(run/'independent_results.csv').open(newline='',encoding='utf-8-sig')as f:rows=list(csv.DictReader(f))
        require(len(rows)==count+resets and len({(r['case'],r['epoch'])for r in rows})==len(rows) and {r['case']for r in rows}==set(labels),'Actual unique result labels differ')
        for name,digest in data['executed_rtl_sha256'].items():require(sha(run/'rtl'/name)==digest,'Validation RTL differs')
    positive=gr/'positive';log=(positive/'private.log').read_text(encoding='utf-8',errors='replace');receipt=native_receipt(positive,'guards')
    require(receipt['exit_code']==0 and (positive/'tb_wb_guards.sv').read_text()==TB,'Guard positive checker/exit differs')
    require({p.name for p in (positive/'rtl').iterdir()if p.is_file()}==set(data['executed_rtl_sha256']),'Guard positive RTL inventory differs')
    for name,digest in data['executed_rtl_sha256'].items():require(sha(positive/'rtl'/name)==digest,'Positive guard RTL is not the validated candidate: '+name)
    require(sha(positive/'private.log')==guards['positive']['log_sha256'] and sha(positive/'guards.csv')==guards['positive']['csv_sha256'],'Guard output changed')
    require(log.splitlines().count('WB_GUARDS_PASS cases=12 reset_pending=1 missing_producer=6 address_priority=1 ex_qualifiers=2')==1 and not re.search(r'(?m)^Fatal:|^ERROR:',log),'Positive guard terminal failed')
    with(positive/'guards.csv').open(newline='',encoding='utf-8-sig')as f:guard_rows=list(csv.DictReader(f))
    require(len(guard_rows)==12 and {r['kind']for r in guard_rows}=={str(i)for i in range(12)},'Guard coverage differs')
    require(len(re.findall(r'^GUARD_EX_QUAL_WITNESS ',log,re.M))==2,'Illegal and X EX qualifier witnesses missing')
    expected_mutants={name:marker for name,old,new,marker in MUTANTS}
    replacements={name:(old,new)for name,old,new,marker in MUTANTS}
    original=(P/'实验/候选/wb_mem/datapath_core.sv').read_text(encoding='utf-8')
    require(len(guards['mutations'])==len(MUTANTS) and {m['name']for m in guards['mutations']}==set(expected_mutants),'Six distinct guard mutations required')
    for m in guards['mutations']:
        run=gr/m['name'];native_receipt(run,'guards');text=(run/'private.log').read_text(encoding='utf-8',errors='replace')
        require(m['status']=='EXPECTED_FAILURE_DETECTED' and m['marker']==expected_mutants[m['name']],'Mutation identity changed')
        require(sha(run/'private.log')==m['log_sha256'] and sha(run/'rtl/datapath_core.sv')==m['mutated_rtl_sha256'],'Mutation evidence changed')
        old,new=replacements[m['name']]
        require(original.count(old)==1 and (run/'rtl/datapath_core.sv').read_text(encoding='utf-8')==original.replace(old,new),'Mutant is not the declared one-line change of the current candidate')
        for name,digest in data['executed_rtl_sha256'].items():
            if name!='datapath_core.sv':require(sha(run/'rtl'/name)==digest,'Mutant changed unrelated RTL: '+name)
        require((run/'tb_wb_guards.sv').read_text()==TB,'Mutant checker differs')
        require(re.search(r'(?m)^Fatal:.*'+re.escape(m['marker']),text) and 'WB_GUARDS_PASS'not in text and '$finish called at time'in text,'Expected mutant failure missing')
    require(len(data['executed_rtl_sha256'])==13,'Thirteen executed production RTL sources required')
    return data,guards

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    for name in ['baseline','candidate','validation','guards','output']:parser.add_argument('--'+name,type=Path,required=True)
    a=parser.parse_args();require(not a.output.exists(),'Comparison output must be new')
    base,cand=read(a.baseline),read(a.candidate);validation,guards=verify_validation(a.validation,a.guards)
    require(base['status']=='FULL_BASELINE_PASS_PHYSICAL_PENDING' and base['candidate']=='ac1','Complete explicit AC1 baseline required')
    require(cand['status']=='FULL_CANDIDATE_PASS_PHYSICAL_PENDING' and cand['candidate']=='wb_mem','Complete WB/MEM matrix required')
    names={'all_ops','baseline','loop','memory_copy','copy_checksum'}
    require(len(base['rows'])==len(cand['rows'])==5 and {r['program']for r in base['rows']}=={r['program']for r in cand['rows']}==names,'Five unique workload pairs required')
    old={r['program']:r for r in base['rows']};rows=[]
    expected_cycles={'all_ops':(25,1),'baseline':(17,1),'loop':(30,0),'memory_copy':(14,1),'copy_checksum':(47,8)}
    for row in cand['rows']:
        b=old[row['program']];bp=P/b['attempt_relative'];cp=P/row['attempt_relative']
        require(sha(bp/'result.json')==b['receipt_sha256'] and sha(cp/'result.json')==row['receipt_sha256'],'Matrix child receipt changed')
        bi,ci=verify_attempt(bp),verify_attempt(cp);br,cr=read(bp/'result.json'),read(cp/'result.json')
        require(br['program']==cr['program']==row['program'] and cr['candidate']=='wb_mem','Child program/candidate differs')
        bh,ch=br['hardware_input_sha256'],cr['hardware_input_sha256']
        require(set(bh)==set(ch) and {n for n in bh if bh[n]!=ch[n]}=={'rtl/datapath_core.sv'},'Hardware comparison is not a single core-file variable')
        for n,digest in validation['executed_rtl_sha256'].items():require(ch['rtl/'+n]==digest,'Validated and routed RTL differ: '+n)
        for key in ['completed','redirects','stores','rf','flags','stop_pc']:require(b[key]==row[key],'Candidate ISA result changed: '+key)
        require((row['cycles'],row['stalls'])==expected_cycles[row['program']],'Candidate exact timing profile differs')
        require(cr['selected_simulation']=='PASS' and cr['selected_trace_sha256']==sha(cp/'selected_trace.csv'),'Selected trace missing/changed')
        selected=(cp/'selected.log').read_text(encoding='utf-8',errors='replace')
        terminal=f'BOARD_SELECTED_PASS program={row["program"]} cycles={row["cycles"]} completed={row["completed"]} stalls={row["stalls"]} redirects={row["redirects"]} stores={row["stores"]}'
        require(selected.splitlines().count(terminal)==1 and '$finish called at time'in selected and not re.search(r'(?m)^Fatal:|^ERROR:',selected),'Selected program terminal differs')
        rows.append(dict(program=row['program'],baseline_cycles=b['cycles'],candidate_cycles=row['cycles'],baseline_stalls=b['stalls'],candidate_stalls=row['stalls'],
                         saved_cycles=b['cycles']-row['cycles'],calculated_time_saved_ns_at100MHz=(b['cycles']-row['cycles'])*10,
                         baseline_LUT=bi['resources']['lut_total'],candidate_LUT=ci['resources']['lut_total'],LUT_delta=ci['resources']['lut_total']-bi['resources']['lut_total'],
                         baseline_FF=bi['resources']['ff'],candidate_FF=ci['resources']['ff'],FF_delta=ci['resources']['ff']-bi['resources']['ff'],
                         baseline_WNS_ns=bi['timing']['wns_ns'],candidate_WNS_ns=ci['timing']['wns_ns'],WNS_delta_ns=ci['timing']['wns_ns']-bi['timing']['wns_ns'],
                         baseline_WHS_ns=bi['timing']['whs_ns'],candidate_WHS_ns=ci['timing']['whs_ns']))
    result=dict(status='COMPARISON_ACCEPTED_PHYSICAL_PENDING',candidate='wb_mem',verification_revision=1,verifier_sha256=sha(__file__),
                hardware_variable='rtl/datapath_core.sv only; same image/board/debug/RAM/constraints/implementation recipe per pair',
                ISA='v1.5',default_core='stable AC1 unchanged',rows=rows,physical_board_validated=False,
                validation_scope='48 original ISA fixtures/10 reset witnesses; 2002 exact-cycle normal cases plus 3 per-clock fault cases; 12 protocol guards and 6 detected negative mutants. Bounded simulation, not formal all-state proof.',
                source_receipt_sha256={str(p.resolve()):sha(p)for p in[a.baseline,a.candidate,a.validation,a.guards]})
    a.output.write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding='utf-8');print('WB_SINGLE_VARIABLE_COMPARISON_PASS')
if __name__=='__main__':main()
