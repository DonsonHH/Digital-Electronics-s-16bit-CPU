`timescale 1ns/1ps
module tb_memory_files;
 reg clk=0;always #5 clk=~clk;
 reg ie=0,de=0,we=0;reg [7:0] ia=0,da=0;reg[15:0] din=0;
 wire[15:0] iq,dq;
 instruction_memory #(.INIT_FILE("programs/memory_im.mem")) im(clk,ie,ia,iq);
 data_memory #(.INIT_FILE("programs/memory_dm.mem")) dm(clk,de,we,da,din,dq);
 task tick;begin @(posedge clk);#1;end endtask
 initial begin
  #1;if(iq!==0||dq!==0)$fatal(1,"MEM_INITIAL_OUTPUT");
  @(negedge clk);ie=1;ia=0;de=1;da=0;tick;
  if(iq!==16'h1005||dq!==16'hbeef)$fatal(1,"MEM_FIRST_FILE_READ");
  @(negedge clk);ie=0;ia=1;de=0;da=7;tick;
  if(iq!==16'h1005||dq!==16'hbeef)$fatal(1,"MEM_DISABLED_HOLD");
  @(negedge clk);ie=1;ia=1;de=1;we=1;da=7;din=16'h1234;tick;
  if(iq!==16'h1403||dq!==16'hbeef)$fatal(1,"MEM_WRITE_OUTPUT_HOLD");
  @(negedge clk);we=0;tick;
  if(dq!==16'h1234)$fatal(1,"MEM_STORE_THEN_LOAD");
  @(negedge clk);da=0;tick;
  if(dq!==16'hbeef)$fatal(1,"MEM_CONSECUTIVE_READ");
  @(negedge clk);de=0;we=1;da=7;din=16'hffff;tick;
  @(negedge clk);de=1;we=0;tick;
  if(dq!==16'h1234)$fatal(1,"MEM_DISABLED_WRITE");
  $display("MEMORY_FILE_CONTRACT_PASS checks=7");$finish;
 end
 initial begin #1000;$fatal(1,"MEMORY_TIMEOUT");end
endmodule
