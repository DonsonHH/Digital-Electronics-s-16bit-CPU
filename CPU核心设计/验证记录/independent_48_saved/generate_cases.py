"""Spec-derived sequential oracle. No RTL import, pipeline control or DUT model."""
from pathlib import Path
import json, hashlib, shutil, sys

ROOT=Path(__file__).resolve().parent
AUDIT=ROOT.parent
OPS={0:'MOV',1:'MOVI',2:'AND',3:'OR',4:'ADD',5:'ADDI',6:'SUB',7:'SUBI',8:'LDR',9:'STR',10:'CMP',11:'ReservedB',12:'JUMP',13:'JZ',14:'HALT',15:'ReservedF'}
def ins(op,d=0,s=0,b=0):
    if op not in OPS or not 0<=d<4 or not 0<=s<4 or not -128<=b<=255: raise ValueError('Bad encoding')
    return op*4096+d*1024+s*256+(b%256)
def signed(x,bits): return x if x<2**(bits-1) else x-2**bits
def pack(e):
    z,c,v=e['flags']
    return (e['pc'] | e['op']<<16 | e['d']<<20 | e['data']<<22 | (z*4+c*2+v)<<38 |
            e['rw']<<41 | e['zw']<<42 | e['cvw']<<43 | e['halt']<<44 | e['store']<<45 |
            e['fault']<<46 | e['addr']<<47)
def oracle(image,memory,rf=None,flags=None):
    r=list(rf or [0,0,0,0]); mem=list(memory); z,c,v=list(flags or [0,0,0]);pc=0
    events=[]; stores=[]
    for _ in range(4096):
        word=image[pc] if pc<256 else 0xb000
        op=word//4096;d=(word//1024)%4;s=(word//256)%4;b=word%256
        e=dict(pc=pc,word=word,op=op,d=d,data=0,flags=[z,c,v],rw=0,zw=0,cvw=0,halt=0,store=0,fault=0,addr=0)
        nextpc=(pc+1)%65536
        if pc>=256 or op in (11,15): e['fault']=1
        elif op==0: r[d]=r[s];e['rw']=1
        elif op==1: r[d]=b;e['rw']=1
        elif op in (2,3): r[d]=(r[d]&r[s]) if op==2 else (r[d]|r[s]);e['rw']=1
        elif op in (4,5,6,7):
            a=r[d];bb=b if op in (5,7) else r[s];subtract=op in (6,7)
            exact=a-bb if subtract else a+bb
            exact_signed=signed(a,16)-signed(bb,16) if subtract else signed(a,16)+signed(bb,16)
            r[d]=exact%65536;c=int(a>=bb) if subtract else int(exact>=65536)
            v=int(not -32768<=exact_signed<=32767);e['rw']=e['cvw']=1
        elif op in (8,9):
            addr=(r[s]+signed(b,8))%65536;e['addr']=addr
            if addr>=256:e['fault']=1
            elif op==8:r[d]=mem[addr];e['rw']=1
            else: mem[addr]=r[d];e['data']=r[d];e['store']=1
        elif op==10:z=int(r[d]==r[s]);e['zw']=1
        elif op==12:nextpc=b
        elif op==13:
            if z:nextpc=(pc+1+signed(b,8))%65536
        elif op==14:e['halt']=1
        else:raise RuntimeError('Unsupported ISA')
        if e['rw']:e['data']=r[d]
        e['flags']=[z,c,v];e['sequence']=len(events);events.append(e)
        if e['store']:stores.append(e.copy())
        if e['halt'] or e['fault']:return dict(events=events,stores=stores,rf=r,dm=mem,flags=[z,c,v],fault=e['fault'],halt=e['halt'])
        pc=nextpc
    raise RuntimeError('Oracle timeout')

cases=[]
def add(label,words,dm=None,rf=None,flags=None,stalls=-1,cycles=-1,reset=0):
    image=[0xb000]*256
    for p,w in (words.items() if isinstance(words,dict) else enumerate(words)):
        if not 0<=p<256:raise ValueError('Program too long')
        image[p]=w
    memory=[(i*0x103+0xa55a)%65536 for i in range(256)]
    for p,w in (dm or {}).items(): memory[p]=w
    r=rf or [0,0,0,0];f=flags or [0,0,0]
    expected=oracle(image,memory,r,f)
    cases.append(dict(label=label,image=image,initial_dm=memory,initial_rf=r,initial_flags=f,expected=expected,stalls=stalls,cycles=cycles,reset=reset))

add('THREE_WRITERS_R0',[ins(1,0,b=1),ins(5,0,b=1),ins(5,0,b=1),ins(0,1,0),ins(4,0,1),ins(14)],stalls=0,cycles=10)
add('LATEST_LOAD_MANY_CONSUMERS',[ins(1,3,b=32),ins(1,0,b=1),ins(5,0,b=2),ins(8,0,3),ins(5,0,b=1),ins(0,1,0),ins(4,2,0),ins(9,2,3,1),ins(14)],dm={32:0x7fff},stalls=1,cycles=14)
add('STR_DATA_LOAD_W_BASE_M',[ins(1,3,b=32),ins(8,0,3),ins(1,1,b=33),ins(9,0,1),ins(8,2,1),ins(10,2,0),ins(13,b=1),ins(15),ins(14)],dm={32:0xbeef},stalls=1)
add('STR_DATA_M_BASE_W',[ins(1,1,b=33),ins(1,0,b=85),ins(9,0,1),ins(8,2,1),ins(14)],stalls=0,cycles=9)
add('LOAD_R0_RD_RS_SAME',[ins(1,3,b=32),ins(8,0,3),ins(9,0,0),ins(8,1,0),ins(10,1,0),ins(13,b=1),ins(11),ins(14)],dm={32:33},stalls=2)
add('FALSE_IMMEDIATE_RS',[ins(1,3,b=32),ins(8,0,3),ins(5,2,0,255),ins(7,1,0,255),ins(1,0,0,7),ins(14)],stalls=0,cycles=10)
add('WB_ID_AND_OVERWRITES',[ins(1,0,b=1),ins(1,1,b=2),ins(1,2,b=3),ins(5,0,b=1),ins(5,0,b=1),ins(0,3,0),ins(14)],stalls=0,cycles=11)
add('CMP_101_JZ',[ins(1,1,b=1),ins(10,0,0),ins(10,0,1),ins(10,1,1),ins(13,b=1),ins(9,1,0),ins(14)],stalls=0)
add('CMP_010_JZ',[ins(1,1,b=1),ins(10,0,1),ins(10,0,0),ins(10,0,1),ins(13,b=1),ins(1,2,b=85),ins(14)],stalls=0,cycles=11)
add('CMP_ACROSS_ALU_STORE_LOAD',[ins(1,3,b=32),ins(8,0,3),ins(10,0,0),ins(5,0,b=1),ins(7,0,b=1),ins(9,0,3,1),ins(8,1,3,1),ins(13,b=1),ins(15),ins(14)],dm={32:1},stalls=1)
add('CMP_LOAD_JZ_W_FALLBACK',[ins(1,3,b=32),ins(10,0,0),ins(8,0,3),ins(13,b=1),ins(9,0,3),ins(14)],dm={32:0xff55},stalls=0)
add('REFETCH_CANCELLED_HALT',[ins(10,0,0),ins(13,b=1),ins(9,0,0),ins(14),ins(9,0,0),ins(15)],stalls=0,cycles=9)
add('REFETCH_CANCELLED_STR',[ins(1,3,b=32),ins(1,0,b=85),ins(12,b=4),ins(14),ins(9,0,3),ins(14),ins(15)],stalls=0,cycles=11)
add('REFETCH_CANCELLED_RESERVED',[ins(12,b=2),ins(14),ins(15),ins(9,0,0)],stalls=0,cycles=8)
add('LOAD_BEFORE_HALT',[ins(1,3,b=32),ins(8,0,3),ins(14),ins(9,0,3,1)],dm={32:0x1234},stalls=0,cycles=7)
add('LEGAL_STR_BEFORE_HALT',[ins(1,3,b=32),ins(1,0,b=85),ins(9,0,3),ins(14),ins(9,1,3)],stalls=0,cycles=8)
add('MEM_FAULT_OVER_BRANCH',[ins(1,1,b=255),ins(5,0,b=1),ins(8,2,1,1),ins(12,b=5),ins(9,0,0),ins(14)],stalls=0)
add('MEM_FAULT_OVER_JZ',[ins(10,0,0),ins(1,1,b=255),ins(8,2,1,1),ins(13,b=1),ins(9,0,0),ins(14)],stalls=0)
add('MEM_FAULT_WITH_LOAD_USE',[ins(1,3,b=32),ins(1,0,b=255),ins(8,0,0,1),ins(8,1,3),ins(0,2,1),ins(14)],dm={32:7})
add('STR_BEFORE_MEM_FAULT',[ins(1,3,b=255),ins(1,0,b=85),ins(9,0,3),ins(8,1,3,1),ins(12,b=6),ins(9,1,0),ins(14)],stalls=0)
add('STR_BEFORE_RESERVED',[ins(1,3,b=32),ins(1,0,b=85),ins(9,0,3),ins(11),ins(15),ins(9,1,3)],stalls=0,cycles=8)
add('CONSECUTIVE_RESERVED',[ins(1,0,b=1),ins(15),ins(11),ins(14)],stalls=0,cycles=6)
add('EA_UPPER_FAULT_NO_ALIAS',[ins(1,1,b=255),ins(1,0,b=85),ins(9,0,1,1),ins(14)],dm={0:0xcafe,255:0xbeef},stalls=0)
add('EA_NEGATIVE_FAULT_NO_ALIAS',[ins(1,0,b=85),ins(9,0,1,-1),ins(14)],dm={255:0xbeef},stalls=0)
add('EA_MODULO_WRAP',[ins(1,3,b=32),ins(8,1,3),ins(1,0,b=85),ins(9,0,1,1),ins(8,2,1,1),ins(14)],dm={32:65535},stalls=0,cycles=10)
add('JZ_S8_LOW_PC_WRAP',[ins(10,0,0),ins(13,b=-128)],stalls=0)
add('FETCH_256_CORRECT_PATH',{0:ins(12,b=255),255:ins(1,0,b=1)},stalls=0,cycles=9)
add('FETCH_256_SQUASH',{0:ins(12,b=255),255:ins(12,b=2),2:ins(14)},stalls=0,cycles=11)

long=[ins(1,3,b=32),ins(1,0,b=1)]
for n in range(18):
    long += [ins(9,0,3,n%8),ins(8,1,3,n%8),ins(5,1,b=1),ins(10,1,0),ins(13,b=1),ins(5,0,b=1),ins(10,0,1),ins(13,b=1),ins(15),ins(2,0,1),ins(3,0,1)]
long += [ins(14)]
add('LONG_ALTERNATING_18_ROUNDS',long,stalls=18)
add('LONG_LOOP_MEMORY_CONSUMERS',[ins(1,3,b=32),ins(1,0,b=15),ins(1,1,b=0),ins(9,0,3),ins(8,2,3),ins(5,2,b=1),ins(5,2,b=1),ins(10,2,0),ins(13,b=5),ins(7,0,b=1),ins(10,0,1),ins(13,b=2),ins(12,b=3),ins(15),ins(14)],stalls=15)
add('FLAGS_CV_Z_LONG_LIFETIMES',[ins(1,3,b=32),ins(8,0,3),ins(8,1,3,1),ins(4,0,1),ins(10,1,1),ins(9,0,3,3),ins(8,2,3,3),ins(2,2,0),ins(3,2,1),ins(13,b=1),ins(15),ins(6,0,1),ins(14)],dm={32:0x7fff,33:1},stalls=2)
add('IGNORED_FIELDS_BOTH_SIGNS',[ins(1,3,2,32),ins(1,0,1,255),ins(0,1,0,255),ins(5,1,3,255),ins(7,1,2,255),ins(2,0,1,255),ins(3,0,1,128),ins(10,0,1,255),ins(13,3,3,1),ins(15),ins(14,3,3,255)],stalls=0)
add('SUPP_MOV_ALU_TO_CMP',[ins(1,1,b=1),ins(1,0,b=1),ins(10,0,1),ins(13,b=1),ins(15),ins(14)],stalls=0,cycles=11)
add('SUPP_G1_INTERVENING_LOAD_STALL',[ins(1,3,b=32),ins(8,0,3),ins(8,1,0),ins(4,2,0),ins(14)],dm={32:33,33:5},stalls=1,cycles=10)

# The four formal Buffer/Interlock tables intentionally use their stated RF fixtures.
add('DOC_ADD_ADD',[0x4100,0x4800,0xe000],rf=[1,2,4,0],stalls=0,cycles=7)
add('DOC_LOAD_STR',[0x8300,0x9100,0xe000],rf=[0,33,0,32],dm={32:7},stalls=1,cycles=8)
add('DOC_CMP_JZ',[0xa100,0xd001,0x9300,0xe000],rf=[1,1,0,32],stalls=0,cycles=9)
add('DOC_STR_HALT',[0x9100,0xe000,0x9900],rf=[0xbeef,33,0x1234,0],stalls=0,cycles=6)

# Reset tests run a checked prefix, then discard in-flight instructions and restart.
reset_program=[ins(1,3,b=32),ins(1,0,b=85),ins(9,0,3),ins(1,2,b=0),ins(8,1,3),ins(5,1,b=1),ins(10,1,0),ins(13,b=1),ins(12,b=10),ins(15),ins(14)]
for code,label in [(1,'RESET_LOAD_USE'),(2,'RESET_REDIRECT'),(3,'RESET_DRAIN_HALT'),(4,'RESET_BEFORE_STORE'),(5,'RESET_AFTER_STORE'),(6,'RESET_HALT_WB')]:
    add(label,reset_program,reset=code)
for code,label in [(7,'RESET_DRAIN_FAULT'),(8,'RESET_FAULT_WB'),(9,'RESET_HALTED'),(10,'RESET_FAULTED')]:
    add(label,[ins(1,0,b=1),ins(11) if code in (7,8,10) else ins(14),ins(9,0,0)],reset=code)

def write_hex(p,values,width): p.write_text('\n'.join(f'{x:0{width}x}' for x in values)+'\n',encoding='ascii')
def write_case(c,prefix):
    folder=ROOT/'programs';folder.mkdir(exist_ok=True)
    write_hex(folder/f'{prefix}_im.mem',c['image'],4)
    write_hex(folder/f'{prefix}_dm.mem',c['initial_dm'],4)
    write_hex(folder/f'{prefix}_rf.mem',c['initial_rf'],4)
    write_hex(folder/f'{prefix}_events.mem',[pack(e) for e in c['expected']['events']],16)
    if c['expected']['stores']:write_hex(folder/f'{prefix}_stores.mem',[pack(e)|(e['sequence']<<63) for e in c['expected']['stores']],20)
    write_hex(folder/f'{prefix}_final_dm.mem',c['expected']['dm'],4)
    write_hex(folder/f'{prefix}_final_rf.mem',c['expected']['rf'],4)

def main():
    work=AUDIT/'runs'/(sys.argv[1] if len(sys.argv)>1 else 'adversarial_native')
    work.mkdir(exist_ok=False)
    shutil.copytree(AUDIT/'snapshot'/'Vivado'/'rtl',work/'rtl')
    shutil.copy2(AUDIT/'snapshot'/'Vivado'/'desktop_launch.py',work/'desktop_launch.py')
    configs=[]
    for i,c in enumerate(cases):
        prefix=f'case_{i:02d}';c['prefix']=prefix;write_case(c,prefix)
        f=c['initial_flags'];count=len(c['expected']['events']);nstores=len(c['expected']['stores'])
        cfg=f'{i}:begin label="{c["label"]}";prefix="{prefix}";token_count={count};store_count={nstores};initial_flags=3\'d{f[0]*4+f[1]*2+f[2]};expect_cycles={c["cycles"]};expect_stalls={c["stalls"]};reset_kind={c["reset"]};end'
        if c['reset']:
            after=list(c['initial_dm'])
            if c['reset'] in (1,2,3,5,6):after[32]=85
            restart_image=[ins(1,3,b=32),ins(8,0,3),ins(14)]+[0xb000]*253
            restart=dict(image=restart_image,initial_dm=after,initial_rf=[0]*4,initial_flags=[0]*3,expected=oracle(restart_image,after))
            c['restart']=restart;write_case(restart,prefix+'_restart')
            cfg=cfg[:-3]+f'restart_token_count={len(restart["expected"]["events"])};restart_store_count=0;end'
        configs.append(cfg)
    (ROOT/'case_config.svh').write_text('case(case_id)\n'+'\n'.join(configs)+'\ndefault:$fatal(1,"BAD_CASE_ID");\nendcase\n',encoding='ascii')
    (ROOT/'case_count.svh').write_text(f'localparam CASES = {len(cases)};\n',encoding='ascii')
    (ROOT/'cases.json').write_text(json.dumps(cases,indent=2),encoding='utf-8')
    (ROOT/'case_summary.json').write_text(json.dumps([dict(label=c['label'],words=sum(x!=0xb000 for x in c['image']),tokens=len(c['expected']['events']),stores=len(c['expected']['stores']),stalls=c['stalls'],cycles=c['cycles'],reset=c['reset']) for c in cases],indent=2),encoding='utf-8')
    (ROOT/'contract_binding.json').write_text(json.dumps({'independent_contract_sha256':hashlib.sha256((AUDIT/'spec'/'independent_contract_before_rtl.md').read_bytes()).hexdigest(),'oracle_sha256':hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),'case_count':len(cases),'scope':'Sequential ISA, full state and ordered events; no forwarding/stall/mode logic in oracle'},indent=2),encoding='utf-8')
    print('SPEC_DERIVED_CASES',len(cases))

if __name__=='__main__':main()
