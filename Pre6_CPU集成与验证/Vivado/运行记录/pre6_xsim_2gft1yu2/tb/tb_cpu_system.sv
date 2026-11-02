`timescale 1ns/1ps
module system_checker #(parameter CASE_ID=0, LABEL="baseline", IM_FILE="programs/baseline_im.mem",DM_FILE="programs/baseline_dm.mem",
 parameter E0="programs/baseline_e0_events.mem",S0="programs/baseline_e0_stores.mem",E1="programs/baseline_e1_events.mem",S1="programs/baseline_e1_stores.mem",
 parameter N0=10,N1=10,STORES0=1,STORES1=1,CYCLES=17,STALLS=1,REDIRECTS=1,RESET_KIND=0,
 parameter [63:0] RF0=64'h0020000800020008,RF1=64'h0020000800020008,
 parameter [2:0] FLAGS0=3'b110,FLAGS1=3'b110,REASON=3'd1,parameter [15:0] STOP_PC=16'd10)
 (input clk,output reg done=0);
 reg rst=1;integer epoch=0,cycles=0,wb_count=0,stores=0,stalls=0,redirects=0;reg first_done=0;
 wire halted,fault,wb_valid,wb_fault,wb_halt,wb_store,rw,zw,cvw,stall,redirect,stop_valid,pc_valid,last_valid,mem_en,mem_we,last_store_valid;
 wire[1:0] rd;wire[15:0] pc,data,stop_pc,last_pc,mem_addr,mem_data,last_addr,last_data,fetch_pc;
 wire[2:0] wb_flags,flags,reason;wire[3:0] pipe_valid;wire[63:0] rf;
 wire [6:0] controls={wb_valid,wb_fault,wb_halt,wb_store,rw,zw,cvw};
`ifdef POST_SYNTH
 cpu_system dut(
`else
 cpu_system #(.IM_INIT_FILE(IM_FILE),.DM_INIT_FILE(DM_FILE)) dut(
`endif
 .clk(clk),.rst(rst),.halted(halted),.fault(fault),.observe_wb_valid(wb_valid),.observe_wb_fault(wb_fault),.observe_wb_halt(wb_halt),.observe_wb_store(wb_store),
 .observe_rf_we(rw),.observe_z_we(zw),.observe_cv_we(cvw),.observe_wb_rd(rd),.observe_wb_pc(pc),.observe_wb_data(data),.observe_wb_flags(wb_flags),
 .observe_stall(stall),.observe_redirect(redirect),.observe_fetch_pc(fetch_pc),.observe_pipeline_valid(pipe_valid),.observe_flags(flags),
 .stop_valid(stop_valid),.stop_pc_valid(pc_valid),.stop_pc(stop_pc),.stop_reason(reason),.last_completed_valid(last_valid),.last_completed_pc(last_pc),
 .rf_snapshot(rf),.observe_mem_en(mem_en),.observe_mem_we(mem_we),.observe_mem_addr(mem_addr),.observe_mem_data(mem_data),
 .last_store_valid(last_store_valid),.last_store_addr(last_addr),.last_store_data(last_data));
 reg[63:0] e0[0:255],e1[0:255];reg[79:0] s0[0:255],s1[0:255];reg[63:0] expected;reg[79:0] expected_store;
 reg expected_last_valid;reg[15:0] expected_last_pc;
 initial begin
  $readmemh(E0,e0,0,N0-1);$readmemh(E1,e1,0,N1-1);
  $readmemh(S0,s0,0,STORES0>0?STORES0-1:0);$readmemh(S1,s1,0,STORES1>0?STORES1-1:0);
  repeat(14)@(negedge clk);rst=0;
  if(RESET_KIND==1)begin
   wait(first_done);@(negedge clk);rst=1;repeat(2)@(negedge clk);epoch=1;rst=0;
  end else if(RESET_KIND==2)begin
   wait(mem_we===1'b1);@(negedge clk);rst=1;#1;
   if(mem_en!==0||mem_we!==0)$fatal(1,"SYSTEM_RESET_WRITE_NOT_DISABLED %s",LABEL);
   repeat(2)@(negedge clk);epoch=1;rst=0;
  end
 end
 always @(posedge clk)begin
  if(rst)begin
   if(rw!==0||zw!==0||cvw!==0||mem_en!==0||mem_we!==0)$fatal(1,"SYSTEM_RESET_SIDE_EFFECT %s",LABEL);
   cycles=0;wb_count=0;stores=0;stalls=0;redirects=0;
   #1;if(stop_valid!==0||pipe_valid!==0||rf!==0||flags!==0)$fatal(1,"SYSTEM_RESET_STATE %s",LABEL);
  end else if(!done&&!first_done || (!rst&&!done&&epoch==1))begin
   cycles=cycles+1;
   if($isunknown({controls,mem_en,mem_we,stall,redirect,pipe_valid}))$fatal(1,"SYSTEM_CONTROL_X %s",LABEL);
   if(wb_valid)begin
    if(wb_count>=(epoch==0?N0:N1))$fatal(1,"SYSTEM_EXTRA_WB %s",LABEL);
    expected=epoch==0?e0[wb_count]:e1[wb_count];
    if(pc!==expected[15:0]||{wb_fault,wb_store,wb_halt,cvw,zw,rw}!==expected[46:41])$fatal(1,"SYSTEM_WB_EVENT %s index=%0d pc=%h exp=%h",LABEL,wb_count,pc,expected[15:0]);
    if(rw&&(rd!==expected[21:20]||data!==expected[37:22]))$fatal(1,"SYSTEM_RF_WRITE %s",LABEL);
    if(zw&&wb_flags[2]!==expected[40])$fatal(1,"SYSTEM_Z_WRITE %s",LABEL);
    if(cvw&&wb_flags[1:0]!==expected[39:38])$fatal(1,"SYSTEM_CV_WRITE %s",LABEL);
    wb_count=wb_count+1;
   end
   if(mem_we)begin
    if(stores>=(epoch==0?STORES0:STORES1))$fatal(1,"SYSTEM_EXTRA_STORE %s",LABEL);
    expected_store=epoch==0?s0[stores]:s1[stores];
    if(mem_en!==1||mem_addr!==expected_store[62:47]||mem_data!==expected_store[37:22]||expected_store[79:63]!==wb_count)$fatal(1,"SYSTEM_STORE_EVENT %s",LABEL);
    stores=stores+1;
   end
   if(stall)stalls=stalls+1;if(redirect)redirects=redirects+1;
   #1;
   if(halted||fault)begin
    if(wb_count!==(epoch==0?N0:N1)||stores!==(epoch==0?STORES0:STORES1)||cycles!==CYCLES||stalls!==STALLS||redirects!==REDIRECTS)$fatal(1,"SYSTEM_COUNTS %s cycles=%0d wb=%0d stores=%0d stalls=%0d redirects=%0d",LABEL,cycles,wb_count,stores,stalls,redirects);
    if(rf!==(epoch==0?RF0:RF1)||flags!==(epoch==0?FLAGS0:FLAGS1)||stop_valid!==1||pc_valid!==1||stop_pc!==STOP_PC||reason!==REASON||fault!==(REASON!=1)||halted!==(REASON==1)||pipe_valid!==0)$fatal(1,"SYSTEM_STOP_STATE %s rf=%h flags=%b pc=%h reason=%0d",LABEL,rf,flags,stop_pc,reason);
    if(stores>0&&(!last_store_valid||last_addr!==expected_store[62:47]||last_data!==expected_store[37:22]))$fatal(1,"SYSTEM_LAST_STORE %s",LABEL);
    if(stores==0&&last_store_valid!==0)$fatal(1,"SYSTEM_PHANTOM_LAST_STORE %s",LABEL);
    expected_last_valid=REASON==1||(epoch==0?N0:N1)>1;
    expected_last_pc=REASON==1?STOP_PC:epoch==0?e0[N0-2][15:0]:e1[N1-2][15:0];
    if(last_valid!==expected_last_valid||(expected_last_valid&&last_pc!==expected_last_pc))$fatal(1,"SYSTEM_LAST_COMPLETED %s",LABEL);
    $display("SYSTEM_CASE_PASS name=%s epoch=%0d cycles=%0d wb=%0d stores=%0d stalls=%0d redirects=%0d stop_pc=%h reason=%0d rf=%h",LABEL,epoch,cycles,wb_count,stores,stalls,redirects,stop_pc,reason,rf);
    if(RESET_KIND==1&&epoch==0)first_done=1;
    else begin
     repeat(3)begin @(posedge clk);#1;
      if(stop_valid!==1||pc_valid!==1||stop_pc!==STOP_PC||reason!==REASON||halted!==(REASON==1)||fault!==(REASON!=1)||pipe_valid!==0||rw!==0||zw!==0||cvw!==0||mem_en!==0||mem_we!==0||rf!==(epoch==0?RF0:RF1)||flags!==(epoch==0?FLAGS0:FLAGS1)||last_valid!==expected_last_valid||(expected_last_valid&&last_pc!==expected_last_pc))$fatal(1,"SYSTEM_STOP_HOLD %s",LABEL);
      if(last_store_valid!==(stores>0)||(stores>0&&(last_addr!==expected_store[62:47]||last_data!==expected_store[37:22])))$fatal(1,"SYSTEM_LAST_STORE_HOLD %s",LABEL);
     end
     done=1;
    end
   end
  end
 end
 initial begin #10000;$fatal(1,"SYSTEM_TIMEOUT %s",LABEL);end
endmodule

`ifdef POST_SYNTH
module tb_cpu_system_mapped;
 reg clk=0;always #5 clk=~clk;wire done;
 `include "mapped_case.svh"
 initial begin wait(done);$display("SYSTEM_MAPPED_PASS cases=1 boot=file_only");$finish;end
endmodule
`else
module debug_injection_checker(input clk,output reg done=0);
 reg rst=1;integer checks=0;
 wire fault,valid,pcvalid;wire[15:0] pc;wire[2:0]reason;
 cpu_system #(.IM_INIT_FILE("programs/control_fault_im.mem"),.DM_INIT_FILE("programs/control_fault_dm.mem")) dut(.clk(clk),.rst(rst),.fault(fault),.stop_valid(valid),.stop_pc_valid(pcvalid),.stop_pc(pc),.stop_reason(reason));
 initial begin
  repeat(14)@(negedge clk);rst=0;force dut.core.load_use=0;
  wait(fault===1);#1;if(!valid||!pcvalid||reason!==5||pc!==2)$fatal(1,"DEBUG_INTERNAL_CONTROL_REASON");
  checks=checks+1;release dut.core.load_use;
  @(negedge clk);rst=1;repeat(2)@(negedge clk);rst=0;@(negedge clk);dut.core.mode=3'd7;
  @(posedge clk);#1;if(!fault||!valid||pcvalid||reason!==6)$fatal(1,"DEBUG_ILLEGAL_MODE_REASON");
  checks=checks+1;$display("DEBUG_INJECTION_PASS checks=2 scope=controlled_simulation_only");done=1;
 end
 initial begin #10000;$fatal(1,"DEBUG_INJECTION_TIMEOUT");end
endmodule
module tb_cpu_system;
 reg clk=0;always #5 clk=~clk;wire[10:0] done;wire injected;
 `include "system_cases.svh"
 debug_injection_checker debug_checks(clk,injected);
 initial begin wait((&done)&&injected);$display("SYSTEM_PASS cases=11 boot=file_only reset_kinds=2 debug_injections=2");$finish;end
 initial begin $dumpfile("system.vcd");$dumpvars(0,tb_cpu_system);end
endmodule
`endif
