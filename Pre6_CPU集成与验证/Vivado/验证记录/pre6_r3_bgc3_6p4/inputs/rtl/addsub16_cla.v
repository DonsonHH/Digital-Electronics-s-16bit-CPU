`timescale 1ns/1ps
// sub=1 implements a + ~b + 1. carry then means NO BORROW.
// This ISA has no ADDC/SUBB; saved architectural C is not an input.
// Timing experiment C: infer the FPGA carry chain with an explicit 17-bit sum.
// Module interface is retained; this implementation does not instantiate CLA.
module addsub16_cla(
    input  [15:0] a, b,
    input         sub,
    output [15:0] result,
    output        carry, overflow
);
    wire [15:0] b_mod = b ^ {16{sub}};
    wire [16:0] wide_sum = {1'b0, a} + {1'b0, b_mod} + {16'b0, sub};
    assign {carry, result} = wide_sum;
    assign overflow = sub
        ? ((a[15] ^ b[15]) & (result[15] ^ a[15]))
        : (~(a[15] ^ b[15]) & (result[15] ^ a[15]));
endmodule
