"""Current 23-page source map plus fresh, source-bound Vivado reproduction evidence."""
from pathlib import Path
import bisect
import csv
import hashlib
import json
import re
from baseline_evidence import collect_frozen
from narrative_v2 import SLIDES, BACKUPS, QUESTIONS

B=Path(__file__).resolve().parent
PRE6=B.parent
REPO=PRE6.parent


def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def write(p,v):p.write_text(json.dumps(v,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')


def sampled_waveform(record):
    sim=record/'project/pre6_cpu.sim/sim_1/behav/xsim'
    with (sim/'selected_trace.csv').open(newline='')as f:rows=list(csv.DictReader(f))
    active=[]
    for row in rows:
        if re.search('[xz]',row['state_before'],re.I):continue
        state=int(row['state_before'],16)
        if not (state>>140&1)and not(state>>88&3):active.append(row)
    assert len(active)==17
    # Cross-check the CSV pre-edge samples against the independent VCD event stream.
    scope=[];code=None;changes=[];times=[];time=0
    for line in (sim/'pre6_selected.vcd').read_text().splitlines():
        tokens=line.split()
        if not tokens:continue
        if tokens[0]=='$scope':scope.append(tokens[2])
        elif tokens[0]=='$upscope':scope.pop()
        elif tokens[0]=='$var'and scope==['tb_selected_program']and tokens[4]=='ev':code=tokens[3]
        elif line.startswith('#'):time=int(line[1:])
        elif line.startswith('b')and code and tokens[-1]==code:
            times.append(time);changes.append(tokens[0][1:])
    assert code and changes
    for row in active:
        edge=(int(row['tick'])-1)*10000+5000
        v=changes[bisect.bisect_left(times,edge)-1]
        assert not re.search('[xz]',v,re.I)and int(v,2)==int(row['events_before'],16)
    fields=[('load_use',78),('redirect',79),('dm_we',45),('wb_valid',0)]
    events=[int(r['events_before'],16)for r in active]
    shown=events[5:13]
    lanes=[dict(name='cycle',wave='='*8,data=[str(i)for i in range(6,14)])]
    for name,bit in fields:
        bits=[(ev>>bit)&1 for ev in shown]
        wave=''.join(str(v)if i==0 or v!=bits[i-1]else'.'for i,v in enumerate(bits))
        lanes.append(dict(name=name,wave=wave))
    assert sum(ev>>78&1 for ev in events)==1 and sum(ev>>79&1 for ev in events)==1 and sum(ev>>45&1 for ev in events)==1
    source={'signal':lanes,'head':{'text':'baseline / XSim / cycles C6 to C13'},
            'foot':{'text':'Rising-edge samples / one slot = 10 ns / no propagation delay implied'},'config':{'hscale':1.5}}
    (B/'图源/baseline_waveform.json5').write_text(json.dumps(source,indent=2)+'\n',encoding='utf-8')
    return {'record':record.relative_to(REPO).as_posix(),'cycles':17,'rows':active,
            'plot_cycle_range':[6,13],'VCD_CSV_pre_edge_agreement':True,'sources':[sim/'selected_trace.csv',sim/'pre6_selected.vcd']}


def main():
    e=collect_frozen()
    records={}
    for p in sorted((PRE6/'Vivado/运行记录').glob('*/result.json')):
        row=json.loads(p.read_text(encoding='utf-8'))
        if row['status']=='PASS':
            if row['program']not in records or row['started_utc']>records[row['program']][1]['started_utc']:
                records[row['program']]=(p,row)
    assert set(records)=={'all_ops','baseline','loop','memory_copy','copy_checksum','system'}
    e['fresh_project_runs']=[{'source':p.relative_to(REPO).as_posix(),**r}for p,r in records.values()]
    e['waveform']=sampled_waveform(records['baseline'][0].parent)
    e['new_XSim_execution']=True;e['new_physical_board_execution']=False;e['new_hardware_or_XSim_execution']=True
    e['source_groups']['LIVE']=[p.relative_to(REPO).as_posix()for p,_ in records.values()]+[p.relative_to(REPO).as_posix()for p in e['waveform'].pop('sources')]
    e['source_groups']['LIVE'] += [p.relative_to(REPO).as_posix()for p in [B/'图源/baseline_waveform.json5',B/'图源/baseline_waveform.svg',B/'图源/baseline_waveform.png',Path(__file__).resolve()]]
    e['source_groups']['FORWARD_CANDIDATE']=['CPU核心设计/实验/前递候选比较.json']
    e['forward_candidate']=json.loads((REPO/'CPU核心设计/实验/前递候选比较.json').read_text(encoding='utf-8'))
    new_hash={p:sha(REPO/p)for group in ['LIVE','FORWARD_CANDIDATE']for p in e['source_groups'][group]}
    drawings=list((B/'图源').glob('*_EN.svg'))+list((B/'图源').glob('0[5-9]_*.svg'))+list((B/'图源').glob('10_*.svg'))
    drawings += [B/'图源/presentation_diagrams.json',B/'diagram_layouts.mjs']
    for p in drawings:new_hash[p.relative_to(REPO).as_posix()]=sha(p)
    e['source_groups']['DIAGRAMS'] += [p.relative_to(REPO).as_posix()for p in drawings]
    e['additional_source_sha256']=new_hash
    write(B/'evidence.json',e)
    count=lambda text:len(re.findall(r"[A-Za-z0-9]+(?:['.-][A-Za-z0-9]+)*",text))
    content=dict(revision='Pre6-r2',main=SLIDES,backup=BACKUPS,questions=QUESTIONS,
                 main_seconds=840,buffer_seconds=60,spoken_words=sum(count(s['speech'])for s in SLIDES))
    write(B/'content.json',content)
    hashes={**e['input_sha256'],**new_hash};maps=[]
    for i,s in enumerate(SLIDES,1):
        groups=s['refs'];paths=list(dict.fromkeys(p for code in groups for p in e['source_groups'][code]))
        m=dict(slide=i,title=s['title'],section=s['section'],claim=s['goal'],source_groups=groups,
               sources=[dict(relative=p,sha256=hashes[p])for p in paths],
               expected='ISA v1.5 / default AC1 instruction and memory contracts',
               actual={'frozen_CPU':'v1.6 / AC1','contract_source':e['baseline_commit']},
               supports='Physical samples prove recorded normal-stop states/counters. Internal cycle timing comes from simulation. Candidate results remain offline.')
        if i in [13,14,15]:
            cases={13:['DOC_LOAD_STR','DOC_ADD_ADD'],14:['DOC_CMP_JZ'],15:['DOC_STR_HALT','MEM_FAULT_OVER_BRANCH']}[i]
            m['actual']=[x for x in e['examples']if x['case']in cases]
        elif i==16:m['actual']={'existing_independent':48,'reset_witnesses':10,'fresh_project_runs':e['fresh_project_runs']}
        elif i==17:m['actual']=e['waveform']
        elif i in [18,19,20]:m['actual']={'physical_programs':e['programs'],'physical_S1':e['button'],'raw_S1':e['raw_button']}
        elif i==21:m['actual']=e['routed']
        elif i==22:m['actual']={'WB_MEM':e['candidate'],'forwarding_MUX':e['forward_candidate']}
        maps.append(m)
    write(B/'source_map.json',maps)
    print('PRE6_R2_CONTENT',len(SLIDES),'main slides;',content['spoken_words'],'words; 6 fresh project runs')


if __name__=='__main__':main()
