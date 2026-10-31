"""Generate the frozen directed ISA fixtures without workspace or RTL dependencies."""
from pathlib import Path
import argparse,copy,hashlib,json,shutil
from verification.independent_vectors import cases
from verification.isa_reference import ins,oracle,pack
BASE=Path(__file__).resolve().parent
def write_hex(p,values,width): p.write_text('\n'.join(f'{x:0{width}x}' for x in values)+'\n',encoding='ascii')

def write_case(c,prefix,output):
    folder=output/'programs';folder.mkdir(exist_ok=True)
    write_hex(folder/f'{prefix}_im.mem',c['image'],4)
    write_hex(folder/f'{prefix}_dm.mem',c['initial_dm'],4)
    write_hex(folder/f'{prefix}_rf.mem',c['initial_rf'],4)
    write_hex(folder/f'{prefix}_events.mem',[pack(e) for e in c['expected']['events']],16)
    if c['expected']['stores']:write_hex(folder/f'{prefix}_stores.mem',[pack(e)|(e['sequence']<<63) for e in c['expected']['stores']],20)
    write_hex(folder/f'{prefix}_final_dm.mem',c['expected']['dm'],4)
    write_hex(folder/f'{prefix}_final_rf.mem',c['expected']['rf'],4)
def generate(output):
    output=Path(output).resolve()
    contract=json.loads((BASE/'verification/test_manifest.json').read_text(encoding='utf-8'))
    vectors=copy.deepcopy(cases)
    expected=contract['frozen_independent48']
    if len(vectors)!=expected['case_count'] or [c['label'] for c in vectors]!=expected['labels']:
        raise ValueError('Directed fixture identity differs from reviewed test manifest')
    output.mkdir(parents=True,exist_ok=False)
    configs=[]
    for i,c in enumerate(vectors):
        prefix=f'case_{i:02d}';c['prefix']=prefix;write_case(c,prefix,output)
        f=c['initial_flags'];count=len(c['expected']['events']);nstores=len(c['expected']['stores'])
        cfg=f'{i}:begin label="{c["label"]}";prefix="{prefix}";token_count={count};store_count={nstores};initial_flags=3\'d{f[0]*4+f[1]*2+f[2]};expect_cycles={c["cycles"]};expect_stalls={c["stalls"]};reset_kind={c["reset"]};end'
        if c['reset']:
            after=list(c['initial_dm'])
            if c['reset'] in (1,2,3,5,6):after[32]=85
            restart_image=[ins(1,3,b=32),ins(8,0,3),ins(14)]+[0xb000]*253
            restart=dict(image=restart_image,initial_dm=after,initial_rf=[0]*4,initial_flags=[0]*3,expected=oracle(restart_image,after))
            c['restart']=restart;write_case(restart,prefix+'_restart',output)
            cfg=cfg[:-3]+f'restart_token_count={len(restart["expected"]["events"])};restart_store_count=0;end'
        configs.append(cfg)
    (output/'case_config.svh').write_text('case(case_id)\n'+'\n'.join(configs)+'\ndefault:$fatal(1,"BAD_CASE_ID");\nendcase\n',encoding='ascii')
    (output/'case_count.svh').write_text(f'localparam CASES = {len(vectors)};\n',encoding='ascii')
    (output/'cases.json').write_text(json.dumps(vectors,indent=2),encoding='utf-8')
    shutil.copy2(BASE/'verification/tb_adversarial.sv',output/'tb_adversarial.sv')
    source_folder=output/'oracle_source';source_folder.mkdir()
    for name in ['generate_independent.py','verification/isa_reference.py','verification/independent_vectors.py','verification/test_manifest.json','verification/ISA_v1.5_contract.md','verification/frozen48_content.json']:
        shutil.copy2(BASE/name,source_folder/Path(name).name)
    hashes={p.relative_to(output).as_posix():hashlib.sha256(p.read_bytes()).hexdigest() for p in output.rglob('*') if p.is_file()}
    manifest={'schema':1,'ISA':'v1.5','case_count':48,'labels':expected['labels'],'expected_reset_witnesses':10,'expected_result_rows':58,'input_sha256':hashes,'isa_contract_sha256':hashlib.sha256((BASE/'verification/ISA_v1.5_contract.md').read_bytes()).hexdigest(),'source_sha256':{n:hashlib.sha256((BASE/n).read_bytes()).hexdigest() for n in ['generate_independent.py','verification/isa_reference.py','verification/independent_vectors.py','verification/test_manifest.json']}}
    (output/'manifest.json').write_text(json.dumps(manifest,indent=2),encoding='utf-8')
    return manifest
def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--output',type=Path,required=True)
    a=p.parse_args();m=generate(a.output)
    print('FROZEN_INDEPENDENT_GENERATED cases='+str(m['case_count'])+' output='+str(a.output.resolve()))
if __name__=='__main__':main()
