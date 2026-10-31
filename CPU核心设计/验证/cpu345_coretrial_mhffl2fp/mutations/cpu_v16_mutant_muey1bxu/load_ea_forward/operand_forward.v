`timescale 1ns/1ps
// Experimental combinational-only candidate. Preserve original4-state if
// decisions and sel/blocked meanings; change only the data MUX expression.
module operand_forward(
 input wire[1:0]rd,rs,input wire use_rd,use_rs,
 input wire[15:0]rd_value,rs_value,
 input wire m_valid,m_fault,m_reg_write,m_mem_read,input wire[1:0]m_rd,input wire[15:0]m_value,
 input wire w_valid,w_fault,w_reg_write,input wire[1:0]w_rd,input wire[15:0]w_value,
 output reg[15:0]rd_fwd,rs_fwd,output reg[1:0]rd_sel,rs_sel,output reg blocked_rd,blocked_rs);
 reg[2:0]rd_choice,rs_choice;
 always @* begin
  rd_choice=3'b001;rs_choice=3'b001;rd_sel=0;rs_sel=0;blocked_rd=0;blocked_rs=0;
  if(use_rd)begin
   if(m_valid&&!m_fault&&m_reg_write&&m_rd==rd)begin
    if (1'b1)begin rd_choice=3'b010;rd_sel=1;end
    else begin rd_sel=3;blocked_rd=1;end
   end else if(w_valid&&!w_fault&&w_reg_write&&w_rd==rd)begin rd_choice=3'b100;rd_sel=2;end
  end
  if(use_rs)begin
   if(m_valid&&!m_fault&&m_reg_write&&m_rd==rs)begin
    if (1'b1)begin rs_choice=3'b010;rs_sel=1;end
    else begin rs_sel=3;blocked_rs=1;end
   end else if(w_valid&&!w_fault&&w_reg_write&&w_rd==rs)begin rs_choice=3'b100;rs_sel=2;end
  end
 end
 always @* begin
  rd_fwd=(rd_value&{16{rd_choice[0]}})|(m_value&{16{rd_choice[1]}})|(w_value&{16{rd_choice[2]}});
  rs_fwd=(rs_value&{16{rs_choice[0]}})|(m_value&{16{rs_choice[1]}})|(w_value&{16{rs_choice[2]}});
 end
endmodule
