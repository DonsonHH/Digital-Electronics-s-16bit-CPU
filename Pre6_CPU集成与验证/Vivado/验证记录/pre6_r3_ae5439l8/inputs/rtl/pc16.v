`timescale 1ns/1ps
// Retained Pre3 ports. redirect wins over hold; rst wins over both.
module pc16(
    input clk, rst, hold, redirect,
    input [15:0] target,
    output reg [15:0] pc
);
    always @(posedge clk) begin
        if (rst) pc <= 16'h0000;
        else if (redirect) pc <= target;
        else if (!hold) pc <= pc + 16'd1;
    end
endmodule
