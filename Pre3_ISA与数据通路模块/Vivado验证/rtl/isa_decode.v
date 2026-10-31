`timescale 1ns/1ps
// Pre3 combinational ISA-to-interface mapping, NOT a pipeline control unit.
module isa_decode(input [15:0] inst,output [1:0] rd,rs,output [7:0] imm,
 output reg use_rd,use_rs,imm_signed,reg_write,mem_read,mem_write,flag_write,
 output reg jump_abs,jump_z,halt,illegal,output reg [2:0] alu_op);
 assign rd=inst[11:10];assign rs=inst[9:8];assign imm=inst[7:0];
 always @* begin
   use_rd=0;use_rs=0;imm_signed=0;reg_write=0;mem_read=0;mem_write=0;flag_write=0;
   jump_abs=0;jump_z=0;halt=0;illegal=0;alu_op=0;
   case(inst[15:12])
    4'h0:reg_write=1;
    4'h1:begin reg_write=1;use_rs=1;end
    4'h2:begin reg_write=1;use_rd=1;alu_op=1;end
    4'h3:begin reg_write=1;use_rd=1;use_rs=1;alu_op=1;end
    4'h4:begin reg_write=1;use_rd=1;use_rs=1;alu_op=2;end
    4'h5:begin reg_write=1;use_rd=1;use_rs=1;alu_op=3;end
    4'h6:begin reg_write=1;use_rd=1;use_rs=1;alu_op=4;end
    4'h7:jump_abs=1;
    4'h8:begin reg_write=1;mem_read=1;use_rs=1;imm_signed=1;alu_op=1;end
    4'h9:begin mem_write=1;use_rd=1;use_rs=1;imm_signed=1;alu_op=1;end
    4'ha:begin flag_write=1;use_rd=1;use_rs=1;end
    4'hb:begin jump_z=1;imm_signed=1;end
    4'hc:halt=1;
    default:illegal=1;
   endcase
 end
endmodule
