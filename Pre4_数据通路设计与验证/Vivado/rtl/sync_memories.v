`timescale 1ns/1ps
// Fixed one-edge native memories, matching v1.4 IM/DM boundary contracts.
// Their registered read outputs are the IF/ID and MEM/WB data boundaries.
// The CPU carries tags/controls beside these outputs; it does not add IR/MDR.
module instruction_memory(input clk,en,input [7:0] addr,output reg [15:0] dout);
 reg [15:0] mem[0:255];integer i;
 initial begin dout=0;for(i=0;i<256;i=i+1)mem[i]=16'hb000;end
 always @(posedge clk) if(en)dout<=mem[addr]; // hold when disabled
endmodule
module data_memory(input clk,en,we,input [7:0] addr,input [15:0] din,output reg [15:0] dout);
 reg [15:0] mem[0:255];integer i;
 initial begin dout=0;for(i=0;i<256;i=i+1)mem[i]=16'h0000;end
 // Successful store followed by load observes the newly written array value.
 // No simultaneous read and write request exists in this single-port contract.
 always @(posedge clk) if(en)begin
   if(we)mem[addr]<=din;else dout<=mem[addr];
 end
endmodule
module pre4_system(input clk,rst,output halted,fault);
 wire [15:0] im_addr,im_dout,dm_addr,dm_din,dm_dout;
 wire im_en,dm_en,dm_we;
 datapath_core core(.clk(clk),.rst(rst),.im_addr(im_addr),.im_en(im_en),.im_dout(im_dout),
 .dm_addr(dm_addr),.dm_en(dm_en),.dm_we(dm_we),.dm_din(dm_din),.dm_dout(dm_dout),.halted(halted),.fault(fault));
 instruction_memory im(.clk(clk),.en(im_en),.addr(im_addr[7:0]),.dout(im_dout));
 data_memory dm(.clk(clk),.en(dm_en),.we(dm_we),.addr(dm_addr[7:0]),.din(dm_din),.dout(dm_dout));
endmodule
