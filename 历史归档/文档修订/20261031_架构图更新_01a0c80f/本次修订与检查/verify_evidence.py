from pathlib import Path
import ast,csv,hashlib,json,re
WORK=Path(__file__).parent
ROOT=Path(r'D:\OneDrive - University of Glasgow\同步文件夹\大三上\Courses\数电')
CORE=ROOT/'CPU核心设计';PRE5=ROOT/'Pre5_控制单元设计'/'Vivado'
def read(p):return json.loads(p.read_text(encoding='utf-8-sig'))
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def require(ok,why):
 if not ok:raise AssertionError(why)
def csvrows(p):
 with p.open(encoding='utf-8-sig',newline='') as f:return list(csv.DictReader(f))

# Extract only the pure VCD reader. Never import/execute the source extractor's
# top-level code, which intentionally writes the original teaching artifacts.
tree=ast.parse((PRE5/'extract_control_evidence.py').read_text(encoding='utf-8'))
pure=[]
for node in tree.body:
 if isinstance(node,ast.FunctionDef) and node.name=='clocks':pure.append(node)
 if isinstance(node,ast.Assign) and any(isinstance(t,ast.Name) and t.id in ['WANTED','HEX_WORDS'] for t in node.targets):pure.append(node)
scope={'re':re,'require':require};exec(compile(ast.Module(body=pure,type_ignores=[]),'pure_vcd_reader','exec'),scope)
receipt=read(PRE5/'验证结果.json');run=PRE5/receipt['archived_run_relative']
for name,digest in receipt['rtl_sha256'].items():
 require(sha(CORE/'Vivado'/'rtl'/name)==sha(PRE5/'rtl'/name)==digest,'Current RTL differs from trace source '+name)
for name,digest in receipt['evidence_sha256'].items():require(sha(run/name)==digest,'Raw evidence hash '+name)
raw={n:scope['clocks'](run/n) for n in ['datapath.vcd','interlock.vcd']}
traces={}
for p in sorted((PRE5/'control_traces').glob('*.json')):
 d=read(p);n=d['source_vcd'];require(sha(run/n)==d['source_vcd_sha256'],'VCD binding '+p.name)
 expected=[e for e in raw[n] if e['time_ps']>=d['case_start_ps']][:int(d['receipt']['cycles'])]
 require(d['edges']==[dict(cycle=i+1,**e) for i,e in enumerate(expected)],'VCD-to-JSON '+p.name)
 rows=csvrows(p.with_suffix('.csv'));require(len(rows)==len(expected),'CSV row count')
 for r,e in zip(rows,d['edges']):
  for key,val in r.items():
   if key in ['cycle','time_ps']:want=e[key]
   else:
    phase,sig=key.split('_',1);want=e[phase][sig]
   got=None if val=='unknown' else int(val,16 if key.split('_',1)[-1] in scope['HEX_WORDS'] else 10)
   require(got==want,'CSV sample differs '+p.name+' '+key)
 traces[d['case']]={e['cycle']:e for e in d['edges']}
def pre(case,c):return traces[case][c]['pre']
def post(case,c):return traces[case][c]['post']
checks=[]
def check(label,ok):require(ok,label);checks.append(label)
t='TRACE_LOAD_STR'
check('LDR->STR: C3 front holds and X bubble',pre(t,3)['load_use']==1 and pre(t,3)['im_en']==0 and post(t,3)['x_valid']==0)
check('LDR->STR: C5 W forwarding, C6 one MEM write',pre(t,5)['rd_fwd_sel']==2 and pre(t,6)['dm_we']==1 and pre(t,6)['dm_din']==7 and sum(e['pre']['dm_we'] for e in traces[t].values())==1)
check('STR C7 valid WB no write',pre(t,7)['w_valid']==1 and pre(t,7)['w_store']==1 and pre(t,7)['rf_we']==pre(t,7)['z_we']==pre(t,7)['cv_we']==0)
check('CMP->JZ C7 M candidate/redirect kills young only',pre(t,7)['z_fwd_sel']==1 and pre(t,7)['qualified_redirect']==1 and post(t,7)['x_valid']==post(t,7)['d_valid']==0 and post(t,7)['m_valid']==1)
check('HALT C12 WB token + empty-next',pre(t,12)['w_halt']==1 and pre(t,12)['drain_done']==1 and post(t,12)['mode']==3)
check('T07 accepts HALT C4, old load writes C5, stops C6',pre('T07',4)['qualified_halt']==1 and pre('T07',5)['rf_we']==1 and pre('T07',5)['wb_data']==0x1234 and post('T07',6)['mode']==3)
check('T16 older MEM fault cancels HALT and blocks DM C4',pre('T16',4)['m_fault_event']==1 and pre('T16',4)['qualified_halt']==pre('T16',4)['dm_en']==pre('T16',4)['dm_we']==0 and post('T16',4)['mode']==2 and post('T16',4)['m_valid']==0 and post('T16',5)['mode']==4)
check('T05 older WB may complete alongside MEM fault',any(e['pre']['m_fault_event'] and e['pre']['rf_we'] for e in traces['T05'].values()))
check('T02 C5 JZ uses latest M zero, not older W CMP',pre('T02',5)['x_pc']==2 and pre('T02',5)['z_fwd_sel']==1 and pre('T02',5)['z_effective']==0 and pre('T02',5)['w_z_write']==1 and pre('T02',5)['qualified_redirect']==0)
check('T02 C6 W candidate zero overrides saved Z one',pre('T02',6)['z_fwd_sel']==2 and pre('T02',6)['z_effective']==0 and pre('T02',6)['Z']==1)
log=(run/'datapath.log').read_text(encoding='utf-8',errors='replace')
modes={int(x) for x in re.findall(r'^RESET_PASS .* old_mode=(\d+)',log,re.M)}
check('Reset witnesses from all five modes',modes==set(range(5)) and len(re.findall(r'^RESET_PASS ',log,re.M))==16)

ir=PRE5/'验证记录'/'cpu_ac1_independent_glok75my';ind=read(ir/'independent_result.json')
for name,digest in ind['input_sha256'].items():require(sha(ir/name)==digest,'Independent input hash '+name)
require(sha(ir/'private.log')==ind['log_sha256'],'Independent log binding')
cases=read(ir/'cases.json');results=csvrows(ir/'independent_results.csv');cycles=csvrows(ir/'independent_cycles.csv')
check('Independent 48 cases / 58 result rows / 952 cycle rows',len(cases)==48 and len(results)==58 and len(cycles)==952)
for label in ['DOC_ADD_ADD','LEGAL_STR_BEFORE_HALT']:
 case=next(c for c in cases if c['label']==label);cs=[r for r in cycles if r['case']==label and r['epoch']=='0'];rs=next(r for r in results if r['case']==label and r['epoch']=='0')
 if label=='DOC_ADD_ADD':
  check(label+' M forwarding schedule requires no stall',int(rs['stalls'])==0 and int(rs['redirects'])==0 and len(cs)==int(rs['cycles']))
 else:check(label+' exactly one old store, normal halt',int(rs['stores'])==1 and sum(int(r['dm_we']) for r in cs)==1 and rs['reset_seen']=='0')

out={'date':'2026-10-31','status':'HISTORICAL_TRACE_RECHECK_PASS','new_xsim_execution':False,'new_synthesis':False,'RTL_changed':False,'raw_vcd_edges':{n:len(v) for n,v in raw.items()},'trace_cases_checked':len(traces),'trace_JSON_and_CSV_match_original_VCD':True,'checks':checks,'run':str(run),'independent_run':str(ir)}
(WORK/'evidence_review.json').write_text(json.dumps(out,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps(out,ensure_ascii=False,indent=2))
