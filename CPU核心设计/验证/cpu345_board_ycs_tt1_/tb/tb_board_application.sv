`timescale 1ns/1ps
module board_case #(parameter KIND=0)(input clk,output reg done=0);
 reg btn_n=1,debug_reset=1;
 wire[255:0] state;wire[159:0] perf;wire[127:0] events;wire[7:0] led;wire rst;
 localparam IM=KIND==0?"programs/all_ops_im.mem":KIND==1?"programs/reset_after_halt_im.mem":"programs/reset_before_store_im.mem";
 localparam DM=KIND==0?"programs/all_ops_dm.mem":KIND==1?"programs/reset_after_halt_dm.mem":"programs/reset_before_store_dm.mem";
 ees331_application #(.IM_INIT_FILE(IM),.DM_INIT_FILE(DM),.RELEASE_BITS(3),.BUILD_ID(64'h123456789abcdef0)) dut(.clk(clk),.reset_btn_n(btn_n),.debug_reset(debug_reset),.state_probe(state),.perf_probe(perf),.event_probe(events),.led(led),.core_reset(rst));
 task check_stop(input[63:0] expected_rf,input integer c,n,s,b,st);
 begin
  wait(state[86]===1);#1;
  if(state[63:0]!==expected_rf||state[87]!==1||state[88]!==1||state[89]!==0||state[85:83]!==1||state[255:192]!==64'h123456789abcdef0)$fatal(1,"BOARD_STOP_STATE kind=%0d state=%h",KIND,state);
  if(perf!=={32'(st),32'(b),32'(s),32'(n),32'(c)})$fatal(1,"BOARD_COUNTERS kind=%0d perf=%h",KIND,perf);
  repeat(4)begin @(posedge clk);#1;if(perf!=={32'(st),32'(b),32'(s),32'(n),32'(c)}||state[63:0]!==expected_rf)$fatal(1,"BOARD_STOP_NOT_STABLE");end
 end endtask
 initial begin
  repeat(5)@(negedge clk);debug_reset=0;
  if(KIND==0)begin check_stop(64'h0020000500050005,25,16,1,2,1);end
  if(KIND==1)begin
   check_stop(64'h0020000000000006,10,5,1,0,1);
   @(negedge clk);debug_reset=1;#1;if(!rst)$fatal(1,"BOARD_DEBUG_RESET_NOT_ASSERTED");
   repeat(3)@(negedge clk);debug_reset=0;
   wait(rst===0);check_stop(64'h0020000000000007,10,5,1,0,1);
  end
  if(KIND==2)begin
   wait(events[45]===1);@(negedge clk);#1;btn_n=0;#1;
   if(rst!==1||events[45]!==0)$fatal(1,"BOARD_BUTTON_FAILED_TO_BLOCK_PENDING_WRITE");
   repeat(5)begin @(negedge clk);btn_n=1;repeat(4)@(negedge clk);btn_n=0;end
   repeat(3)@(negedge clk);#1;if(perf!==0||state[86]!==0)$fatal(1,"BOARD_BOUNCE_EARLY_START");
   btn_n=1;wait(rst===0);check_stop(64'h0020000012340055,9,5,0,0,1);
  end
  $display("BOARD_CASE_PASS kind=%0d",KIND);done=1;
 end
 always @(posedge clk)if(rst)begin #1;if(perf!==0||events[45]!==0)$fatal(1,"BOARD_RESET_SIDE_EFFECT");end
 initial begin #20000;$fatal(1,"BOARD_APPLICATION_TIMEOUT kind=%0d",KIND);end
endmodule
module tb_board_application;
 reg clk=0;always #5 clk=~clk;wire[2:0]done;
 board_case #(0) c0(clk,done[0]);board_case #(1)c1(clk,done[1]);board_case #(2)c2(clk,done[2]);
 initial begin $dumpfile("board_application.vcd");$dumpvars(0,tb_board_application);wait(&done);$display("BOARD_APPLICATION_PASS cases=3 reset_paths=2 bounce=1");$finish;end
endmodule
