`timescale 1ns/1ps
// Finite control/index-space proof for the existing forwarding interface.
// Data values are distinct sentinels; not a 16-bit data-space exhaustion.
module tb_forward_contract;
 reg [1:0] rd,rs,m_rd,w_rd;
 reg use_rd,use_rs,m_valid,m_fault,m_reg_write,m_mem_read;
 reg w_valid,w_fault,w_reg_write;
 reg [15:0] rd_value=16'h1111,rs_value=16'h2222,m_value=16'h3333,w_value=16'h4444;
 wire [15:0] rd_fwd,rs_fwd;wire [1:0] rd_sel,rs_sel;wire blocked_rd,blocked_rs;
 operand_forward dut(.*);
 integer idx,mask,count=0;reg [1:0] er,es;reg [15:0] vr,vs;reg br,bs;
 task automatic oracle(input [1:0] source,input used,input [15:0] saved,
   output [1:0] sel,output [15:0] val,output blocked);
  reg match_m,match_w;
  begin
   sel=0;val=saved;blocked=0;
   // Truth-table oracle: source use, qualified age match and readiness.
   // Deliberately not a copy of the DUT's nested if/else control flow.
   match_m=m_valid&&!m_fault&&m_reg_write&&(m_rd==source);
   match_w=w_valid&&!w_fault&&w_reg_write&&(w_rd==source);
   casez({used,match_m,match_w,m_mem_read})
    4'b0???:begin sel=0;val=saved;end
    4'b11?0:begin sel=1;val=m_value;end
    4'b11?1:begin sel=3;val=saved;blocked=1;end
    4'b101?:begin sel=2;val=w_value;end
    4'b100?:begin sel=0;val=saved;end
    default:$fatal(1,"FORWARD_ORACLE_UNKNOWN_CONTROL");
   endcase
  end
 endtask
 initial begin
  // Four 2-bit indexes, 2 use bits, 4 M qualifiers, 3 W qualifiers = 2^17.
  for(idx=0;idx<256;idx++)for(mask=0;mask<512;mask++)begin
   {rd,rs,m_rd,w_rd}=8'(idx);
   {use_rd,use_rs,m_valid,m_fault,m_reg_write,m_mem_read,w_valid,w_fault,w_reg_write}=9'(mask);
   oracle(rd,use_rd,rd_value,er,vr,br);oracle(rs,use_rs,rs_value,es,vs,bs);#1;
   if({rd_sel,rs_sel,rd_fwd,rs_fwd,blocked_rd,blocked_rs}!=={er,es,vr,vs,br,bs})
    $fatal(1,"FORWARD_CONTRACT idx=%h qualifiers=%h",idx,mask);
   count++;
  end
  if(count!=131072)$fatal(1,"FORWARD_COVERAGE_COUNT actual=%0d expected=131072",count);
  $display("FORWARD_CONTRACT_PASS controls=%0d failures=0 scope=control_index_not_full_data",count);$finish;
 end
endmodule
