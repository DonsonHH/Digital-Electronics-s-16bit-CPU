"""Independently parse routed timing/resources, IO, DRC, debug and bitstream evidence."""
from pathlib import Path
import argparse,hashlib,json,re

def require(condition,detail):
 if not condition:raise ValueError(detail)
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def parse_timing(text):
 require('Design State : Routed' in text,'Timing report is not routed')
 require('Device       : 7z020-clg484' in text and 'Speed File   : -1 ' in text,'Wrong timing device/speed')
 row=re.search(r'WNS\(ns\)[^\n]*\n[^\n]*\n([^\n]+)',text)
 require(row is not None,'Full setup/hold/pulse summary missing')
 v=row[1].split();require(len(v)==12,'Unexpected timing summary columns')
 r=dict(zip(['wns_ns','tns_ns','setup_failed','setup_endpoints','whs_ns','ths_ns','hold_failed','hold_endpoints','wpws_ns','tpws_ns','pulse_failed','pulse_endpoints'],map(float,v)))
 require(all(r[n]>=0 for n in ['wns_ns','whs_ns','wpws_ns']),'Negative setup/hold/pulse slack')
 require(all(r[n]==0 for n in ['tns_ns','ths_ns','tpws_ns','setup_failed','hold_failed','pulse_failed']),'Failing setup/hold/pulse endpoints')
 require(re.search(r'^board_clk\s+\{0\.000\s+5\.000\}\s+10\.000',text,re.M),'Missing100MHz board clock')
 return r

def analyze_reports(run,build_id):
 run=Path(run);reports=run/'reports';output=run/'output'
 timing=parse_timing((reports/'timing.rpt').read_text())
 checks=(reports/'check_timing.rpt').read_text()
 counts={n:int(v) for n,v in re.findall(r'^\d+\. checking (\w+) \((\d+)\)',checks,re.M)}
 for n in ['no_clock','constant_clock','unconstrained_internal_endpoints','multiple_clock','generated_clocks','loops','partial_input_delay','partial_output_delay','latch_loops']:
  require(n in counts and counts[n]==0,'Uncovered internal timing category: '+n)
 require(counts.get('no_input_delay',99)<=1 and counts.get('no_output_delay',99)<=8,'Unexpected untimed IO')
 require('There are 0 input ports with no input delay specified.' in checks,'Unexcepted input delay missing')
 require('There are 0 ports with no output delay specified.' in checks,'Unexcepted output delay missing')
 io=(reports/'io.rpt').read_text()
 for name,pin in [('clk100','M19'),('reset_btn_n','L18')]+[(f'led[{i}]',p) for i,p in enumerate(['V4','U6','U5','V7','W7','W6','W5','U7'])]:
  rows=[line for line in io.splitlines() if re.search(r'\|\s*'+re.escape(name)+r'\s*\|',line)]
  require(len(rows)==1 and re.search(r'\b'+pin+r'\b',rows[0]) and 'LVCMOS33' in rows[0],'IO binding differs: '+name)
 util=(reports/'utilization.rpt').read_text()
 require('Design State : Routed' in util,'Resource report not routed')
 row=next((line for line in util.splitlines() if re.match(r'^\| ees331_top\s+\|',line)),None)
 require(row is not None,'Top resource row missing')
 fields=[x.strip() for x in row.split('|')][1:-1];require(fields[1]=='(top)','Unexpected top utilization')
 nums=list(map(int,fields[2:]));require(len(nums)==8,'Resource column layout differs')
 resources=dict(zip(['lut_total','lut_logic','lutram','srl','ff','bram36','bram18','dsp'],nums))
 require(resources['bram18']+resources['bram36']>=2,'IM/DM block memories missing')
 drc=(reports/'drc.rpt').read_text();require('Design State : Fully Routed' in drc,'DRC is not fully routed')
 violations=re.findall(r'^\|\s*([A-Z][A-Z0-9]+-\d+)\s*\|\s*(\w+)\s*\|[^\n]+\|\s*(\d+)\s*\|',drc,re.M)
 require(all(severity=='Warning' for _,severity,_ in violations),'Error/critical DRC violation')
 allowed={'PDCN-1569','RTSTAT-10','ZPS7-1'}
 require({code for code,_,_ in violations}<=allowed,'Unreviewed DRC warning')
 found=re.search(r'Checks found:\s*(\d+)',drc)
 require(found is not None and sum(int(n) for _,_,n in violations)==int(found[1]),'DRC summary incomplete')
 for chunk in re.findall(r'(?ms)^PDCN-1569#\d+ Warning\n(.*?)(?=^[A-Z][A-Z0-9]+-\d+#|\Z)',drc):
  require('of cell dbg_hub/' in chunk,'LUT warning outside vendor debug hub')
 require('REQP-1840' not in drc,'Asynchronous control of memory requires correction')
 ltx=json.loads((output/'debug.ltx').read_text());cores=[c for d in ltx['ltx_root']['ltx_data'] for c in d['debug_cores']]
 vio=[c for c in cores if c['type']=='VIO_V2'];require(len(vio)==1,'Expected one VIO')
 ports={p['name']:(p['direction'],abs(p['leftIndex']-p['rightIndex'])+1) for p in vio[0]['pins']}
 require(ports=={'probe_in0':('IN',256),'probe_in1':('IN',160),'probe_out0':('OUT',1)},'VIO interface differs')
 hubs=[c for c in cores if c['type']=='XSDB_V3'];require(len(hubs)==1 and hubs[0]['clk_input_freq_hz']=='100000000','Debug hub clock differs')
 bit=output/'ees331.bit';require(bit.stat().st_size>100000 and b'7z020clg484' in bit.read_bytes()[:2048],'Bitstream missing or wrong package')
 require((output/'routed.dcp').stat().st_size>100000,'Routed checkpoint missing')
 synth=(run/'project/ees331.runs/synth_1/runme.log').read_text(encoding='utf-8',errors='replace')
 ids=re.findall(r"Parameter BUILD_ID bound to: 64'b([01]+)",synth)
 require(len(ids)==2 and all(int(v,2)==int(build_id,16) for v in ids),'Executed generic build identity missing/different')
 require(not re.search(r'(?m)^CRITICAL WARNING:|^ERROR:',synth),'Synthesis error/critical warning')
 native=json.loads((reports/'implementation.json').read_text())
 resources['carry4']=native['carry4']
 return {'scope':'routed implementation, physical EES-331 unverified','part':'xc7z020clg484-1','period_ns':10,'timing':timing,'resources':resources,
  'drc_warnings':{code:int(count) for code,_,count in violations},'warning_disposition':{'PDCN-1569':'Vendor debug-hub unused LUT input terms; no CPU cell affected','RTSTAT-10':'Unused nets with no routable loads in generated debug hub','ZPS7-1':'PL/JTAG-only design; PS clock/DDR/MIO unused, boot/configuration remains a physical-board check'},
  'untimed_external_IO':'Only button to first synchronizer D and LEDs without a synchronous receiver; no core data-path timing exception',
  'build_id':build_id,'bitstream_sha256':sha(bit),'ltx_sha256':sha(output/'debug.ltx'),'placed_and_routed':True,'board_validated':False}

def verify_attempt(run):
 run=Path(run);receipt=json.loads((run/'result.json').read_text())
 require(receipt['status']=='PASS','Attempt did not finish successfully')
 labels=['compile','elaborate','simulate'] if receipt['mode']=='all' else []
 if (run/'tb/tb_selected_program.sv').exists():
  require(receipt.get('verification_revision')=='board_selected_v2','Selected program verification revision missing')
  if receipt['mode']=='all':labels+=['elaborate_selected','simulate_selected']
 labels+=['implement']
 require([s['label'] for s in receipt['steps']]==labels,'Native step sequence missing')
 for step in receipt['steps']:
  require(step['exit']==0 and sha(run/(step['label']+'.console.log'))==step['console_sha256'],'Native step changed/failed')
  require(sha(run/(step['label']+'.cmd'))==step['command_sha256'],'Native command changed')
 expected={p.relative_to(run).as_posix() for group in ['rtl','tb','programs','constraints'] for p in (run/group).rglob('*') if p.is_file()}
 expected.update(['build_board.tcl','probe_hardware.tcl','run_board.py','desktop_launch.py'])
 if (run/'verify_board_results.py').exists():expected.add('verify_board_results.py')
 require(set(receipt['input_sha256'])==expected,'Executed input inventory missing/different')
 expected_out={p.relative_to(run).as_posix() for group in ['reports','output'] for p in (run/group).rglob('*') if p.is_file()}
 require(set(receipt['output_sha256'])==expected_out,'Output inventory missing/different')
 for name,digest in receipt['input_sha256'].items():require(sha(run/name)==digest,'Executed input changed: '+name)
 for name,digest in receipt['output_sha256'].items():require(sha(run/name)==digest,'Output changed: '+name)
 log=(run/'implementation.log').read_text(encoding='utf-8',errors='replace')
 require(log.splitlines().count('BOARD_IMPLEMENTATION_COMPLETE attempt='+receipt['attempt']+' build_id='+receipt['build_id']+' scope=routed_design_not_physical_validation')==1,'Fresh implementation terminal missing')
 return analyze_reports(run,receipt['build_id'])

if __name__=='__main__':
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('--run',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
 require(not a.output.exists(),'Review output must be a new file');r=verify_attempt(a.run);r.update(new_native_execution=False,result_kind='independent_post_route_revalidation')
 a.output.write_text(json.dumps(r,ensure_ascii=False,indent=2),encoding='utf-8');print('BOARD_REPORT_REVIEW_PASS '+str(a.output))
