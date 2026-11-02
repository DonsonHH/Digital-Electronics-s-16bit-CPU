`timescale 1ns/1ps
// Retained Pre3 ports. branch_pc is the instruction's tag, not PC_fetch.
module branch_target16(
    input [15:0] branch_pc,
    input [7:0] imm,
    input relative,
    output [15:0] target
);
    wire [15:0] offset = {{8{imm[7]}}, imm};
    assign target = relative ? branch_pc + 16'd1 + offset : {8'h00, imm};
endmodule
