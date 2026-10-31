`timescale 1ns/1ps
// Third independent audit: handwritten expected events, no DUT/reference ISA
// decoder used for the oracle. All RF, flags and DM checked after each edge.
module tb_audit3;
  reg clk=0,rst=1;always #5 clk=~clk;
  wire halted,fault;pre4_system dut(clk,rst,halted,fault);
  reg [15:0] fixture[0:3],rf[0:3],memory[0:255];
  reg z,c,v;
  integer ep[0:31],ed[0:31],ea[0:31];
  reg [15:0] data[0:31];
  reg store[0:31],rw[0:31],zw[0:31],cvw[0:31],h[0:31],load_select[0:31];
  reg ez[0:31],ec[0:31],ev[0:31];
  integer n,seen,cycles,stalls,total=0,restarts=0,kind;
  integer fault_pc;
  bit expected_fault,pre_halt,pre_fault,witness;
  string label;
  task automatic fresh(input string s);
    begin
      label=s;@(negedge clk);rst=1;repeat(2)@(posedge clk);#1;
      for(integer k=0;k<4;k++)fixture[k]=0;
      for(integer k=0;k<256;k++)begin dut.im.mem[k]=16'hb000;memory[k]=0;end
      z=0;c=0;v=0;n=0;expected_fault=0;fault_pc=0;witness=0;
    end
  endtask
  task automatic wb(input integer pc,d,input [15:0] value,
    input bit r,zmask,zval,cvmask,cval,vval,stop,lselect);
    begin
      ep[n]=pc;ed[n]=d;data[n]=value;ea[n]=0;store[n]=0;
      rw[n]=r;zw[n]=zmask;ez[n]=zval;cvw[n]=cvmask;ec[n]=cval;ev[n]=vval;
      h[n]=stop;load_select[n]=lselect;n++;
    end
  endtask
  task automatic st(input integer pc,address,input [15:0] value);
    begin ep[n]=pc;ea[n]=address;data[n]=value;store[n]=1;n++;end
  endtask
  task automatic halt_event(input integer pc);
    wb(pc,0,0,0,0,0,0,0,0,1,0);
  endtask
  task automatic run_case(input integer expect_cycles,expect_stalls);
    begin
      @(negedge clk);
      for(integer k=0;k<4;k++)begin rf[k]=fixture[k];dut.core.u_rf.regs[k]=fixture[k];end
      for(integer k=0;k<256;k++)dut.dm.mem[k]=memory[k];
      dut.core.u_flags.Z=z;dut.core.u_flags.C=c;dut.core.u_flags.V=v;
      cycles=0;seen=0;stalls=0;rst=0;
      while(!halted&&!fault&&cycles<64)begin
        @(posedge clk);cycles++;pre_halt=0;pre_fault=0;
        if(dut.core.w_valid)begin
          if(dut.core.w_fault)begin
            if(!expected_fault||seen!=n||dut.core.w_pc!==16'(fault_pc)||
               {dut.core.rf_we,dut.core.z_we,dut.core.cv_we}!==0)$fatal(1,"AUDIT3 fault PC/age/mask %s",label);
            pre_fault=1;
          end else if(dut.core.w_store)begin
            if(dut.core.rf_we||dut.core.z_we||dut.core.cv_we||dut.core.w_halt)$fatal(1,"AUDIT3 store WB side effect");
          end else begin
            if(seen>=n||store[seen]||dut.core.w_pc!==16'(ep[seen]))$fatal(1,"AUDIT3 WB age %s",label);
            if({dut.core.rf_we,dut.core.z_we,dut.core.cv_we,dut.core.w_halt,dut.core.w_wb_sel}!==
              {rw[seen],zw[seen],cvw[seen],h[seen],load_select[seen]})$fatal(1,"AUDIT3 WB intent %s",label);
            if(rw[seen])begin
              if(dut.core.w_rd!==2'(ed[seen])||dut.core.wb_data!==data[seen])$fatal(1,"AUDIT3 WB value %s pc=%0d",label,ep[seen]);
              rf[ed[seen]]=data[seen];
            end
            if(zw[seen])z=ez[seen];
            if(cvw[seen])begin c=ec[seen];v=ev[seen];end
            pre_halt=h[seen];seen++;
          end
        end
        if(dut.dm_we)begin
          if(seen>=n||!store[seen]||dut.core.m_pc!==16'(ep[seen])||
             dut.dm_en!==1||dut.dm_addr!==16'(ea[seen])||dut.dm_din!==data[seen])$fatal(1,"AUDIT3 store event %s",label);
          memory[ea[seen]]=data[seen];seen++;
        end
        if(dut.core.load_use)stalls++;
        if(dut.dm_en&&dut.dm_addr>255||dut.im_en&&dut.im_addr>255)$fatal(1,"AUDIT3 range guard");
        if(dut.core.x_valid)begin
          case(kind)
            0:if(dut.core.x_pc==2)begin
              if(dut.core.rs_fwd_sel!==2||dut.core.rs_fwd!==16'h5a00||dut.core.rd_fwd!==16'h00a5)$fatal(1,"AUDIT3 different loads operand alignment");witness=1;end
            1:if(dut.core.x_pc==2)begin
              if(dut.core.rs_fwd_sel!==2||dut.core.rs_fwd!==16'h5a00)$fatal(1,"AUDIT3 youngest of same-destination loads");witness=1;end
            2:if(dut.core.x_pc==2)begin
              if(dut.core.rs_fwd_sel!==1||dut.core.rs_fwd!==2)$fatal(1,"AUDIT3 newer M over old WB load");witness=1;end
            3:if(dut.core.x_pc==2)begin
              if(dut.core.rs_fwd_sel!==2||dut.core.rs_fwd!==16'h00a5)$fatal(1,"AUDIT3 newest load over older same-name value");witness=1;end
            4:if(dut.core.x_pc==2)begin
              if(dut.core.rd_fwd_sel!==2||dut.core.rs_fwd_sel!==1||dut.core.x_store_data!==16'h00b5||dut.core.alu_a!==32)$fatal(1,"AUDIT3 STR data WB/base M");witness=1;end
            5:if(dut.core.x_pc==2)begin
              if(dut.core.rd_fwd_sel!==1||dut.core.rs_fwd_sel!==2||dut.core.x_store_data!==16'h00b5||dut.core.alu_a!==32)$fatal(1,"AUDIT3 STR data M/base WB");witness=1;end
            6:if(dut.core.x_pc==1)begin
              if(dut.core.rd_fwd_sel!==1||dut.core.rs_fwd_sel!==1||dut.core.x_store_data!==32||dut.core.alu_a!==32)$fatal(1,"AUDIT3 STR identical sources M");witness=1;end
            7:if(dut.core.x_pc==1)begin
              if(dut.core.rd_fwd_sel!==2||dut.core.rs_fwd_sel!==2||dut.core.x_store_data!==33||dut.core.alu_a!==33)$fatal(1,"AUDIT3 load-STR identical sources W");witness=1;end
            8:if(dut.core.x_pc==2)begin
              if(dut.core.z_fwd_sel!==2||dut.core.z_effective!==1||dut.core.qualified_redirect!==1)$fatal(1,"AUDIT3 M arithmetic/W CMP Z fallback");witness=1;end
            9:if(dut.core.x_pc==2)begin
              if(dut.core.z_fwd_sel!==1||dut.core.z_effective!==0||dut.core.qualified_redirect!==0)$fatal(1,"AUDIT3 newer Z=0 overrides W=1");witness=1;end
            default:witness=1;
          endcase
        end
        #1;
        for(integer k=0;k<4;k++)if(dut.core.u_rf.regs[k]!==rf[k])$fatal(1,"AUDIT3 RF edge %s R%0d",label,k);
        if({dut.core.Z,dut.core.C,dut.core.V}!=={z,c,v})$fatal(1,"AUDIT3 flags edge %s",label);
        for(integer k=0;k<256;k++)if(dut.dm.mem[k]!==memory[k])$fatal(1,"AUDIT3 DM edge %s addr=%0d",label,k);
        if({halted,fault}!=={pre_halt,pre_fault})$fatal(1,"AUDIT3 exact stop edge %s",label);
      end
      if(cycles!=expect_cycles||stalls!=expect_stalls||seen!=n||!witness)$fatal(1,"AUDIT3 coverage/count %s C=%0d S=%0d",label,cycles,stalls);
      if(halted===fault||fault!==expected_fault||{dut.core.d_valid,dut.core.x_valid,dut.core.m_valid,dut.core.w_valid}!==0)$fatal(1,"AUDIT3 final stop %s",label);
      repeat(3)begin
        @(posedge clk);if({dut.im_en,dut.dm_en,dut.dm_we,dut.core.rf_we,dut.core.z_we,dut.core.cv_we} !== 6'b0)$fatal(1,"AUDIT3 stopped write");
        #1;if({halted,fault}!=={!expected_fault,expected_fault})$fatal(1,"AUDIT3 stop changed");
      end
      total++;$display("AUDIT3_CASE_PASS %s cycles=%0d stalls=%0d events=%0d",label,cycles,stalls,n);
    end
  endtask
  task automatic reset_restart(input bit faulting,at_consumption_edge);
    integer wait_cycles;
    begin
      fresh($sformatf("RESET_RESTART_fault%0d_consumption%0d",faulting,at_consumption_edge));
      dut.im.mem[0]=faulting?16'hb000:16'he000;
      @(negedge clk);rst=0;wait_cycles=0;
      // Stop token is pre-edge-visible in W after four valid clock edges.
      while(!dut.core.w_valid&&wait_cycles<8)begin @(negedge clk);wait_cycles++;end
      if(!dut.core.w_valid||dut.core.w_pc!==0)$fatal(1,"AUDIT3 reset-stop witness");
      if(!at_consumption_edge)begin @(posedge clk);#1;@(negedge clk);end
      dut.dm.mem[17]=16'hcafe;rst=1;#1;
      if({dut.dm_en,dut.dm_we,dut.core.rf_we,dut.core.z_we,dut.core.cv_we,dut.im_en} !== 6'b0)$fatal(1,"AUDIT3 reset qualification");
      @(posedge clk);#1;
      if(dut.core.PC_fetch!==0||dut.core.mode!==0||{halted,fault}!==0||{dut.core.d_valid,dut.core.x_valid,dut.core.m_valid,dut.core.w_valid}!==0||{dut.core.Z,dut.core.C,dut.core.V}!==0||dut.dm.mem[17]!==16'hcafe)$fatal(1,"AUDIT3 reset stop state");
      for(integer k=0;k<4;k++)if(dut.core.u_rf.regs[k]!==0)$fatal(1,"AUDIT3 reset RF");
      for(integer k=0;k<256;k++)begin memory[k]=dut.dm.mem[k];dut.im.mem[k]=16'hb000;end
      dut.im.mem[0]=16'h1007;dut.im.mem[1]=16'he000;n=0;kind=10;
      wb(0,0,7,1,0,0,0,0,0,0,0);halt_event(1);run_case(6,0);restarts++;
    end
  endtask
  initial begin
    fresh("BACK_LOAD_DIFFERENT");kind=0;fixture[3]=32;memory[32]=16'h00a5;memory[33]=16'h5a00;
    dut.im.mem[0]=16'h8300;dut.im.mem[1]=16'h8701;dut.im.mem[2]=16'h4100;dut.im.mem[3]=16'he000;
    wb(0,0,16'h00a5,1,0,0,0,0,0,0,1);wb(1,1,16'h5a00,1,0,0,0,0,0,0,1);wb(2,0,16'h5aa5,1,0,0,1,0,0,0,0);halt_event(3);run_case(9,1);
    fresh("BACK_LOAD_SAME_DEST");kind=1;fixture[3]=32;memory[32]=16'h00a5;memory[33]=16'h5a00;
    dut.im.mem[0]=16'h8300;dut.im.mem[1]=16'h8301;dut.im.mem[2]=16'h0400;dut.im.mem[3]=16'he000;
    wb(0,0,16'h00a5,1,0,0,0,0,0,0,1);wb(1,0,16'h5a00,1,0,0,0,0,0,0,1);wb(2,1,16'h5a00,1,0,0,0,0,0,0,0);halt_event(3);run_case(9,1);
    fresh("M_RESULT_OVER_OLD_LOAD");kind=2;fixture[3]=32;memory[32]=16'h00a5;
    dut.im.mem[0]=16'h8300;dut.im.mem[1]=16'h1002;dut.im.mem[2]=16'h0400;dut.im.mem[3]=16'he000;
    wb(0,0,16'h00a5,1,0,0,0,0,0,0,1);wb(1,0,2,1,0,0,0,0,0,0,0);wb(2,1,2,1,0,0,0,0,0,0,0);halt_event(3);run_case(8,0);
    fresh("NEW_LOAD_OVER_OLD_VALUE");kind=3;fixture[3]=32;memory[32]=16'h00a5;
    dut.im.mem[0]=16'h1001;dut.im.mem[1]=16'h8300;dut.im.mem[2]=16'h0400;dut.im.mem[3]=16'he000;
    wb(0,0,1,1,0,0,0,0,0,0,0);wb(1,0,16'h00a5,1,0,0,0,0,0,0,1);wb(2,1,16'h00a5,1,0,0,0,0,0,0,0);halt_event(3);run_case(9,1);
    fresh("STR_DATA_W_BASE_M");kind=4;
    dut.im.mem[0]=16'h10b5;dut.im.mem[1]=16'h1420;dut.im.mem[2]=16'h9100;dut.im.mem[3]=16'he000;
    wb(0,0,16'h00b5,1,0,0,0,0,0,0,0);wb(1,1,32,1,0,0,0,0,0,0,0);st(2,32,16'h00b5);halt_event(3);run_case(8,0);
    fresh("STR_DATA_M_BASE_W");kind=5;
    dut.im.mem[0]=16'h1420;dut.im.mem[1]=16'h10b5;dut.im.mem[2]=16'h9100;dut.im.mem[3]=16'he000;
    wb(0,1,32,1,0,0,0,0,0,0,0);wb(1,0,16'h00b5,1,0,0,0,0,0,0,0);st(2,32,16'h00b5);halt_event(3);run_case(8,0);
    fresh("STR_SAME_SOURCE_M");kind=6;
    dut.im.mem[0]=16'h1020;dut.im.mem[1]=16'h9000;dut.im.mem[2]=16'he000;
    wb(0,0,32,1,0,0,0,0,0,0,0);st(1,32,32);halt_event(2);run_case(7,0);
    fresh("LOAD_STR_BOTH_SOURCES_W");kind=7;fixture[3]=32;memory[32]=33;
    dut.im.mem[0]=16'h8300;dut.im.mem[1]=16'h9000;dut.im.mem[2]=16'he000;
    wb(0,0,33,1,0,0,0,0,0,0,1);st(1,33,33);halt_event(2);run_case(8,1);
    fresh("Z_W_CMP_THROUGH_M_ADD");kind=8;
    dut.im.mem[0]=16'ha000;dut.im.mem[1]=16'h5401;dut.im.mem[2]=16'hd001;dut.im.mem[3]=16'h9000;dut.im.mem[4]=16'he000;
    wb(0,0,0,0,1,1,0,0,0,0,0);wb(1,1,1,1,0,0,1,0,0,0,0);wb(2,0,0,0,0,0,0,0,0,0,0);halt_event(4);run_case(10,0);
    fresh("Z_NEW_M_ZERO_OVER_W_ONE");kind=9;fixture[1]=1;c=1;v=1;
    dut.im.mem[0]=16'ha000;dut.im.mem[1]=16'ha100;dut.im.mem[2]=16'hd001;dut.im.mem[3]=16'h1855;dut.im.mem[4]=16'he000;
    wb(0,0,0,0,1,1,0,0,0,0,0);wb(1,0,0,0,1,0,0,0,0,0,0);wb(2,0,0,0,0,0,0,0,0,0,0);wb(3,2,16'h55,1,0,0,0,0,0,0,0);halt_event(4);run_case(9,0);
    fresh("OLD_CMP_WB_WITH_MEM_STORE_FAULT");kind=10;fixture[3]=255;c=1;v=1;expected_fault=1;fault_pc=1;
    dut.im.mem[0]=16'ha000;dut.im.mem[1]=16'h9301;dut.im.mem[2]=16'h5401;dut.im.mem[3]=16'he000;
    wb(0,0,0,0,1,1,0,0,0,0,0);run_case(6,0);
    fresh("OLD_LOAD_WB_WITH_YOUNGER_LOAD_FAULT");kind=10;fixture[3]=255;memory[255]=16'hcafe;expected_fault=1;fault_pc=1;
    dut.im.mem[0]=16'h8300;dut.im.mem[1]=16'h8701;dut.im.mem[2]=16'he000;
    wb(0,0,16'hcafe,1,0,0,0,0,0,0,1);run_case(6,0);
    reset_restart(0,1);reset_restart(1,1);reset_restart(0,0);reset_restart(1,0);
    if(total!=16||restarts!=4)$fatal(1,"AUDIT3 coverage total");
    $display("AUDIT3_PASS directed=12 reset_restart=4 total=16 failures=0");check_cpu_controls("before_finish");$finish;
  end
 `include "tb_control_checks.svh"
endmodule
