"""Exercise readiness/reset/illegal-control guards and six checker sensitivities."""
from pathlib import Path
import argparse,hashlib,json,re,shutil,sys,tempfile
E=Path(__file__).resolve().parent;P=E.parent;V=P/'Vivado';B=P/'板级'
sys.path[:0]=[str(V),str(B)]
from tool_config import add_tool_arguments,resolve_tools
from candidate_registry import apply_candidate
import negative_test_support as native
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
MUTANTS=[
  ('stale_store_data','assign dm_din = m_store_pending ? wb_data : m_store_data;','assign dm_din = m_store_data;','GUARD_STORE_VALUE'),
  ('base_stall_removed','|| (d_use_rs && d_rs == x_rd));','|| (d_use_rs && d_rs == x_rd && !d_store_data_only));','GUARD_BASE_STALL'),
  ('readiness_forced_true',"m_store_data_ready = 1'b0;","m_store_data_ready = 1'b1;",'GUARD_READY_FAIL_CLOSED'),
  ('pending_reset_removed',"m_store_pending <= 1'b0;","m_store_pending <= m_store_pending;",'GUARD_RESET_PENDING'),
  ('store_wb_dropped','w_valid_next = m_valid;','w_valid_next = m_valid && !m_mem_write;','GUARD_STORE_WB_TOKEN'),
  ('illegal_late_qualifier_removed','&& !x_reg_write && !x_mem_read','&& !x_mem_read','GUARD_ILLEGAL_LATE_ACCEPTED')]

TB=r'''`timescale 1ns/1ps
module tb_wb_guards;
  reg clk=0,rst=1;always #5 clk=~clk;
  wire[15:0]im_addr,dm_addr,dm_din;
  wire im_en,dm_en,dm_we,halted,fault;
  reg[15:0]im_dout=0,dm_dout=0;
  reg[15:0]im[0:255],dm[0:255];
  datapath_core dut(.clk(clk),.rst(rst),.im_addr(im_addr),.im_en(im_en),.im_dout(im_dout),
    .dm_addr(dm_addr),.dm_en(dm_en),.dm_we(dm_we),.dm_din(dm_din),.dm_dout(dm_dout),.halted(halted),.fault(fault));
  always @(posedge clk)begin
    if(im_en)im_dout<=im[im_addr];
    if(dm_en)begin if(dm_we)dm[dm_addr]<=dm_din;else dm_dout<=dm[dm_addr];end
  end
  integer kind,cycles,stores,stalls,passed=0,fd;
  bit injected,done,previous_store;
  task automatic edge_check;
    begin
      @(posedge clk);
      if(rst)begin
        if({im_en,dm_en,dm_we,dut.rf_we,dut.z_we,dut.cv_we}!==0)$fatal(1,"GUARD_RESET_WRITE");
      end else begin
        cycles++;
        if(dut.load_use)stalls++;
        if(kind==8 && dut.x_valid && dut.x_mem_read && dut.d_valid && dut.d_inst[15:12]==9
           && dut.load_use!==1)$fatal(1,"GUARD_BASE_STALL");
        if(previous_store && !(dut.w_valid && dut.w_store && dut.w_pc==1))$fatal(1,"GUARD_STORE_WB_TOKEN");
        previous_store=0;
        if(dm_we===1'b1)begin
          if(kind!=0 && kind!=8)$fatal(1,"GUARD_FORBIDDEN_WRITE kind=%0d",kind);
          if(dm_addr!==33 || dm_din!==(kind==8?16'd33:16'hbeef))$fatal(1,"GUARD_STORE_VALUE");
          stores++;previous_store=1;
        end
        if($isunknown({dm_en,dm_we}))$fatal(1,"GUARD_UNKNOWN_ENABLE");
      end
      #1;
      if(rst && dut.m_store_pending!==0)$fatal(1,"GUARD_RESET_PENDING");
      if(halted||fault)done=1;
    end
  endtask
  initial begin
    fd=$fopen("guards.csv","w");if(!fd)$fatal(1,"GUARD_OUTPUT");
    $fdisplay(fd,"kind,cycles,stores,stalls,injected,halted,fault,stop_reason");
    for(kind=0;kind<12;kind++)begin
      @(negedge clk);rst=1;cycles=0;stores=0;stalls=0;injected=0;done=0;previous_store=0;
      for(integer i=0;i<256;i++)begin im[i]=16'hb000;dm[i]=0;end
      im[0]=16'h8300;im[1]=(kind==8?16'h9000:16'h9301);im[2]=16'he000;im[3]=16'h9702;
      dm[32]=(kind==8?16'd33:16'hbeef);dm[33]=16'h1234;
      repeat(2)begin @(posedge clk);#1;if(dut.m_store_pending!==0)$fatal(1,"GUARD_RESET_PENDING");end
      @(negedge clk);dut.u_rf.regs[3]=32;rst=0;#1;
      while(!done && cycles<80)begin
        if(kind>=10 && !injected && dut.x_valid && dut.x_mem_write && dut.blocked_rd && !dut.blocked_rs)begin
          // Deposit an illegal control combination, then an X qualifier.
          // The next normal edge overwrites this register; no force masks the
          // fault-token transport or older load writeback we need to observe.
          if(kind==10)dut.x_reg_write=1'b1;else dut.x_reg_write=1'bx;
          injected=1;#1;
          if(dut.x_store_late!==0 || dut.x_control_illegal!==1 || dut.x_fault_event!==1)
            $fatal(1,"GUARD_ILLEGAL_LATE_ACCEPTED kind=%0d",kind);
          $display("GUARD_EX_QUAL_WITNESS kind=%0d blocked_rd=1 qualifier=%b",kind,dut.x_reg_write);
        end
        if(!injected && dut.m_valid && dut.m_store_pending)begin
          case(kind)
            1:dut.w_valid=0;
            2:dut.w_reg_write=0;
            3:dut.w_wb_sel=0;
            4:dut.w_rd=1;
            5:dut.w_fault=1;
            6:dut.w_wb_sel=1'bx;
            7:rst=1;
            9:begin dut.m_exec_value=256;dut.w_valid=0;end
            default:begin end
          endcase
          injected=1;#1;
          if(kind>=1 && kind<=6 && (dut.m_store_data_ready!==0 || dut.m_store_data_fault!==1 || {dm_en,dm_we}!==0))
            $fatal(1,"GUARD_READY_FAIL_CLOSED kind=%0d",kind);
          if(kind==9 && (dut.m_fault_event!==1 || {dm_en,dm_we}!==0))$fatal(1,"GUARD_ADDRESS_PRIORITY");
          $display("GUARD_REAL_WITNESS kind=%0d pending=%b",kind,dut.m_store_pending);
        end
        edge_check();
        if(kind==7 && rst)begin
          if(dm[33]!==16'h1234)$fatal(1,"GUARD_RESET_STORE_OCCURRED");
          @(negedge clk);im[0]=16'he000;im[1]=16'hb000;rst=0;#1;
        end else if(!done)begin @(negedge clk);#1;end
      end
      if(!done)$fatal(1,"GUARD_TIMEOUT kind=%0d",kind);
      if(kind!=8 && !injected)$fatal(1,"GUARD_WITNESS_MISSING");
      if(kind==0 || kind==8)begin
        if(!halted || fault || stores!=1 || dm[33]!==(kind==8?16'd33:16'hbeef))$fatal(1,"GUARD_NORMAL");
        if(stalls!=(kind==8?1:0))$fatal(1,"GUARD_STALL_COUNT");
      end else if(kind==7)begin
        if(!halted || fault || stores!=0 || dm[33]!==16'h1234)$fatal(1,"GUARD_RESET_RESULT");
      end else begin
        if(halted || !fault || stores!=0 || dut.stop_reason!==(kind==9?3'd4:3'd5) || dut.stop_pc!==1)
          $fatal(1,"GUARD_FAULT_RESULT kind=%0d reason=%0d",kind,dut.stop_reason);
        if(dm[33]!==16'h1234)$fatal(1,"GUARD_CORRUPT_MEMORY");
        if(kind>=10 && dut.u_rf.regs[0]!==16'hbeef)$fatal(1,"GUARD_OLDER_LOAD_LOST");
      end
      repeat(3)begin @(posedge clk);if({im_en,dm_en,dm_we,dut.rf_we,dut.z_we,dut.cv_we}!==0)$fatal(1,"GUARD_STOP_WRITE");end
      $fdisplay(fd,"%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d",kind,cycles,stores,stalls,injected,halted,fault,dut.stop_reason);
      passed++;$display("WB_GUARD_CASE_PASS kind=%0d",kind);
    end
    if(passed!=12)$fatal(1,"GUARD_COVERAGE");
    $display("WB_GUARDS_PASS cases=12 reset_pending=1 missing_producer=6 address_priority=1 ex_qualifiers=2");
    $fclose(fd);$finish;
  end
endmodule
'''

def execute(root,rtl):
    native.prepare(root,'tb_wb_guards',{'tb_wb_guards.sv':TB},rtl=rtl)
    code=native.execute(root,'guards')
    log=(root/'private.log').read_text(encoding='utf-8',errors='replace')if(root/'private.log').exists()else''
    console=(root/'guards_console.log').read_text(encoding='utf-8',errors='replace')
    if re.search(r'(?im)^ERROR:',console)or'Vivado Simulator v2025.2'not in console:raise RuntimeError('Compile/elaborate/tool-version failure, not a valid checker result')
    receipt=json.loads((root/'guards_execution.json').read_text())
    if type(receipt['exit_code']) is not int or receipt['exit_code'] not in (0,1) or receipt['error'] is not None:
        raise RuntimeError('Incomplete native lifecycle cannot count as a detected mutant')
    for name,digest in receipt['input_sha256'].items():
        if sha(root/name)!=digest:raise ValueError('Native input changed: '+name)
    return code,log

def main():
    parser=argparse.ArgumentParser(description=__doc__);add_tool_arguments(parser);a=parser.parse_args()
    tools=resolve_tools(a.vivado_bin,python=sys.executable,config=a.config);native.configure(tools['vivado_bin'])
    work=Path(tempfile.mkdtemp(prefix='wb_mem_guards_'));dest=P/'验证'/work.name
    result=dict(status='RUNNING',candidate='wb_mem',scope='Injected internal-protocol guards and checker sensitivity; not additional ISA instructions',tools=tools,mutations=[])
    try:
        shutil.copytree(V/'rtl',work/'rtl');apply_candidate(work,'wb_mem');source=work/'rtl/datapath_core.sv';original=source.read_text(encoding='utf-8')
        result['candidate_rtl_sha256']=sha(source)
        code,log=execute(work/'positive',work/'rtl')
        terminal='WB_GUARDS_PASS cases=12 reset_pending=1 missing_producer=6 address_priority=1 ex_qualifiers=2'
        if code or log.splitlines().count(terminal)!=1 or '$finish called at time'not in log or re.search(r'(?im)^Fatal:|^ERROR:',log):raise RuntimeError('Positive guard suite failed')
        result['positive']={'cases':12,'log_sha256':sha(work/'positive/private.log'),'csv_sha256':sha(work/'positive/guards.csv')}
        for name,old,new,marker in MUTANTS:
            if original.count(old)!=1:raise ValueError('Mutation seam changed: '+name)
            rtl=work/(name+'_rtl');shutil.copytree(work/'rtl',rtl);(rtl/'datapath_core.sv').write_text(original.replace(old,new),encoding='utf-8')
            print('WB_MUTATION_START '+name,flush=True);code,log=execute(work/name,rtl)
            # XSim 2025.2 may return process exit 0 even after $fatal. An
            # expected negative result therefore requires the exact fatal
            # checker marker and must NEVER contain the positive terminal.
            if not re.search(r'(?m)^Fatal:.*'+re.escape(marker),log) or terminal in log or '$finish called at time' not in log:raise RuntimeError('Mutant was not rejected by the intended checker: '+name)
            result['mutations'].append(dict(name=name,status='EXPECTED_FAILURE_DETECTED',native_exit=code,marker=marker,mutated_rtl_sha256=sha(rtl/'datapath_core.sv'),log_sha256=sha(work/name/'private.log')))
            print('WB_MUTATION_DETECTED '+name,flush=True)
        result['status']='PASS'
    except BaseException as exc:result.update(status='FAIL',error=str(exc));raise
    finally:
        result['runner_sha256']=sha(__file__)
        (work/'result.json').write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding='utf-8')
        shutil.copytree(work,dest,ignore=shutil.ignore_patterns('.Xil','xsim.dir','__pycache__'))
        print('WB_GUARDS_RECORD='+str(dest),flush=True)
if __name__=='__main__':main()
