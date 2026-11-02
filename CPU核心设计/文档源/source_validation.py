"""Read-only RTL/fixture/trace gates for the architecture document. No hardware access."""
from pathlib import Path
import csv,hashlib,json,re,subprocess
from io import StringIO

P=Path(__file__).resolve().parents[1];ROOT=P.parent;V=P/'Vivado'
BASELINE='0d888cc65a8b650575317be7fa5d5d4040266abf'
ORACLES=['generate_independent.py','isa_reference.py','independent_vectors.py','test_manifest.json','ISA_v1.5_contract.md','frozen48_content.json']

def require(value,message):
    if not value:raise ValueError(message)
def sha(path):return hashlib.sha256(Path(path).read_bytes()).hexdigest()
def read(path):return json.loads(Path(path).read_text(encoding='utf-8-sig'))
def source_bytes(relative):return subprocess.check_output(['git','show',BASELINE+':'+relative],cwd=ROOT)

def check_canonical_outputs(run,rtl,new_receipt):
    contract=read(Path(__file__).with_name('canonical_outputs.json'))
    require(contract['source_commit']==BASELINE,'Canonical CSV baseline was not reviewed')
    require(set(contract['files'])=={'independent_results.csv','independent_cycles.csv'},'Both canonical CSV contracts are mandatory')
    manifest=json.loads(source_bytes('CPU核心设计/文件SHA256.json'))['files']
    relative=contract['reference_record'];reference=P/relative
    digest=manifest.get(relative+'/independent_result.json')
    require(digest==contract['reference_receipt_sha256']==sha(reference/'independent_result.json'),'Canonical CSV reference receipt changed')
    receipt=read(reference/'independent_result.json')
    require(receipt['status']=='PASS' and receipt['new_xsim_execution'] and receipt['native_execution_complete'],'Canonical CSV reference is not a completed native run')
    for name,value in rtl.items():require(receipt['input_sha256']['rtl/'+name]==value,'Canonical CSV reference uses different RTL')
    consumed={}
    for name,digest in contract['files'].items():
        require(digest==manifest.get(relative+'/'+name)==sha(reference/name),'Canonical CSV digest differs from the pinned published manifest')
        consumed[name]=(Path(run)/name).read_bytes()
        require(hashlib.sha256(consumed[name]).hexdigest()==digest,'Independent canonical CSV output changed: '+name)
    for name,digest in new_receipt['input_sha256'].items():
        if name.startswith('programs/') or name in ['cases.json','case_config.svh','case_count.svh','tb_adversarial.sv']:
            require(receipt['input_sha256'][name]==digest,'Canonical CSV reference uses different frozen input: '+name)
    return contract,consumed

def check_rtl_contract(plan):
    require(plan['baseline_commit']==BASELINE,'Architecture baseline must be explicitly reviewed before it changes')
    paths=list((V/'rtl').glob('*'))+list((P/'系统/rtl').glob('*'))
    paths=[p for p in paths if p.is_file()]
    require(len(paths)==14,'Expected thirteen core files and one system file')
    for path in paths:require(path.read_bytes()==source_bytes(path.relative_to(ROOT).as_posix()),'Production RTL changed: '+str(path))
    for name in ['operand_forward.v','datapath_core.sv']:
        folder='forward_onehot'if name=='operand_forward.v'else'wb_mem'
        path=P/'实验/候选'/folder/name
        require(path.read_bytes()==source_bytes(path.relative_to(ROOT).as_posix()),'Isolated experimental RTL changed')
    text=(V/'rtl/datapath_core.sv').read_text(encoding='utf-8')
    declarations={}
    for match in re.finditer(r'^\s*reg\s*(?:\[(\d+):(\d+)\])?\s+([^;]+);',text,re.M):
        width=abs(int(match[1])-int(match[2]))+1 if match[1]else 1
        for name in match[3].split(','):declarations[name.strip().split('=')[0].strip()]=width
    for name,group in plan['control_groups'].items():
        require(sum(group['fields'].values())==group['width'],'CW group total differs: '+name)
        for field,width in group['fields'].items():require(declarations.get(group['prefix']+field)==width,'CW declaration differs: '+group['prefix']+field)
    # Identify each CLOCKED begin/end block independently of field naming.
    # Assignment alternatives inside one block do not create extra owners.
    owners={};blocks=[]
    clean=re.sub(r'//[^\n]*|/\*[\s\S]*?\*/','',text)
    for match in re.finditer(r'always\s*@\(posedge clk\)\s*begin',clean):
        start=match.end();depth=1;end=None
        for token in re.finditer(r'\bbegin\b|\bend\b',clean[start:]):
            depth+=1 if token[0]=='begin'else-1
            if depth==0:end=start+token.end();break
        require(end is not None,'Unbalanced clocked block')
        fields=set(re.findall(r'\b(\w+)\s*<=',clean[start:end]));blocks.append(fields)
        for field in fields:owners.setdefault(field,[]).append(len(blocks)-1)
    require(len(blocks)==2,'Review clocked ownership before changing the architecture text')
    for field in ['mode','d_valid','x_valid','m_valid','w_valid']:
        require(owners.get(field)==[1],'Pipeline state ownership differs: '+field)
    for field in ['x_reason','m_reason','w_reason','stop_pc','stop_valid']:
        require(owners.get(field)==[0],'Diagnostic state ownership differs: '+field)
    for instance in ['regfile4x16 u_rf','flags_reg u_flags','pc16 u_pc']:
        require(text.count(instance)==1,'Architectural state instance is not unique: '+instance)
    return {p.relative_to(P).as_posix():sha(p)for p in paths}

def verify_independent(run):
    run=Path(run);r=read(run/'independent_result.json')
    require(r['status']=='PASS' and r['new_xsim_execution'] is True and r['native_execution_complete'] is True,'Fresh independent execution missing')
    require(type(r['native_exit'])is int and r['native_exit']==0 and r['error']is None,'Independent execution lifecycle incomplete')
    frozen=read(V/'verification/frozen48_content.json')['files']
    rtl={p.name:sha(p)for p in(V/'rtl').iterdir()if p.is_file()}
    expected=set(frozen)|{'oracle_source/'+n for n in ORACLES}|{'manifest.json','desktop_launch.py','run.cmd','run.tcl'}|{'rtl/'+n for n in rtl}
    require(set(r['input_sha256'])==expected,'Independent executed-input inventory differs')
    for name,digest in r['input_sha256'].items():require(sha(run/name)==digest,'Independent input changed: '+name)
    for name,digest in frozen.items():
        if name!='tb_adversarial.sv':require(hashlib.sha256((run/name).read_bytes().replace(b'\r\n',b'\n')).hexdigest()==digest,'Frozen fixture changed: '+name)
    for name,digest in rtl.items():require(r['input_sha256']['rtl/'+name]==digest,'Fresh trace is not for the current default RTL: '+name)
    require(sha(run/'console.log')==r['console_sha256'] and sha(run/'private.log')==r['log_sha256'],'Independent native logs changed')
    log=(run/'private.log').read_text(encoding='utf-8',errors='replace')
    marker='ADVERSARIAL_PASS cases=48 reset_witnesses=10 failures=0 oracle=external_python memory=independent_sync'
    require(log.splitlines().count(marker)==1 and '$finish called at time' in log and not re.search(r'(?m)^Fatal:|^ERROR:',log),'Independent terminal/negative markers failed')
    contract,consumed=check_canonical_outputs(run,rtl,r)
    rows=list(csv.DictReader(StringIO(consumed['independent_results.csv'].decode('utf-8-sig'))))
    expected_labels=read(V/'verification/test_manifest.json')['frozen_independent48']['labels']
    require(len(rows)==58 and len({(row['case'],row['epoch'])for row in rows})==58 and {row['case']for row in rows}==set(expected_labels),'Independent result coverage differs')
    cycles=list(csv.DictReader(StringIO(consumed['independent_cycles.csv'].decode('utf-8-sig'))))
    require(len(cycles)==952,'Independent cycle row count differs from the unchanged pipeline')
    canonical=(V/'verification/tb_adversarial.sv').read_text(encoding='utf-8')
    replacement='datapath_core dut(.clk(clk),.rst(rst),.im_addr(im_addr),.im_en(im_en),.im_dout(im_dout),.dm_addr(dm_addr),.dm_en(dm_en),.dm_we(dm_we),.dm_din(dm_din),.dm_dout(dm_dout),.halted(halted),.fault(fault));'
    require((run/'tb_adversarial.sv').read_text(encoding='utf-8')==canonical.replace('datapath_core dut(.*);',replacement),'Independent checker changed beyond the reviewed connection adapter')
    return r,rows,cycles,read(run/'cases.json')

OP_NAMES={0:'MOV',1:'MOV',2:'AND',3:'OR',4:'ADD',5:'ADD',6:'SUB',7:'SUB',8:'LDR',9:'STR',10:'CMP',11:'RES',12:'JUMP',13:'JZ',14:'HALT',15:'RES'}
def stage_text(row,letter,bit,image):
    if not int(row['DXMW_valid'],2)&(1<<bit):return '—'
    pc=int(row[letter+'_pc'],16);return f'{pc:02X}:{OP_NAMES[image[pc]>>12]}'if pc<256 else f'{pc:04X}:FAULT'
def format_instruction(word):
    op=word>>12;d=(word>>10)&3;s=(word>>8)&3;b=word&255;name=OP_NAMES[op]
    if op in [0,2,3,4,6,10]:return f'{name} R{d},R{s}'
    if op in [1,5,7]:return f'{name} R{d},#{b}'
    if op in [8,9]:return f'{name} R{d},[R{s}{b if b<128 else b-256:+d}]'
    if op==12:return f'JUMP #{b}'
    if op==13:return f'JZ #{b if b<128 else b-256:+d}'
    return name

def extract_examples(plan,run):
    receipt,results,cycles,cases=verify_independent(run);bycase={c['label']:c for c in cases};out=[]
    for spec in plan['examples']:
        c=bycase[spec['case']];trace=[r for r in cycles if r['case']==spec['case'] and r['epoch']=='0']
        result=next(r for r in results if r['case']==spec['case'] and r['epoch']=='0')
        require(len(trace)==int(result['cycles']),'Worked-example cycle total differs')
        table=[]
        for r in trace:
            actions=[]
            if r['load_use']=='1':actions.append('保持IF/ID；X插bubble')
            if r['redirect']=='1':actions.append('EX重定向；取消年轻槽')
            if r['rf_we']=='1':
                e=c['expected']['events'][int(r['wb_count'])-1]
                require(e['pc']==int(r['w_pc'],16) and e['rw']==1,'WB event annotation differs')
                actions.append(f'RF R{e["d"]}←{e["data"]:04X}')
            if r['z_we']=='1':actions.append('WB写Z')
            if r['cv_we']=='1':actions.append('WB写C/V')
            if r['dm_we']=='1':actions.append(f'DM[{r["dm_addr"].upper()}]←{r["dm_din"].upper()}')
            if r['stop']=='10':actions.append('停止HALTED')
            if r['stop']=='01':actions.append('停止FAULTED')
            if spec['case']=='MEM_FAULT_OVER_BRANCH' and stage_text(r,'m',1,c['image'])=='02:LDR':
                require(stage_text(r,'x',2,c['image'])=='03:JUMP' and r['redirect']=='0' and r['dm_en']=='0' and r['rf_we']=='1' and r['cv_we']=='1','Older-MEM-fault witness missing')
                actions.append('M越界压制EX跳转；老WB保留')
            ifetch=f'{int(r["fetch_pc"],16):02X}'if r['im_en']=='1'else'—'
            table.append(['C'+r['cycle'],ifetch]+[stage_text(r,n,b,c['image'])for n,b in [('d',3),('x',2),('m',1),('w',0)]]+['；'.join(actions)or'正常推进'])
        last_program_word=max(i for i,word in enumerate(c['image'])if word!=0xb000)
        out.append(dict(**spec,initial_rf=c['initial_rf'],initial_flags=c['initial_flags'],instructions=[f'{i:02X}: {format_instruction(word)} ({word:04X})'for i,word in enumerate(c['image'])if i<=last_program_word],rows=table,result=result,final_rf=c['expected']['rf'],final_flags=c['expected']['flags'],stores=c['expected']['stores']))
    return dict(status='PASS',source_receipt_sha256=sha(Path(run)/'independent_result.json'),trace_sha256=sha(Path(run)/'independent_cycles.csv'),examples=out)
