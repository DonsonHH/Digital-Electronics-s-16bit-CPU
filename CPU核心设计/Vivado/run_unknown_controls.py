from negative_test_support import ROOT,prepare,execute,sha
import json,re,sys,tempfile,shutil
base=ROOT;out=__import__('pathlib').Path(tempfile.mkdtemp(prefix='cpu_v16_unknowns_'))
variants=[('stopped_dm_we_x','tb_datapath',None),('stopped_dm_we_x_stress','tb_stress',None),
 ('stopped_dm_we_x_audit','tb_audit3',None),('stopped_dm_we_x_uniform','tb_uniform_smoke',None),
 ('stopped_im_en_z','tb_datapath',('halt','dut.im_en',"1'bz")),
 ('stopped_rf_we_x','tb_datapath',('halt','dut.core.rf_we',"1'bx")),
 ('stopped_valid_z','tb_datapath',('halt','dut.core.d_valid',"1'bz")),
 ('running_stall_x','tb_datapath',('run','dut.core.load_use',"1'bx")),
 ('running_redirect_z','tb_datapath',('run','dut.core.qualified_redirect',"1'bz")),
 ('reset_dm_en_z','tb_datapath',('reset','dut.dm_en',"1'bz"))]
results=[]
for label,top,force in variants:
 p=prepare(out/label,top,{})
 if force is None:
  target=p/'rtl'/'datapath_core.sv';s=target.read_text(encoding='utf-8');old='assign dm_we = mem_ok && m_mem_write;'
  if s.count(old)!=1:raise RuntimeError('Original M1 mutation seam missing')
  target.write_text(s.replace(old,"assign dm_we = mode_active ? (mem_ok && m_mem_write) : 1'bx;"),encoding='utf-8')
 else:
  phase,signal,value=force;target=p/'tb'/(top+'.sv');s=target.read_text(encoding='utf-8')
  wait={'halt':"wait(halted===1'b1);",'run':"wait(rst===1'b0);",'reset':"wait(rst===1'b1);"}[phase]
  injection=f' initial begin {wait} @(negedge clk);#0.2;force {signal}={value};end\n'
  target.write_text(s.replace('endmodule',injection+'endmodule'),encoding='utf-8')
 rc=execute(p);log=(p/'private.log').read_text(encoding='utf-8',errors='replace');fatal=re.search(r'^Fatal: (.+)$',log,re.M)
 if not fatal or not re.match(r'^CONTROL_(XZ|DISABLED_NOT_ZERO)',fatal[1]):raise RuntimeError('Unknown state was not precisely rejected: '+label+' '+(fatal[1] if fatal else 'no runtime Fatal'))
 results.append(dict(case=label,top=top,expected_runtime_failure=True,fatal=fatal[1],native_exit=rc,target=str(target),target_sha256=sha(target),log_sha256=sha(p/'private.log')))
 print('UNKNOWN_INJECTION_REJECTED '+label,flush=True)
# Non-consumed data in empty X/M slots must remain legal.
p=prepare(out/'inactive_payload_allowed','tb_datapath',{})
target=p/'tb'/'tb_datapath.sv';s=target.read_text(encoding='utf-8')
inject=''' initial begin
 wait(rst===1'b0);#0.2;
 if(dut.core.x_valid!==0||dut.core.m_valid!==0)$fatal(1,"PAYLOAD_FIXTURE_NOT_EMPTY");
 force dut.core.x_rd_value=16'hxxxx;force dut.core.x_rs_value=16'hzzzz;
 force dut.core.m_exec_value=16'hzzzz;#2;
 release dut.core.x_rd_value;release dut.core.x_rs_value;release dut.core.m_exec_value;
 $display("INACTIVE_PAYLOAD_ALLOWED");
 end
'''
target.write_text(s.replace('endmodule',inject+'endmodule'),encoding='utf-8')
rc=execute(p);log=(p/'private.log').read_text(encoding='utf-8',errors='replace')
if rc or 'Fatal:' in log or 'INACTIVE_PAYLOAD_ALLOWED' not in log or 'DATAPATH_PASS cases=128' not in log:raise RuntimeError('Invalid unused payload was incorrectly rejected')
results.append(dict(case='inactive_payload_allowed',normal_pass=True,log_sha256=sha(p/'private.log')))
(out/'m1_results.json').write_text(json.dumps(dict(status='PASS',verification_revision='1.6-vtools-r1',negative_variants=10,unused_payload_positive=True,hardware_fault_tolerance_claim=False,results=results),ensure_ascii=False,indent=2),encoding='utf-8')
print('M1_ACCEPTANCE_PASS negative=10 unused_payload_positive=1')

archive=ROOT.parent/'审查'/'验证工具_r1'/'负向'/out.name
archive.parent.mkdir(parents=True,exist_ok=True)
shutil.copytree(out,archive,ignore=shutil.ignore_patterns('xsim.dir','.Xil','__pycache__'))
print('UNKNOWN_CONTROLS_ARCHIVE='+str(archive))
