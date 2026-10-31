`timescale 1ns/1ps
// sub=1 implements a + ~b + 1. carry then means NO BORROW.
// This ISA has no ADDC/SUBB; saved architectural C is not an input.
module addsub16_cla(
    input  [15:0] a, b,
    input         sub,
    output [15:0] result,
    output        carry, overflow
);
    wire [15:0] b_mod = b ^ {16{sub}};
    cla16 u_cla(.a(a), .b(b_mod), .cin(sub), .sum(result), .cout(carry));
    assign overflow = sub
        ? ((a[15] ^ b[15]) & (result[15] ^ a[15]))
        : (~(a[15] ^ b[15]) & (result[15] ^ a[15]));
endmodule
