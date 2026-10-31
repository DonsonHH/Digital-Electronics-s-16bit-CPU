`timescale 1ns/1ps
// Combinational companion; branch_pc must be the branch instruction's tag.
module branch_target16(input [15:0] branch_pc,input [7:0] imm,input relative,
 output [15:0] target);
 wire [15:0] offset={{8{imm[7]}},imm};
 assign target=relative ? branch_pc+16'd1+offset : {8'h00,imm};
endmodule
