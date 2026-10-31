`timescale 1ns/1ps
module alu16(input [15:0] a,b,input [2:0] op,
 output reg [15:0] result,output reg illegal,output eq);
 // Internal ALU control is separate from the 4-bit instruction opcode.
 localparam PASS_B=3'd0,ADD=3'd1,SUB=3'd2,AND_OP=3'd3,OR_OP=3'd4;
 assign eq=(a==b); // CMP candidate; does not itself write architectural Z.
 always @* begin
   result=16'h0000;illegal=1'b0;
   case(op)
     PASS_B: result=b;
     ADD: result=a+b; // Defined 16-bit modulo result.
     SUB: result=a-b;
     AND_OP: result=a&b;
     OR_OP: result=a|b;
     default: begin result=16'h0000;illegal=1'b1;end
   endcase
 end
endmodule
