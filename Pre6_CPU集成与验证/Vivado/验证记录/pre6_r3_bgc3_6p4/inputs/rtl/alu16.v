`timescale 1ns/1ps
// Internal op is NOT the CPU opcode: 0 PASS_B,1 ADD,2 SUB,3 AND,4 OR.
// eq is independent of op; only a qualified CMP writes architectural Z.
module alu16(
    input  [15:0] a, b,
    input  [2:0]  op,
    output reg [15:0] result,
    output        eq,
    output reg    illegal, carry, overflow
);
    wire [15:0] arithmetic_result;
    wire arithmetic_carry, arithmetic_overflow;
    addsub16_cla u_addsub(.a(a), .b(b), .sub(op == 3'd2),
        .result(arithmetic_result), .carry(arithmetic_carry),
        .overflow(arithmetic_overflow));
    assign eq = (a == b);
    always @* begin
        result = 16'h0000;
        carry = 1'b0;
        overflow = 1'b0;
        illegal = 1'b0;
        case (op)
            3'd0: result = b;
            3'd1, 3'd2: begin
                result = arithmetic_result;
                carry = arithmetic_carry;
                overflow = arithmetic_overflow;
            end
            3'd3: result = a & b;
            3'd4: result = a | b;
            default: illegal = 1'b1;
        endcase
    end
endmodule
