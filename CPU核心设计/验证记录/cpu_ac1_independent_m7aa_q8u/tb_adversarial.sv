`timescale 1ns/1ps
// Expected packets are PRECOMPUTED by a Python sequential ISA interpreter.
// This TB does not execute instructions or copy the DUT's pipeline arbitration.
module tb_adversarial;
  reg clk=0,rst=1;always #5 clk=~clk;
  wire [15:0] im_addr,dm_addr,dm_din;
  wire im_en,dm_en,dm_we,halted,fault;
  reg [15:0] im_dout=0,dm_dout=0;
  datapath_core dut(.clk(clk),.rst(rst),.im_addr(im_addr),.im_en(im_en),.im_dout(im_dout),.dm_addr(dm_addr),.dm_en(dm_en),.dm_we(dm_we),.dm_din(dm_din),.dm_dout(dm_dout),.halted(halted),.fault(fault));
  reg [15:0] im[0:255],dm[0:255];
  // Independent memory implementation, one registered read, disabled hold.
  always @(posedge clk) begin
    if(im_en===1'b1) begin
      if(im_addr>255)$fatal(1,"ALT_IM_RANGE");
      im_dout<=im[im_addr];
    end
    if(dm_en===1'b1) begin
      if(dm_addr>255)$fatal(1,"ALT_DM_RANGE");
      if(dm_we===1'b1)dm[dm_addr]<=dm_din;
      else if(dm_we===1'b0)dm_dout<=dm[dm_addr];
      else $fatal(1,"ALT_DM_WRITE_UNKNOWN");
    end
  end
  `include "case_count.svh"
  integer case_id,token_count,store_count,restart_token_count,restart_store_count;
  integer expect_cycles,expect_stalls,reset_kind;
  string label,prefix,active_prefix;
  reg [2:0] initial_flags;
  reg [63:0] tokens[0:4095];
  reg [79:0] stores[0:4095];
  reg [15:0] ref_rf[0:3],ref_dm[0:255],final_rf[0:3],final_dm[0:255];
  reg [2:0] ref_flags;
  integer wb_n,store_n,cycles,stalls,redirects,epoch,total=0,reset_total=0,fd,tracefd;
  bit expected_halt_state,expected_fault_state,reset_taken,done;
  bit reset_trigger;
  bit supplement_witness;
  reg [63:0] e;
  reg [79:0] se;
  bit pending_store;
  reg [15:0] pending_pc;
  reg [15:0] pre_pc,pre_dpc,pre_xpc,pre_mpc,pre_wpc,pre_dmaddr,pre_dmdin,pre_target;
  reg [2:0] pre_mode;
  reg [3:0] pre_valid;
  reg [5:0] pre_en;
  bit pre_stall,pre_redirect;

  task automatic known_controls;
    begin
      if($isunknown({im_en,dm_en,dm_we,halted,fault,dut.rf_we,dut.z_we,dut.cv_we,
        dut.d_valid,dut.x_valid,dut.m_valid,dut.w_valid,dut.mode,dut.load_use,
        dut.qualified_redirect,dut.qualified_halt,dut.x_fault_event,dut.m_fault_event}))
        $fatal(1,"AUDIT_UNKNOWN_CONTROL case=%s epoch=%0d cycle=%0d",label,epoch,cycles);
      if(dm_we===1'b1 && dm_en!==1'b1)$fatal(1,"AUDIT_WE_WITHOUT_EN");
      if(dut.load_use===1'b1 && dut.branch_req===1'b1)$fatal(1,"AUDIT_UNREACHABLE_BRANCH_LOAD");
      if(dut.m_valid===1'b1 && dut.m_mem_read===1'b1 && dut.m_mem_write===1'b1)$fatal(1,"AUDIT_DOUBLE_DM_REQUEST");
    end
  endtask
  task automatic read_epoch(input string p,input integer n,ns,input [2:0] flags);
    begin
      active_prefix=p;token_count=n;store_count=ns;
      $readmemh({"programs/",p,"_im.mem"},im,0,255);
      $readmemh({"programs/",p,"_dm.mem"},dm,0,255);
      $readmemh({"programs/",p,"_dm.mem"},ref_dm,0,255);
      $readmemh({"programs/",p,"_rf.mem"},ref_rf,0,3);
      $readmemh({"programs/",p,"_events.mem"},tokens,0,n-1);
      if(ns>0)$readmemh({"programs/",p,"_stores.mem"},stores,0,ns-1);
      $readmemh({"programs/",p,"_final_dm.mem"},final_dm,0,255);
      $readmemh({"programs/",p,"_final_rf.mem"},final_rf,0,3);
      ref_flags=flags;
      for(integer k=0;k<4;k++)dut.u_rf.regs[k]=ref_rf[k];
      dut.u_flags.Z=flags[2];dut.u_flags.C=flags[1];dut.u_flags.V=flags[0];
      wb_n=0;store_n=0;cycles=0;stalls=0;redirects=0;pending_store=0;
      expected_halt_state=0;expected_fault_state=0;
    end
  endtask
  task automatic reset_assertions;
    begin
      known_controls();
      if({im_en,dm_en,dm_we,dut.rf_we,dut.z_we,dut.cv_we}!==0)$fatal(1,"AUDIT_RESET_WRITE_GATE");
      @(posedge clk);#1;
      if({dut.PC_fetch,dut.mode,dut.d_valid,dut.x_valid,dut.m_valid,dut.w_valid,
          halted,fault,dut.Z,dut.C,dut.V}!==0)$fatal(1,"AUDIT_RESET_STATE");
      for(integer k=0;k<4;k++)if(dut.u_rf.regs[k]!==0)$fatal(1,"AUDIT_RESET_RF");
      for(integer k=0;k<256;k++)if(dm[k]!==ref_dm[k])$fatal(1,"AUDIT_RESET_DM_PRESERVATION");
    end
  endtask
  task automatic one_edge;
    begin
      @(posedge clk);cycles++;
      known_controls();
      pre_pc=im_addr;pre_dpc=dut.d_pc;pre_xpc=dut.x_pc;pre_mpc=dut.m_pc;pre_wpc=dut.w_pc;
      pre_valid={dut.d_valid,dut.x_valid,dut.m_valid,dut.w_valid};pre_mode=dut.mode;
      pre_dmaddr=dm_addr;pre_dmdin=dm_din;pre_target=dut.branch_target;
      pre_en={im_en,dm_en,dm_we,dut.rf_we,dut.z_we,dut.cv_we};
      pre_stall=dut.load_use;pre_redirect=dut.qualified_redirect;
      if(pre_stall)stalls++;if(pre_redirect)redirects++;
      if(label=="SUPP_MOV_ALU_TO_CMP" && dut.x_valid===1'b1 && dut.x_pc===16'd2)begin
        if(dut.rd_fwd_sel!==1 || dut.rs_fwd_sel!==2 || dut.rd_fwd!==1 || dut.rs_fwd!==1)$fatal(1,"AUDIT_SUPP_CMP_FORWARD");
        supplement_witness=1;$display("AUDIT_SUPP_CMP_WITNESS newest_M_rd=1 older_W_rs=1 stalls=0");
      end
      if(label=="SUPP_G1_INTERVENING_LOAD_STALL" && dut.x_valid===1'b1 && dut.x_pc===16'd3)begin
        if(dut.rs_fwd_sel!==0 || dut.rs_fwd!==33 || dut.w_valid!==0)$fatal(1,"AUDIT_SUPP_G1_SAVED");
        supplement_witness=1;$display("AUDIT_SUPP_G1_WITNESS rs_sel=0 saved=0021 W_valid=0 middle_load_stalled=1");
      end
      if(pending_store && (dut.w_valid!==1'b1 || dut.w_store!==1'b1 || dut.w_pc!==pending_pc))
        $fatal(1,"AUDIT_STORE_TO_WB_TOKEN %s",label);
      pending_store=0;
      if(dut.w_valid===1'b1)begin
        if(wb_n>=token_count)$fatal(1,"AUDIT_EXTRA_TOKEN %s",label);
        e=tokens[wb_n];
        if(dut.w_pc!==e[15:0] || dut.w_fault!==e[46])$fatal(1,"AUDIT_ORDER_FAULT %s cycle=%0d index=%0d pc=%h expected=%h",label,cycles,wb_n,dut.w_pc,e[15:0]);
        if({dut.rf_we,dut.z_we,dut.cv_we}!=={e[41],e[42],e[43]})$fatal(1,"AUDIT_WRITE_MASK %s",label);
        if({dut.w_halt,dut.w_store}!=={e[44],e[45]})$fatal(1,"AUDIT_TOKEN_TYPE %s",label);
        if(e[41])begin
          if(dut.w_rd!==e[21:20] || dut.wb_data!==e[37:22])$fatal(1,"AUDIT_WB_VALUE %s",label);
          ref_rf[e[21:20]]=e[37:22];
        end
        if(e[42] && dut.w_cmp_z!==e[40])$fatal(1,"AUDIT_Z_VALUE %s",label);
        if(e[43] && {dut.w_c,dut.w_v}!==e[39:38])$fatal(1,"AUDIT_CV_VALUE %s",label);
        ref_flags=e[40:38];
        if(e[44])expected_halt_state=1;
        if(e[46])expected_fault_state=1;
        wb_n++;
      end
      if(dm_we===1'b1)begin
        if(store_n>=store_count)$fatal(1,"AUDIT_EXTRA_STORE %s",label);
        se=stores[store_n];
        if(dut.m_pc!==se[15:0] || dm_addr!==se[62:47] || dm_din!==se[37:22] || wb_n!=se[78:63])
          $fatal(1,"AUDIT_STORE_ORDER_DATA %s cycle=%0d pc=%h seq=%0d wb=%0d",label,cycles,dut.m_pc,se[78:63],wb_n);
        ref_dm[se[62:47]]=se[37:22];store_n++;pending_store=1;pending_pc=se[15:0];
      end
      #1;
      known_controls();
      for(integer k=0;k<4;k++)if(dut.u_rf.regs[k]!==ref_rf[k])$fatal(1,"AUDIT_RF_EDGE %s R%0d",label,k);
      for(integer k=0;k<256;k++)if(dm[k]!==ref_dm[k])$fatal(1,"AUDIT_DM_EDGE %s addr=%0d",label,k);
      if({dut.Z,dut.C,dut.V}!==ref_flags)$fatal(1,"AUDIT_FLAGS_EDGE %s",label);
      if({halted,fault}!=={expected_halt_state,expected_fault_state})$fatal(1,"AUDIT_EXACT_STOP_EDGE %s",label);
      if((halted||fault) && {dut.d_valid,dut.x_valid,dut.m_valid,dut.w_valid}!==0)$fatal(1,"AUDIT_NONEMPTY_STOP %s",label);
      $fdisplay(tracefd,"%s,%0d,%0d,%04h,%b,%04h,%04h,%04h,%04h,%b,%b,%b,%b,%04h,%04h,%04h,%0d,%b,%b,%b,%b,%b,%0d,%0d",
        label,epoch,cycles,pre_pc,pre_valid,pre_dpc,pre_xpc,pre_mpc,pre_wpc,
        pre_en[5],pre_en[4],pre_en[3],pre_stall,pre_dmaddr,pre_dmdin,pre_target,pre_mode,pre_redirect,
        pre_en[2],pre_en[1],pre_en[0],{halted,fault},wb_n,store_n);
    end
  endtask

  initial begin
    for(integer k=0;k<256;k++)begin im[k]=16'hb000;dm[k]=0;end
    fd=$fopen("independent_results.csv","w");tracefd=$fopen("independent_cycles.csv","w");
    if(!fd||!tracefd)$fatal(1,"AUDIT_OUTPUT_OPEN");
    $fdisplay(fd,"case,epoch,cycles,tokens,stores,stalls,redirects,reset_seen");
    $fdisplay(tracefd,"case,epoch,cycle,fetch_pc,DXMW_valid,d_pc,x_pc,m_pc,w_pc,im_en,dm_en,dm_we,load_use,dm_addr,dm_din,branch_target,mode,redirect,rf_we,z_we,cv_we,stop,wb_count,store_count");
    for(case_id=0;case_id<CASES;case_id++)begin
      `include "case_config.svh"
      epoch=0;reset_taken=0;done=0;supplement_witness=0;
      @(negedge clk);rst=1;repeat(2)@(posedge clk);#1;
      @(negedge clk);read_epoch(prefix,token_count,store_count,initial_flags);rst=0;
      while(!done && cycles<1500)begin
        // Conditions are sampled halfway through the stable cycle, before the
        // next active edge. Every requested reset must have a real witness.
        #1;reset_trigger=0;
        if(reset_kind>0 && !reset_taken)case(reset_kind)
          1:reset_trigger=(dut.load_use===1'b1);
          2:reset_trigger=(dut.qualified_redirect===1'b1);
          3:reset_trigger=(dut.mode===3'd1);
          4:reset_trigger=(dm_we===1'b1);
          5:reset_trigger=(store_n==1);
          6:reset_trigger=(dut.w_valid===1'b1 && dut.w_halt===1'b1);
          7:reset_trigger=(dut.mode===3'd2);
          8:reset_trigger=(dut.w_valid===1'b1 && dut.w_fault===1'b1);
          9:reset_trigger=(halted===1'b1);
          10:reset_trigger=(fault===1'b1);
          default:$fatal(1,"AUDIT_BAD_RESET_KIND");
        endcase
        if(reset_trigger)begin
          $display("AUDIT_RESET_WITNESS %s kind=%0d cycle=%0d mode=%0d stores=%0d stall=%b redirect=%b",label,reset_kind,cycles+1,dut.mode,store_n,dut.load_use,dut.qualified_redirect);
          $fdisplay(fd,"%s,%0d,%0d,%0d,%0d,%0d,%0d,1",label,epoch,cycles,wb_n,store_n,stalls,redirects);
          rst=1;#1;reset_assertions();
          reset_taken=1;reset_total++;epoch=1;
          // Check prescribed retained memory before starting the new epoch.
          $readmemh({"programs/",prefix,"_restart_dm.mem"},final_dm,0,255);
          for(integer k=0;k<256;k++)if(dm[k]!==final_dm[k])$fatal(1,"AUDIT_RESET_EXPECTED_PREFIX_MEMORY %s",label);
          @(negedge clk);read_epoch({prefix,"_restart"},restart_token_count,restart_store_count,0);rst=0;
        end else begin
          one_edge();
          if(halted||fault)begin
            if(reset_kind==0 || reset_taken)done=1;
          end
          if(!done)@(negedge clk);
        end
      end
      if(!done)$fatal(1,"AUDIT_TIMEOUT %s",label);
      if(reset_kind>0 && !reset_taken)$fatal(1,"AUDIT_MISSING_RESET_WITNESS %s",label);
      if((label=="SUPP_MOV_ALU_TO_CMP"||label=="SUPP_G1_INTERVENING_LOAD_STALL")&&!supplement_witness)$fatal(1,"AUDIT_SUPP_WITNESS_MISSING");
      if(wb_n!=token_count||store_n!=store_count)$fatal(1,"AUDIT_MISSING_EVENTS %s",label);
      if(reset_kind==0 && expect_cycles>=0 && cycles!=expect_cycles)$fatal(1,"AUDIT_CYCLES %s got=%0d expected=%0d",label,cycles,expect_cycles);
      if(reset_kind==0 && expect_stalls>=0 && stalls!=expect_stalls)$fatal(1,"AUDIT_STALLS %s got=%0d expected=%0d",label,stalls,expect_stalls);
      for(integer k=0;k<4;k++)if(dut.u_rf.regs[k]!==final_rf[k])$fatal(1,"AUDIT_FINAL_RF %s",label);
      for(integer k=0;k<256;k++)if(dm[k]!==final_dm[k])$fatal(1,"AUDIT_FINAL_DM %s",label);
      $fdisplay(fd,"%s,%0d,%0d,%0d,%0d,%0d,%0d,%0d",label,epoch,cycles,wb_n,store_n,stalls,redirects,reset_taken);
      repeat(3)begin
        @(posedge clk);known_controls();
        if({im_en,dm_en,dm_we,dut.rf_we,dut.z_we,dut.cv_we}!==0)$fatal(1,"AUDIT_STOP_SIDE_EFFECT %s",label);
        #1;if({halted,fault}!=={expected_halt_state,expected_fault_state})$fatal(1,"AUDIT_STOP_HOLD %s",label);
      end
      total++;$display("ADVERSARIAL_CASE_PASS %s cycles=%0d tokens=%0d stores=%0d stalls=%0d redirects=%0d reset=%0d",label,cycles,wb_n,store_n,stalls,redirects,reset_taken);
    end
    if(total!=CASES||reset_total!=10)$fatal(1,"AUDIT_CASE_COVERAGE");
    $display("ADVERSARIAL_PASS cases=%0d reset_witnesses=%0d failures=0 oracle=external_python memory=independent_sync",total,reset_total);
    $fclose(fd);$fclose(tracefd);$finish;
  end
endmodule
