`timescale 1ns/1ps
// Retained Pre3 ports. MOV/ADD/SUB/JUMP use zero extension;
// LDR/STR/JZ use sign extension per ISA v1.4.
module imm_ext16(
    input [7:0] imm,
    input sign_mode,
    output reg [15:0] value
);
    always @* begin
        if (sign_mode) value = {{8{imm[7]}}, imm};
        else value = {8'h00, imm};
    end
endmodule
