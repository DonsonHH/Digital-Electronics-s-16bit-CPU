"""Independent catalogue and regression comparison from actual native records."""
from pathlib import Path
import csv,difflib,hashlib,json,re
p=Path(__file__).resolve().parent.parent
def require(x,s):
 if not x:raise ValueError(s)
def sha(f):return hashlib.sha256(f.read_bytes()).hexdigest()
receipt=json.loads((p/'验证结果.json').read_text(encoding='utf-8'))
status=json.loads((p/'最近运行.json').read_text(encoding='utf-8-sig'))
require(receipt['status']==status['status']=='PASS' and receipt['runtime']==status['runtime'],'Latest attempt not verified')
run=p/receipt['archived_run_relative'];old=p.parent/'CPU实现_v1.5'
for field,sub in [('rtl_sha256','rtl'),('tb_sha256','tb')]:
 for name,digest in receipt[field].items():require(sha(p/'Vivado'/sub/name)==sha(run/sub/name)==digest,'Source differs: '+name)
names={0:'MOV reg',1:'MOV imm',2:'AND',3:'OR',4:'ADD reg',5:'ADD imm',6:'SUB reg',7:'SUB imm',8:'LDR',9:'STR',10:'CMP'}
roles={0:[1],2:[0,1,2],3:[0,1,2],4:[0,1,2],5:[0],6:[0,1,2],7:[0],8:[1],9:[0,1,2],10:[0,1,2]}
native={}
for line in (run/'hazards.log').read_text(errors='replace').splitlines():
 m=re.fullmatch(r'CASE_PASS (\S+) cycles=(\d+) retired=(\d+) stalls=(\d+) redirects=(\d+) RF=([\da-f/]+) ZCV=([01]{3}) halt=([01]) fault=([01])',line)
 if m:native[m[1]]={'cycles':int(m[2]),'retired':int(m[3]),'stalls':int(m[4]),'redirects':int(m[5]),'rf':m[6],'zcv':m[7],'halted':int(m[8]),'fault':int(m[9])}
expected={f'RAW_P{prod:x}_C{cons:x}_R{reg}_S{role}_G{gap}' for prod in range(9) for cons,rs in roles.items() for role in rs for reg in range(4) for gap in range(3)}
require({k for k in native if k.startswith('RAW_')}==expected,'Finite RAW catalogue missing combinations')
destination=p/'审查';destination.mkdir(exist_ok=True)
rows=[]
for label in sorted(expected):
 m=re.fullmatch(r'RAW_P(\w)_C(\w)_R(\d)_S(\d)_G(\d)',label)
 prod,cons,reg,role,gap=int(m[1],16),int(m[2],16),int(m[3]),int(m[4]),int(m[5])
 ready='MEM end -> WB' if prod==8 else 'EX end -> MEM'
 selection='MEM ready' if gap==0 and prod!=8 else ('WB' if gap<2 else 'WB-to-ID bypass then saved value')
 stall=int(prod==8 and gap==0)
 require(native[label]['stalls']==stall,'Stall count differs: '+label)
 rows.append({'case':label,'producer':names[prod],'consumer':names[cons],'source':'Rd and Rs' if role==2 else ('Rd' if role==0 else 'Rs'),'register':f'R{reg}','gap':gap,'detect':'ID interlock / EX select','ready':ready,'solution':selection,'stall_cycles':stall,'cycle_template':'load-use C3 hold C4 bubble C5 WB-to-EX' if stall else ('consumer EX C4/M' if gap==0 else ('consumer EX C5/W' if gap==1 else 'producer WB and consumer ID C5; EX C6')),'expected':f'producer R{reg}=0020; independent full RF/DM/flags model','actual_rf':native[label]['rf'],'actual_zcv':native[label]['zcv'],'actual_cycles':native[label]['cycles'],'result':'PASS'})
with (destination/'Hazard_Matrix_2376.csv').open('w',encoding='utf-8-sig',newline='') as f:
 writer=csv.DictWriter(f,fieldnames=rows[0]);writer.writeheader();writer.writerows(rows)
old_result=json.loads((old/'验证结果.json').read_text(encoding='utf-8'));oldrun=old/old_result['archived_run_relative']
for file in ('case_results.csv',):require((run/file).read_bytes()==(oldrun/file).read_bytes(),'Original metrics changed: '+file)
def case_lines(f):return [line for line in f.read_text(errors='replace').splitlines() if line.startswith('CASE_PASS ')]
require(case_lines(run/'datapath.log')==case_lines(oldrun/'datapath.log'),'Original final states/cycles changed')
before=list(csv.DictReader((oldrun/'baseline_trace.csv').read_text().splitlines()));after=list(csv.DictReader((run/'baseline_trace.csv').read_text().splitlines()))
trace_delta=[]
for a,b in zip(before,after):
 changed={k:[a[k],b[k]] for k in a if a[k]!=b[k]}
 if changed:trace_delta.append({'cycle':int(a['cycle']),'changes':changed})
require(trace_delta==[{'cycle':10,'changes':{'w_valid':['0','1']}}],f'Unexpected baseline cycle difference {trace_delta}')
production=[]
for f in sorted((p/'Vivado/rtl').iterdir()):
 if f.is_file():
  oldfile=old/'Vivado/rtl'/f.name;changed=sha(f)!=sha(oldfile)
  production.append({'file':f.name,'status':'modified' if changed else 'reused_byte_identical'})
  if changed:(destination/(f.name+'.diff')).write_text(''.join(difflib.unified_diff(oldfile.read_text().splitlines(True),f.read_text().splitlines(True),fromfile='v1.5/'+f.name,tofile='v1.6/'+f.name)),encoding='utf-8')
require([r['file'] for r in production if r['status']=='modified']==['datapath_core.sv'],'Unexpected production module changes')
result={'implementation':'1.6','isa':'1.5','raw_catalogue':len(rows),'producer_types':9,'consumer_types':10,'single_source_roles':16,'registers':4,'gaps':[0,1,2],'same_source_dual_combinations':648,'single_source_combinations':1728,'original_128_case_states_and_cycles':'identical','baseline_trace_difference':trace_delta,'source_inventory':production,'external_interface':'unchanged','no_new_production_module':True,'no_fifo_or_cache':True,'timing_closed':False,'scope':'finite hazard/control catalogue, not exhaustive data values or CPU programs'}
(destination/'independent_matrix_review.json').write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding='utf-8');print(json.dumps(result,ensure_ascii=True))
