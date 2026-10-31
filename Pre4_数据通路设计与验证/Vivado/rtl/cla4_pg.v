`timescale 1ns/1ps
// Four-bit carry-lookahead group. P/G are functions of a/b only.
// v1.4 uses XOR propagation, so sum[i] = p[i] XOR c[i].
module cla4_pg(
    input  [3:0] a, b,
    input        cin,
    output [3:0] sum,
    output       cout,
    output       P, G
);
    wire [3:0] p = a ^ b;
    wire [3:0] g = a & b;
    wire [4:0] c;
    assign c[0] = cin;
    assign c[1] = g[0] | (p[0] & cin);
    assign c[2] = g[1] | (p[1] & g[0]) | (p[1] & p[0] & cin);
    assign c[3] = g[2] | (p[2] & g[1]) | (p[2] & p[1] & g[0])
                        | (p[2] & p[1] & p[0] & cin);
    assign P = &p;
    assign G = g[3] | (p[3] & g[2]) | (p[3] & p[2] & g[1])
                     | (p[3] & p[2] & p[1] & g[0]);
    assign c[4] = G | (P & cin);
    assign cout = c[4];
    assign sum = p ^ c[3:0];
endmodule
