`timescale 1ns/1ps
// The first RED/GREEN check: successful store keeps a valid WB token.
module tb_uniform_smoke;
 reg clk=0,rst=1;always #5 clk=~clk;
 wire halted,fault;pre4_system dut(clk,rst,halted,fault);
 integer cycles=0,retired=0,stores=0,store_wb=0,branch_wb=0;
 bit was_store;reg [15:0] saved_pc;
 initial begin
  repeat(2)@(posedge clk);#1;
  dut.im.mem[0]=16'h1007;dut.im.mem[1]=16'h1420;
  dut.im.mem[2]=16'h9100;dut.im.mem[3]=16'hc005;
  dut.im.mem[4]=16'hf000;dut.im.mem[5]=16'he000;
  @(negedge clk);rst=0;
  while(!halted&&!fault&&cycles<20)begin
   @(posedge clk);cycles++;
   was_store=dut.dm_we;saved_pc=dut.core.m_pc;
   if(dut.dm_we)stores++;
   if(dut.core.w_valid&&!dut.core.w_fault)begin
    retired++;
    if(dut.core.w_pc==2)begin
     store_wb++;
     if(dut.core.rf_we||dut.core.z_we||dut.core.cv_we)$fatal(1,"SMOKE_STORE_WB_SIDE_EFFECT");
    end
    if(dut.core.w_pc==3)branch_wb++;
   end
   #1;
   if(was_store && (dut.core.w_valid!==1||dut.core.w_pc!==saved_pc||dut.core.w_fault!==0))
    $fatal(1,"UNIFORM_STORE_TOKEN_MISSING pc=%h cycle=%0d",saved_pc,cycles);
  end
  if(!halted||fault||retired!=5||stores!=1||store_wb!=1||branch_wb!=1||dut.dm.mem[32]!==7)
   $fatal(1,"SMOKE_COUNTS_OR_STATE retired=%0d stores=%0d store_wb=%0d",retired,stores,store_wb);
  $display("UNIFORM_SMOKE_PASS retired=5 stores=1 store_wb=1 branch_wb=1");check_cpu_controls("before_finish");$finish;
 end
 `include "tb_control_checks.svh"
endmodule
