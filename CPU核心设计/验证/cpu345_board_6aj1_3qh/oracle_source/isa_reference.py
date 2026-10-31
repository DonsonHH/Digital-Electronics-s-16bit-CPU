"""Independent sequential ISA v1.5 oracle, promoted without RTL dependencies."""
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
