"""Sequentially consume the four remaining prebuilt AC1 images. No build/Flash/UART."""
from pathlib import Path
from datetime import datetime,timezone
import hashlib,json,os,re,subprocess,sys
A=Path(__file__).resolve().parent;P=A.parents[1]
sys.path.insert(0,str(P/'Vivado'));sys.path.insert(0,str(P/'板级'))
from tool_config import resolve_tools
from verify_board_results import verify_attempt
from probe_codec import decode
def read(p):return json.loads(Path(p).read_text(encoding='utf-8-sig'))
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def require(value,message):
 if not value:raise ValueError(message)
def save(r):(A/'result.json').write_text(json.dumps(r,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
def verify_case(program,record,row):
 root=P/record;r=read(root/'result.json');impl=P/row['attempt_relative'];d=read(impl/'result.json');expected=d['selected_result']
 require(r['status']=='FUNCTIONAL_BOARD_PASS'and r['board_validated']is True and r['native_exit']==0,'Board lifecycle failed: '+program)
 require(r['target']=='localhost:3121/xilinx_tcf/Xilinx/1234-tulA'and r['physical_board_confirmation']=='EES-331','Target binding differs')
 require(r['source_receipt_sha256']==sha(impl/'result.json')==row['receipt_sha256'],'Implementation source receipt changed')
 for name,digest in r['input_sha256'].items():require(sha(root/name)==digest,'Capture input changed: '+name)
 require(sha(root/'program.bit')==row['implementation']['bitstream_sha256'],'Programmed image differs')
 log=(root/'hardware.log').read_text(encoding='utf-8')
 require(log.splitlines().count('HARDWARE_CAPTURE_COMPLETE attempt='+root.name)==1 and not re.search(r'(?im)^WARNING:|^CRITICAL WARNING:|^ERROR:|^HARDWARE_SESSION_FAILED=',log),'Capture log incomplete/unreviewed')
 raw=[decode(*line.split('\t')[1:])for line in(root/'snapshots.tsv').read_text().splitlines()]
 require(raw==r['snapshots']and len(raw)==2,'Two raw snapshots differ from receipt')
 for c in raw:
  require(c['build_id']==row['implementation']['build_id'],'Build identity differs')
  for key in ['rf','flags','stop_pc','cycles','completed','stalls','redirects','stores']:require(c[key]==expected[key],'Architecture/counter mismatch: '+program+'/'+key)
  for key,value in {'core_reset':0,'stop_valid':1,'stop_pc_valid':1,'halted':1,'fault':0,'stop_reason':1,'last_completed_valid':1,'last_completed_pc':expected['stop_pc'],'reserved':0}.items():require(c[key]==value,'Stop/metadata mismatch: '+key)
  require(c['last_store_valid']==int(expected['stores']>0),'Store-valid mismatch')
  if expected['stores']:
   packet=int((impl/'programs/selected_stores.mem').read_text().splitlines()[-1],16)
   require(c['last_store_addr']==((packet>>47)&0xffff)and c['last_store_data']==((packet>>22)&0xffff),'Last store mismatch')
 require({k:v for k,v in raw[0].items()if k!='heartbeat'}=={k:v for k,v in raw[1].items()if k!='heartbeat'},'Stopped state/counters are not stable')
 return dict(program=program,record=record,receipt_sha256=sha(root/'result.json'),hardware_log_sha256=sha(root/'hardware.log'),raw_snapshots_sha256=sha(root/'snapshots.tsv'),actual=raw[-1])
def main():
 r=read(A/'result.json');require(r['status']=='CPU_BOARD_MATRIX_RUNNING','Preserve an existing completed/failed matrix')
 baseline=read(P/'实验/性能基线.json');matrix=P/baseline['matrix_relative'];require(sha(matrix)==baseline['matrix_sha256'],'Pinned baseline matrix changed')
 rows={x['program']:x for x in read(matrix)['rows']};tools=resolve_tools(python=sys.executable);v=Path(tools['vivado_bin']).parent
 env={k.upper():value for k,value in os.environ.items()};env['PATH']=';'.join(str(v/part)for part in ['lib/win64.o','bin','bin/unwrapped/win64.o'])+';'+env.get('PATH','')
 r['verified_programs']=[]
 try:
  for program in ['all_ops','baseline','loop','memory_copy','copy_checksum']:
   if program not in r['program_records']:
    impl=P/rows[program]['attempt_relative'];verify_attempt(impl)
    args=[sys.executable,'-B','-X','utf8',str(P/'板级/run_hardware.py'),'--implementation',str(impl),'--target',r['target'],'--confirmed-board','EES-331','--program-device','--run-program']
    print('START_PROGRAM='+program,flush=True)
    done=subprocess.run(args,cwd=P,env=env,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,encoding='utf-8',errors='replace')
    (A/(program+'.entry.log')).write_text(done.stdout,encoding='utf-8')
    found=re.findall(r'^HARDWARE_RECORD=(.+)$',done.stdout,re.M)
    if found:r['program_records'][program]=Path(found[-1].strip()).relative_to(P).as_posix();save(r)
    require(done.returncode==0 and len(found)==1,'Hardware entry failed: '+program+'; see entry log')
   row=verify_case(program,r['program_records'][program],rows[program]);r['verified_programs'].append(row);save(r)
   print('PROGRAM_PASS='+program+' cycles='+str(row['actual']['cycles']),flush=True)
  r['status']='FIVE_PROGRAMS_BOARD_PASS_BUTTON_PENDING';r['five_programs_verified_at_utc']=datetime.now(timezone.utc).isoformat();save(r)
 except BaseException as e:r.update(status='FAIL',error=str(e));save(r);raise
 print('FIVE_PROGRAMS_BOARD_PASS',flush=True)
if __name__=='__main__':main()
