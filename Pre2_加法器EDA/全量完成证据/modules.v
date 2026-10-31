`timescale 1ns/1ps
module mux_gate #(parameter W=16)(input [W-1:0] a,b,input sel,output [W-1:0] y);
  wire ns;
  not(ns,sel);
  genvar i;
  generate for(i=0;i<W;i=i+1) begin: bitslice
    wire p,q;
    and(p,a[i],ns);
    and(q,b[i],sel);
    or(y[i],p,q);
  end endgenerate
endmodule
module mux_rtl #(parameter W=16)(input [W-1:0] a,b,input sel,output reg [W-1:0] y);
  always @* begin
    if(sel) y=b;
    else y=a;
  end
endmodule
module half_adder(input a,b,output sum,cout);
  xor(sum,a,b);
  and(cout,a,b);
endmodule
module full_adder(input a,b,cin,output sum,cout);
  wire p,g,h;
  half_adder h0(.a(a),.b(b),.sum(p),.cout(g));
  half_adder h1(.a(p),.b(cin),.sum(sum),.cout(h));
  or(cout,g,h);
endmodule
module ripple_adder #(parameter W=16)(input [W-1:0] a,b,input cin,output [W-1:0] sum,output cout);
  wire [W:0] c;
  assign c[0]=cin;
  assign cout=c[W];
  genvar i;
  generate for(i=0;i<W;i=i+1) begin: stage
    full_adder fa(.a(a[i]),.b(b[i]),.cin(c[i]),.sum(sum[i]),.cout(c[i+1]));
  end endgenerate
endmodule
module adder_rtl #(parameter W=16)(input [W-1:0] a,b,input cin,output reg [W-1:0] sum,output reg cout);
  always @* begin
    {cout,sum}={1'b0,a}+{1'b0,b}+{{W{1'b0}},cin};
  end
endmodule
