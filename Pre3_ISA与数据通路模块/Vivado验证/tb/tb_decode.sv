`timescale 1ns/1ps
module tb_decode;
 reg [15:0] inst=0;wire [1:0] rd,rs;wire [7:0] imm;
 wire ur,us,sg,rw,mr,mw,fw,ja,jz,halt,ill;wire [2:0] af;
 isa_decode d(inst,rd,rs,imm,ur,us,sg,rw,mr,mw,fw,ja,jz,halt,ill,af);
 // Literal control vectors from the reviewed ISA table, not DUT internals.
 // {use_rd,use_rs,sign,reg_write,mem_read,mem_write,flag_write,jump_abs,jump_z,halt,illegal}
 reg [10:0] controls[0:15];reg [2:0] funcs[0:15];integer n,fd;
 initial begin
 controls[0]=11'b00010000000;funcs[0]=0;
 controls[1]=11'b01010000000;funcs[1]=0;
 controls[2]=11'b10010000000;funcs[2]=1;
 controls[3]=11'b11010000000;funcs[3]=1;
 controls[4]=11'b11010000000;funcs[4]=2;
 controls[5]=11'b11010000000;funcs[5]=3;
 controls[6]=11'b11010000000;funcs[6]=4;
 controls[7]=11'b00000001000;funcs[7]=0;
 controls[8]=11'b01111000000;funcs[8]=1;
 controls[9]=11'b11100100000;funcs[9]=1;
 controls[10]=11'b11000010000;funcs[10]=0;
 controls[11]=11'b00100000100;funcs[11]=0;
 controls[12]=11'b00000000010;funcs[12]=0;
 for(n=13;n<16;n++)begin controls[n]=11'b00000000001;funcs[n]=0;end
 for(n=0;n<65536;n++)begin
  inst=n;#1;
  if({ur,us,sg,rw,mr,mw,fw,ja,jz,halt,ill}!==controls[n>>12] || af!==funcs[n>>12])$fatal(1,"DECODE fail word=%h",inst);
  if(rd!==inst[11:10] || rs!==inst[9:8] || imm!==inst[7:0])$fatal(1,"FIELD fail");
 end
 $display("DECODE_PASS words=65536 failures=0");
 fd=$fopen("decode_results.json","w");$fdisplay(fd,"{\"words\":65536,\"failures\":0}");$fclose(fd);$finish;
 end
endmodule
