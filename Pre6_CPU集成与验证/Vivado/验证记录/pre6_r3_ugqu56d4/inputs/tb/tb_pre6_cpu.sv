`timescale 1ns/1ps
module pre6_checker #(parameter CASE_ID=0, LABEL="baseline", IM_FILE="baseline_im.mem",DM_FILE="baseline_dm.mem",
 parameter E0="baseline_e0_events.mem",S0="baseline_e0_stores.mem",E1="baseline_e1_events.mem",S1="baseline_e1_stores.mem",
 parameter N0=10,N1=10,STORES0=1,STORES1=1,CYCLES=17,STALLS=1,REDIRECTS=1,RESET_KIND=0,
 parameter [63:0] RF0=64'h0020000800020008,RF1=64'h0020000800020008,
 parameter [2:0] FLAGS0=3'b110,FLAGS1=3'b110,REASON=3'd1,parameter [15:0] STOP_PC=16'd10)
 (input clk,output reg done=0);
 reg rst=1;integer trace;integer epoch=0,cycles=0,wb_count=0,stores=0,stalls=0,redirects=0;reg first_done=0;
 wire halted,fault,wb_valid,wb_fault,wb_halt,wb_store,rw,zw,cvw,stall,redirect,stop_valid,pc_valid,last_valid,mem_en,mem_we,last_store_valid;
 wire[1:0] rd;wire[15:0] pc,data,stop_pc,last_pc,mem_addr,mem_data,last_addr,last_data,fetch_pc;
 wire[2:0] wb_flags,flags,reason;wire[3:0] pipe_valid;wire[63:0] rf;
 wire [6:0] controls={wb_valid,wb_fault,wb_halt,wb_store,rw,zw,cvw};
pre6_cpu_top dut(
 .clk(clk),.rst(rst),.halted(halted),.fault(fault),.observe_wb_valid(wb_valid),.observe_wb_fault(wb_fault),.observe_wb_halt(wb_halt),.observe_wb_store(wb_store),
 .observe_rf_we(rw),.observe_z_we(zw),.observe_cv_we(cvw),.observe_wb_rd(rd),.observe_wb_pc(pc),.observe_wb_data(data),.observe_wb_flags(wb_flags),
 .observe_stall(stall),.observe_redirect(redirect),.observe_fetch_pc(fetch_pc),.observe_pipeline_valid(pipe_valid),.observe_flags(flags),
 .stop_valid(stop_valid),.stop_pc_valid(pc_valid),.stop_pc(stop_pc),.stop_reason(reason),.last_completed_valid(last_valid),.last_completed_pc(last_pc),
 .rf_snapshot(rf),.observe_mem_en(mem_en),.observe_mem_we(mem_we),.observe_mem_addr(mem_addr),.observe_mem_data(mem_data),
 .last_store_valid(last_store_valid),.last_store_addr(last_addr),.last_store_data(last_data));

 initial begin
  trace=$fopen("cpu_trace.csv","w");if(!trace)$fatal(1,"PRE6_TRACE_OPEN");
  $fdisplay(trace,"time_ps,cycle,wb_valid,wb_pc,rf_we,wb_rd,wb_data,z_we,cv_we,dm_we,dm_addr,dm_data,stall,redirect");
 end
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
   $fdisplay(trace,"%0t,%0d,%b,%h,%b,%0d,%h,%b,%b,%b,%h,%h,%b,%b",$time,cycles,wb_valid,pc,rw,rd,data,zw,cvw,mem_we,mem_addr,mem_data,stall,redirect);
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

module tb_pre6_cpu;
 `include "selected_expected.svh"
 reg clk=0;always #5 clk=~clk;wire done;
 pre6_checker #(.LABEL(PROGRAM),.E0("selected_events.mem"),.E1("selected_events.mem"),
 .S0("selected_stores.mem"),.S1("selected_stores.mem"),.N0(EXPECTED_N),.N1(EXPECTED_N),
 .STORES0(EXPECTED_STORES),.STORES1(EXPECTED_STORES),.CYCLES(EXPECTED_CYCLES),
 .STALLS(EXPECTED_STALLS),.REDIRECTS(EXPECTED_REDIRECTS),.RF0(EXPECTED_RF),.RF1(EXPECTED_RF),
 .FLAGS0(EXPECTED_FLAGS),.FLAGS1(EXPECTED_FLAGS),.STOP_PC(EXPECTED_PC)) check(.clk(clk),.done(done));
 initial begin wait(done);$display("PRE6_CPU_PASS program=%s cycles=%0d completed=%0d stalls=%0d redirects=%0d stores=%0d",PROGRAM,EXPECTED_CYCLES,EXPECTED_N,EXPECTED_STALLS,EXPECTED_REDIRECTS,EXPECTED_STORES);$finish;end
 initial begin $dumpfile("pre6_cpu.vcd");$dumpvars(0,tb_pre6_cpu);end
endmodule
