"""Chapter-indexed evidence: unchanged AC1 contract plus the corrected GUI projects."""
from pathlib import Path
import bisect
import csv
import hashlib
import json
import re
from baseline_evidence import collect_frozen
from narrative_v3 import SLIDES,QUESTIONS,TEAM

B=Path(__file__).resolve().parent;PRE=B.parent;REPO=PRE.parent


def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def write(p,v):p.write_text(json.dumps(v,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')


def vcd_signals(path):
    scope=[];ids={};changes={};tick=0
    for line in path.read_text(encoding='utf-8',errors='replace').splitlines():
        t=line.split()
        if not t:continue
        if t[0]=='$scope':scope.append(t[2])
        elif t[0]=='$upscope':scope.pop()
        elif t[0]=='$var':ids['.'.join(scope+[t[4]])]=t[3]
        elif line.startswith('#'):tick=int(line[1:])
        elif line.startswith('b')and len(t)==2:
            changes.setdefault(t[1],[]).append((tick,t[0][1:]))
        elif line[0]in'01xXzZ'and len(line)>1:
            changes.setdefault(line[1:],[]).append((tick,line[0]))
    return ids,changes


def actual_trace(folder):
    sim=folder/'outputs/project/pre6_cpu.sim/sim_1/behav/xsim'
    with (sim/'cpu_trace.csv').open(newline='')as f:rows=list(csv.DictReader(f))
    ids,changes=vcd_signals(sim/'pre6_cpu.vcd')
    prefix='tb_pre6_cpu.check.'
    signals={'wb_valid':'wb_valid','dm_we':'mem_we','stall':'stall','redirect':'redirect'}
    for column,signal in signals.items():
        history=changes[ids[prefix+signal]];times=[t for t,_ in history]
        for row in rows:
            index=bisect.bisect_left(times,int(row['time_ps']))-1
            assert index>=0 and int(history[index][1],2)==int(row[column]),(column,row['cycle'])
    rf=int(changes[ids[prefix+'rf']][-1][1],2);flags=int(changes[ids[prefix+'flags']][-1][1],2)
    return dict(rows=rows,rf=[(rf>>(16*i))&0xffff for i in range(4)],flags=[(flags>>i)&1 for i in [2,1,0]],
                source_files=[sim/'cpu_trace.csv',sim/'pre6_cpu.vcd'],VCD_CSV_agreement=True)


def asm(word):
    op=word>>12;rd=(word>>10)&3;rs=(word>>8)&3;u=word&255;s=u if u<128 else u-256
    if op in [0,2,3,4,6,10]:return f"{dict(zip([0,2,3,4,6,10],['MOV','AND','OR','ADD','SUB','CMP']))[op]} R{rd}, R{rs}"
    if op in [1,5,7]:return f"{ {1:'MOV',5:'ADD',7:'SUB'}[op]} R{rd}, #{u}"
    if op in [8,9]:return f"{ {8:'LDR',9:'STR'}[op]} R{rd}, [R{rs}{'+'+str(s)if s>0 else str(s)if s<0 else ''}]"
    if op==12:return f'JUMP #{u}'
    if op==13:return f'JZ {s:+d}'
    return 'HALT'if op==14 else'Reserved'


def main():
    e=collect_frozen();records={}
    for p in sorted((PRE/'Vivado/验证记录').glob('*/result.json')):
        r=json.loads(p.read_text(encoding='utf-8'))
        if r.get('status')=='PASS'and r.get('kind')=='cpu'and r.get('mode')=='behavioral':
            if r['program']not in records or r['started_utc']>records[r['program']][1]['started_utc']:records[r['program']]=(p,r)
    assert set(records)=={'all_ops','baseline','loop','memory_copy','copy_checksum'}
    live={};paths=[]
    for name,(p,r)in records.items():
        for relative,digest in {**r['archived_input_sha256'],**r['output_sha256']}.items():assert sha(p.parent/relative)==digest
        t=actual_trace(p.parent);expect=r['expected'];assert len(t['rows'])==expect['CYCLES']and t['rf']==expect['rf']and t['flags']==expect['flags']
        native=p.parent/'outputs/vivado.log';log=native.read_text(encoding='utf-8',errors='replace')
        assert '$finish called at time'in log and not re.search(r'(?m)^ERROR:|^CRITICAL WARNING:|^Fatal:',log)
        live[name]={'source':p.relative_to(REPO).as_posix(),'actual':r['actual'],'rf':t['rf'],'flags':t['flags'],
                    'rows':t['rows'],'VCD_CSV_agreement':True,'scope':'native behavioral XSim'}
        paths += [p,native,*t['source_files'],p.parent/'inputs/data/dut_im.mem',p.parent/'inputs/data/dut_dm.mem',p.parent/'inputs/tb/selected_expected.svh']
    e['fresh_programs']=live;e.pop('new_hardware_or_XSim_execution',None)
    e.pop('new_XSim_execution',None);e['collector_launches_XSim']=False;e['new_physical_board_execution']=False
    e['collection_scope']='Read-only collection of retained native records, dated by each source result.json; this collector launches no EDA or hardware flow.'
    e['source_groups']['LIVE']=[p.relative_to(REPO).as_posix()for p in paths]
    baseline=records['baseline'][0].parent
    words=[int(x,16)for x in (baseline/'inputs/data/dut_im.mem').read_text().splitlines()]
    e['baseline_assembly']=[dict(pc=f'{i:02X}',word=f'{w:04X}',asm=asm(w))for i,w in enumerate(words[:11])]
    rows=live['baseline']['rows'];shown=rows[5:13];assert [int(r['cycle'])for r in shown]==list(range(6,14))
    lanes=[dict(name='cycle',wave='='*8,data=[r['cycle']for r in shown])]
    for signal in ['stall','redirect','dm_we','wb_valid']:
        bits=[int(r[signal])for r in shown];lanes.append(dict(name=signal,wave=''.join(str(v)if i==0 or v!=bits[i-1]else'.'for i,v in enumerate(bits))))
    wave={'signal':lanes,'head':{'text':'baseline / XSim / C6 to C13'},'foot':{'text':'Rising-edge VCD samples / 10 ns cycle'},'config':{'hscale':1.5}}
    write(B/'图源/r3/baseline_waveform.json5',wave)
    e['waveform']={'case':'baseline','plot_cycle_range':[6,13],'VCD_CSV_agreement':True,'rows':rows}
    figdir=B/'图源/r3';drawings=[p for p in figdir.iterdir()if p.is_file()and p.suffix in ['.svg','.png','.json','.json5']]
    e['source_groups']['FIGURES']=[p.relative_to(REPO).as_posix()for p in drawings]
    e['source_groups']['FORWARD_CANDIDATE']=['CPU核心设计/实验/前递候选比较.json']
    e['source_groups']['REFERENCE']=['CPU核心设计/板级/benchmark_programs.py','CPU核心设计/Vivado/verification/isa_reference.py']+[
        f'Pre6_CPU集成与验证/Vivado/benchmarks/{program}/{name}'
        for program in records for name in ['dut_im.mem','dut_dm.mem','selected_expected.svh']]
    e['forward_candidate']=json.loads((REPO/'CPU核心设计/实验/前递候选比较.json').read_text(encoding='utf-8'))
    extra={p:sha(REPO/p)for code in ['LIVE','FIGURES','REFERENCE']for p in e['source_groups'][code]}
    e['additional_source_sha256']=extra
    write(B/'evidence.json',e)
    count=lambda t:len(re.findall(r"[A-Za-z0-9]+(?:['.-][A-Za-z0-9]+)*",t))
    content=dict(revision='Pre6-r5',main=SLIDES,backup=[],questions=QUESTIONS,team=TEAM,main_seconds=840,buffer_seconds=60,spoken_words=sum(count(s['speech'])for s in SLIDES))
    write(B/'content.json',content)
    hashes={**e['input_sha256'],**extra};index=[]
    for page,s in enumerate(SLIDES,1):
        codes=list(s['refs'])
        if s['reference_page']in [2,5,6,7,8,9,10]:codes+=['FIGURES']
        if s['reference_page']in [16,17,18]:codes+=['REFERENCE']
        names=list(dict.fromkeys(n for c in codes for n in e['source_groups'][c]))
        row=dict(slide=page,reference_page=s['reference_page'],code=s['code'],title=s['title'],claim=s['goal'],source_groups=codes,
                 sources=[dict(relative=n,sha256=hashes[n])for n in names],expected='ISA v1.5 / AC1 contracts',
                 supports='Source-bound instruction behavior, actual XSim samples, archived VIO samples or named routed reports as shown.')
        ref=s['reference_page']
        if ref in [13,14,15]:row['actual']=[x for x in e['examples']if x['case']in{13:['DOC_LOAD_STR','DOC_ADD_ADD'],14:['DOC_CMP_JZ'],15:['DOC_STR_HALT','MEM_FAULT_OVER_BRANCH']}[ref]]
        elif ref==17:row['actual']=live['baseline']
        elif ref==18:row['actual']={'physical_programs':e['programs'],'S1':e['button']};row['raw_S1_notes']=e['raw_button']
        elif ref in [19,20]:row['actual']=e['programs']
        elif ref==21:row['actual']=e['routed']
        elif ref==22:row['actual']={'WB_MEM':e['candidate'],'forwarding_MUX':e['forward_candidate']}
        else:row['actual']={'contract':e['baseline_commit'],'source_groups':codes}
        index.append(row)
    write(B/'source_map.json',index)
    print('R3_EVIDENCE_READY',len(SLIDES),'main pages;',content['spoken_words'],'words; 5 native program/VCD agreements')


if __name__=='__main__':main()
