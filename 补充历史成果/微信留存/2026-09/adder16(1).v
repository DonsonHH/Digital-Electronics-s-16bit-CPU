`timescale 1ns / 1ps

// Full adder: direct three-term carry logic
module full_adder (
    input  wire a,
    input  wire b,
    input  wire cin,
    output wire sum,
    output wire cout
);

    wire p;
    wire ab, ac, bc;

    // sum = a XOR b XOR cin
    xor XOR1 (p,   a, b);
    xor XOR2 (sum, p, cin);

    // cout = (a AND b) OR (a AND cin) OR (b AND cin)
    and AND1 (ab, a, b);
    and AND2 (ac, a, cin);
    and AND3 (bc, b, cin);

    or OR1 (cout, ab, ac, bc);

endmodule


// 16-bit ripple-carry adder
module adder16 (
    input  wire [15:0] a,
    input  wire [15:0] b,
    input  wire        cin,
    output wire [15:0] sum,
    output wire        cout
);

    wire [16:0] c;

    assign c[0] = cin;
    assign cout = c[16];

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : GEN_FA
            full_adder FA (
                .a    (a[i]),
                .b    (b[i]),
                .cin  (c[i]),
                .sum  (sum[i]),
                .cout (c[i+1])
            );
        end
    endgenerate

endmodule