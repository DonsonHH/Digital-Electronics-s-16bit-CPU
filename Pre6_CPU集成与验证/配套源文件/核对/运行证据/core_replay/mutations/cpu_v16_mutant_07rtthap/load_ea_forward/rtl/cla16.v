`timescale 1ns/1ps
// Two-level CLA: four local CLA4 groups plus an independent group-lookahead
// network. No group's cout drives the next group's cin.
module cla16(
    input  [15:0] a, b,
    input         cin,
    output [15:0] sum,
    output        cout
);
    wire [3:0] P, G;
    wire [4:0] K;
    wire [3:0] local_cout;
    assign K[0] = cin;
    assign K[1] = G[0] | (P[0] & K[0]);
    assign K[2] = G[1] | (P[1] & G[0])
                        | (P[1] & P[0] & K[0]);
    assign K[3] = G[2] | (P[2] & G[1]) | (P[2] & P[1] & G[0])
                        | (P[2] & P[1] & P[0] & K[0]);
    assign K[4] = G[3] | (P[3] & G[2]) | (P[3] & P[2] & G[1])
                        | (P[3] & P[2] & P[1] & G[0])
                        | (P[3] & P[2] & P[1] & P[0] & K[0]);
    cla4_pg u_group0(.a(a[3:0]),   .b(b[3:0]),   .cin(K[0]),
                    .sum(sum[3:0]),   .cout(local_cout[0]), .P(P[0]), .G(G[0]));
    cla4_pg u_group1(.a(a[7:4]),   .b(b[7:4]),   .cin(K[1]),
                    .sum(sum[7:4]),   .cout(local_cout[1]), .P(P[1]), .G(G[1]));
    cla4_pg u_group2(.a(a[11:8]),  .b(b[11:8]),  .cin(K[2]),
                    .sum(sum[11:8]),  .cout(local_cout[2]), .P(P[2]), .G(G[2]));
    cla4_pg u_group3(.a(a[15:12]), .b(b[15:12]), .cin(K[3]),
                    .sum(sum[15:12]), .cout(local_cout[3]), .P(P[3]), .G(G[3]));
    assign cout = K[4];
endmodule
