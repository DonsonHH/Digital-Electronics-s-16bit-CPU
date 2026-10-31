"""Extract clock-edge CU evidence from NEW XSim VCD, without drawing images.

All changes at a timestamp settle before post-edge sampling. Pre-edge values
come from before that same timestamp. No invented clock or hardware delay.
"""
from pathlib import Path
from datetime import datetime,timezone
import csv,hashlib,json,re

ROOT=Path(__file__).resolve().parent;PACKAGE=ROOT;PROJECT=ROOT.parent
def read(p):return json.loads(p.read_text(encoding='utf-8-sig'))
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def require(ok,why):
    if not ok:raise RuntimeError(why)
def bound(root,hashes):
    for name,digest in hashes.items():require(sha(root/name)==digest,'Evidence mismatch: '+name)

receipt=read(PACKAGE/'验证结果.json');attempt=read(PACKAGE/'最近运行.json')
require(receipt['status']=='PASS' and receipt['new_xsim_execution'] and receipt['attempt_id']==attempt['attempt_id'],'No current execution PASS')
require(attempt['status']=='PASS' and receipt['execution_binding']['native_subprocesses']==19,'Incomplete execution ledger')
run=PACKAGE/receipt['archived_run_relative']
bound(run,receipt['evidence_sha256']);bound(PACKAGE/'rtl',receipt['rtl_sha256'])
original=read(ROOT/'source_manifest.json')
for name,digest in receipt['rtl_sha256'].items():require(original['input_sha256']['rtl/'+name]==digest,'Executed RTL differs from the approved CPU core')

WANTED='clk rst mode mode_next mode_active stop_pending PC_fetch pc_hold qualified_redirect branch_target fetch_accept im_en d_valid d_pc d_inst d_use_rd d_use_rs d_alu_op d_reg_write d_mem_read d_mem_write d_z_write d_cv_write d_illegal d_fault x_valid x_pc x_fault x_rd x_rs x_alu_op x_reg_write x_mem_read x_mem_write x_z_write x_cv_write x_halt m_valid m_pc m_fault m_exec_value m_store_data m_reg_write m_mem_read m_mem_write m_z_write m_cv_write m_halt w_valid w_pc w_fault w_store w_reg_write w_z_write w_cv_write w_halt wb_data rf_we z_we cv_we dm_en dm_we dm_addr dm_din dm_dout alu_a alu_b alu_result alu_eq alu_c alu_v rd_fwd_sel rs_fwd_sel blocked_rd blocked_rs load_use z_effective z_fwd_sel Z C V m_fault_event x_fault_event qualified_halt branch_req frontend_kill d_valid_next x_valid_next m_valid_next w_valid_next w_stop_token pipeline_empty_next drain_done halted fault'.split()
HEX_WORDS=set('PC_fetch d_pc d_inst x_pc m_pc m_exec_value m_store_data w_pc wb_data dm_addr dm_din dm_dout alu_a alu_b alu_result branch_target'.split())

def clocks(path):
    declarations={};scope=[];values={};edges=[];changes={};stamp=None;prefix=None
    with path.open(encoding='utf-8',errors='replace') as handle:
        for raw in handle:
            line=raw.strip()
            if line.startswith('$scope '):scope.append(line.split()[2])
            elif line.startswith('$upscope'):scope.pop()
            elif line.startswith('$var '):
                p=line.split();declarations['.'.join(scope+[p[4]])]=p[3]
            elif line.startswith('$enddefinitions'):break
        # Clock values below are deliberately expressed in picoseconds. Reject
        # a changed/missing VCD unit rather than silently relabeling its ticks.
        handle.seek(0)
        header=''
        for raw in handle:
            header+=raw
            if raw.strip().startswith('$enddefinitions'):break
        scale=re.search(r'\$timescale\s*(\d+)\s*([a-z]+)\s*\$end',header,re.I)
        require(scale is not None and scale.group(1)=='1' and scale.group(2).lower()=='ps','VCD timebase must be exactly 1ps')
        matches=[name[:-5] for name in declarations if name.endswith('.dut.core.mode')]
        require(len(matches)==1,'Cannot identify unique core mode')
        prefix=matches[0];mapping={name:declarations.get(prefix+'.'+name) for name in WANTED}
        require(all(mapping.values()),'Required CU signals absent: '+str([n for n,c in mapping.items() if c is None]))
        ids=set(mapping.values())
        def sample(v):return {name:v.get(code) for name,code in mapping.items()}
        def flush():
            before=sample(values);values.update(changes);after=sample(values)
            if before['clk']==0 and after['clk']==1:edges.append(dict(time_ps=stamp,pre=before,post=after))
        for raw in handle:
            line=raw.strip()
            if not line:continue
            if line.startswith('#'):
                t=int(line[1:])
                if stamp is not None and t!=stamp:flush();changes={}
                stamp=t
            elif line[0] in 'bB':
                p=line[1:].split()
                if len(p)==2 and p[1] in ids:changes[p[1]]=int(p[0],2) if re.fullmatch('[01]+',p[0]) else None
            elif line[0] in '01xXzZ' and line[1:] in ids:
                changes[line[1:]]=int(line[0]) if line[0] in '01' else None
        if stamp is not None:flush()
    return edges

out=ROOT/'control_traces';out.mkdir(exist_ok=True)
all_edges=clocks(run/'datapath.vcd');short_edges=clocks(run/'interlock.vcd')
def cases(name):
    with (run/name).open(newline='',encoding='utf-8-sig') as f:return list(csv.DictReader(f))
main_cases={r['case']:r for r in cases('case_results.csv')}
main_starts={r['case']:int(r['start_ps']) for r in cases('case_timings.csv')}
trace_cases={r['case']:r for r in cases('trace_case_results.csv')}
trace_starts={r['case']:int(r['start_ps']) for r in cases('trace_case_timings.csv')}
chosen={}
for name in ('BASELINE','T01','T02','T03','T04','T05','T07','T16','T17a','T18b','TRACE_LOAD_STR'):
    source,start,result=(short_edges,trace_starts[name],trace_cases[name]) if name=='TRACE_LOAD_STR' else (all_edges,main_starts[name],main_cases[name])
    selected=[dict(cycle=i+1,**edge) for i,edge in enumerate([e for e in source if e['time_ps']>=start][:int(result['cycles'])])]
    require(len(selected)==int(result['cycles']),'Case trace length mismatch')
    require(selected[0]['time_ps']==start+5000,'Unexpected first-edge timing')
    for i,row in enumerate(selected):require(row['time_ps']==start+5000+10000*i,'Non-uniform clock period')
    data=dict(case=name,source_vcd='interlock.vcd' if name=='TRACE_LOAD_STR' else 'datapath.vcd',
              source_vcd_sha256=sha(run/('interlock.vcd' if name=='TRACE_LOAD_STR' else 'datapath.vcd')),
              case_start_ps=start,time_unit='ps',sample_rule='pre before edge; post after all same-timestamp updates settle',
              receipt=result,edges=selected)
    (out/(name+'.json')).write_text(json.dumps(data,indent=2),encoding='utf-8')
    columns=['cycle','time_ps']+['pre_'+n for n in WANTED if n not in ('clk','rst')]+['post_'+n for n in ('mode','d_valid','x_valid','m_valid','w_valid','halted','fault','Z','C','V')]
    with (out/(name+'.csv')).open('w',newline='',encoding='utf-8') as f:
        writer=csv.DictWriter(f,fieldnames=columns);writer.writeheader()
        for e in selected:
            flat=dict(cycle=e['cycle'],time_ps=e['time_ps'])
            for key in columns[2:]:
                phase,n=key.split('_',1);value=e[phase][n]
                flat[key]='unknown' if value is None else (f'{value:04X}' if n in HEX_WORDS else value)
            writer.writerow(flat)
    chosen[name]=data

# Cross-check independent visible witnesses. These are actual edge values,
# additional to the original self-checking testbench, not just final RF values.
short={e['cycle']:e for e in chosen['TRACE_LOAD_STR']['edges']}
require(short[3]['pre']['load_use']==1 and short[3]['post']['x_valid']==0,'Missing one-cycle interlock')
require(short[4]['pre']['load_use']==0 and short[5]['pre']['rd_fwd_sel']==2,'Missing WB load forwarding')
require(short[6]['pre']['dm_we']==1 and short[6]['pre']['dm_din']==7,'STR write differs')
require(short[7]['pre']['w_valid']==1 and short[7]['pre']['w_store']==1 and short[7]['pre']['rf_we']==0,'STR valid no-write WB differs')
require(short[7]['pre']['qualified_redirect']==1 and short[7]['pre']['z_fwd_sel']==1 and short[7]['post']['x_valid']==0 and short[7]['post']['d_valid']==0,'CMP/JZ/flush differs')
require(short[12]['pre']['w_halt']==1 and short[12]['pre']['drain_done']==1 and short[12]['post']['mode']==3,'HALT WB stop edge differs')
fault=chosen['T16']['edges'][3]
require(fault['pre']['m_fault_event']==1 and fault['pre']['qualified_halt']==0 and fault['post']['mode']==2,'Older MEM fault did not override HALT')
log=(run/'datapath.log').read_text(encoding='utf-8',errors='replace')
reset_modes={int(x) for x in re.findall(r'^RESET_PASS .* old_mode=(\d+)',log,re.M)}
require(reset_modes==set(range(5)),'Reset not witnessed from all five operating modes')
independent_runs=[(read(p/'independent_result.json'),p) for p in (PACKAGE/'验证记录').glob('cpu_ac1_independent_*') if (p/'independent_result.json').exists()]
independent,independent_dir=max(independent_runs,key=lambda pair:pair[0]['ended_at_utc'])
require(independent['status']=='PASS' and independent['native_execution_complete'] and independent['new_xsim_execution'],'Independent48 not newly completed')
bound(independent_dir,independent['input_sha256'])
require(sha(independent_dir/'private.log')==independent['log_sha256'],'Independent48 native log hash differs')
require(sha(independent_dir/'console.log')==independent['console_sha256'],'Independent48 console hash differs')
for name,digest in receipt['rtl_sha256'].items():require(independent['input_sha256']['rtl/'+name]==digest,'Independent48 used another RTL snapshot')
independent_log=(independent_dir/'private.log').read_text(encoding='utf-8',errors='replace')
require(independent_log.splitlines().count('ADVERSARIAL_PASS cases=48 reset_witnesses=10 failures=0 oracle=external_python memory=independent_sync')==1,'Independent terminal marker differs')

summary=dict(status='PASS',reviewed_at_utc=datetime.now(timezone.utc).isoformat(),attempt_id=receipt['attempt_id'],
             native_steps=19,new_xsim_execution=True,nine_suites='PASS',decoder_words=receipt['decoder_contract']['decode_words_checked'],
             directed_programs=receipt['datapath']['cases'],reset_probes=receipt['datapath']['reset_probes'],
             reset_from_modes=sorted(reset_modes),hazard_cases=receipt['hazards']['total'],forwarding_control_combinations=receipt['forward_control_index_space']['cases'],
             independent_cases=48,trace_cases=list(chosen),trace_semantics='Per-clock pre/post edge samples from current executed VCD',
             register_timing_unchanged=True,hardware_programmed=False,scope='Finite functional/control tests; not CPU-state exhaustion or new board/timing acceptance',
             evidence=dict(regression=str(run),independent=str(independent_dir)),source_receipt_sha256=sha(PACKAGE/'验证结果.json'))
(ROOT/'control_evidence.json').write_text(json.dumps(summary,ensure_ascii=False,indent=2),encoding='utf-8')
print('PRE5_CONTROL_EVIDENCE_PASS modes=5 reset_modes=5 trace_cases='+str(len(chosen))+' regression_suites=9 independent_cases=48')
for case in ('TRACE_LOAD_STR','T07','T16'):
    print(case)
    for e in chosen[case]['edges']:
        p,q=e['pre'],e['post']
        print(e['cycle'],'X/M/W',p['x_pc'] if p['x_valid'] else '-',p['m_pc'] if p['m_valid'] else '-',p['w_pc'] if p['w_valid'] else '-',
              'stall/redirect/store',p['load_use'],p['qualified_redirect'],p['dm_we'],'mode',p['mode'],'->',q['mode'],'drain',p['drain_done'])
