`timescale 1ns/1ps
// Retained Pre3 ports and storage name. R0 is ordinary writable storage.
module regfile4x16(
    input clk, rst, we,
    input [1:0] waddr, raddr_a, raddr_b,
    input [15:0] wdata,
    output reg [15:0] rdata_a, rdata_b
);
    reg [15:0] regs[0:3];
    integer i;
    always @(posedge clk) begin
        if (rst)
            for (i=0; i<4; i=i+1) regs[i] <= 16'h0000;
        else if (we) regs[waddr] <= wdata;
    end
    always @* begin
        rdata_a = regs[raddr_a];
        rdata_b = regs[raddr_b];
        if (we && !rst && waddr == raddr_a) rdata_a = wdata;
        if (we && !rst && waddr == raddr_b) rdata_b = wdata;
    end
endmodule
