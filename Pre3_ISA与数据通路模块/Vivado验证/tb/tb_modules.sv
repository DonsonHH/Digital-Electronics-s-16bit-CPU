`timescale 1ns/1ps
module tb_modules;
 reg clk=0; always #5 clk=~clk;
 reg rst_rf=1,we=0;reg [1:0] wa=0,ra=0,rb=0;reg [15:0] wd=0;
 wire [15:0] qa,qb;
 regfile4x16 rf(clk,rst_rf,we,wa,ra,rb,wd,qa,qb);
 reg [15:0] a=0,b=0;reg [2:0] op=0;wire [15:0] result;wire illegal,eq;
 alu16 alu(a,b,op,result,illegal,eq);
 reg rst_pc=1,hold=0,redirect=0;reg [15:0] target=0;wire [15:0] pc;
 pc16 pcu(clk,rst_pc,hold,redirect,target,pc);
 reg [7:0] imm=0;reg sign_mode=0;wire [15:0] extended;
 imm_ext16 ext(imm,sign_mode,extended);
 reg [15:0] branch_pc=0;reg relative=0;wire [15:0] bt;
 branch_target16 branch(branch_pc,imm,relative,bt);
 integer i,j,k,v,fd;
 longint unsigned n_rf=0,n_alu=0,n_pc=0,n_imm=0,n_target=0;
 reg [15:0] model[0:3];reg [31:0] rng=32'h20260920;
 reg capture=1;
 function automatic [31:0] nxt(input [31:0] x);
   reg [31:0] t;begin t=x^(x<<13);t=t^(t>>17);nxt=t^(t<<5);end
 endfunction
 task automatic alu_check(input [15:0] x,y,input [2:0] f);
   reg [15:0] exp;reg bad;integer unsigned wide;
   begin
     a=x;b=y;op=f;bad=0;
     case(f)
       0:exp=y;
       1:begin wide=int'(x)+int'(y);exp=wide%65536;end
       2:begin wide=int'(x)+65536-int'(y);exp=wide%65536;end
       3:exp=x&y;
       4:exp=x|y;
       default:begin exp=0;bad=1;end
     endcase
     #1;
     if(result!==exp || illegal!==bad || eq!==(x==y))
       $fatal(1,"ALU fail a=%h b=%h op=%d got=%h expected=%h",x,y,f,result,exp);
     n_alu++;
   end
 endtask
 task automatic rf_check(input bit reset_i,write_i,input [1:0] addr,read_a,read_b,input [15:0] data);
   reg [15:0] ea,eb;
   begin
     @(negedge clk);rst_rf=reset_i;we=write_i;wa=addr;ra=read_a;rb=read_b;wd=data;
     #1;ea=model[read_a];eb=model[read_b];
     if(write_i&&!reset_i)begin if(addr==read_a)ea=data;if(addr==read_b)eb=data;end
     if(qa!==ea || qb!==eb)$fatal(1,"RF pre-edge/bypass fail");
     @(posedge clk);
     if(reset_i)for(integer z=0;z<4;z++)model[z]=0;
     else if(write_i)model[addr]=data;
     #1;ea=model[read_a];eb=model[read_b];
     if(qa!==ea || qb!==eb)$fatal(1,"RF post-edge fail");
     n_rf++;
   end
 endtask
 task automatic pc_check(input bit reset_i,hold_i,redirect_i,input [15:0] t);
   reg [15:0] before_pc,exp;
   begin
     @(negedge clk);before_pc=pc;rst_pc=reset_i;hold=hold_i;redirect=redirect_i;target=t;
     #1;if(pc!==before_pc)$fatal(1,"PC changed without active edge");
     if(reset_i)exp=0;else if(redirect_i)exp=t;else if(hold_i)exp=before_pc;else exp=before_pc+16'd1;
     @(posedge clk);#1;if(pc!==exp)$fatal(1,"PC transition fail");n_pc++;
   end
 endtask
 initial begin
   for(i=0;i<4;i++)model[i]=0;
   @(posedge clk);#1;rst_rf=0;rst_pc=0;hold=1;
   // Readable directed waves; only this prefix is recorded in VCD.
   rf_check(0,1,0,0,1,16'h1234);
   rf_check(0,0,0,0,1,16'hffff);
   rf_check(0,1,1,0,1,16'h00ff);
   rf_check(1,1,2,0,1,16'hbeef);
   rf_check(0,1,2,2,2,16'habcd);
   pc_check(1,1,1,16'h1234);
   pc_check(0,0,0,0);
   pc_check(0,1,0,0);
   pc_check(0,1,1,16'h0020);
   pc_check(0,0,1,16'hffff);
   pc_check(0,0,0,0);
   for(i=0;i<8;i++)begin
     case(i)
       0:alu_check(16'h1234,16'h00ff,0);
       1:alu_check(16'hffff,16'h0001,1);
       2:alu_check(16'h0000,16'h0001,2);
       3:alu_check(16'haaaa,16'h0f0f,3);
       4:alu_check(16'haaaa,16'h0f0f,4);
       5:alu_check(16'h7fff,16'h0001,1);
       6:alu_check(16'h002a,16'h002a,0);
       7:alu_check(16'h1234,16'hffff,7);
     endcase
     #9;
   end
   for(i=0;i<4;i++)begin imm=(i<2)?8'h80:8'hff;sign_mode=i%2;#10;end
   capture=0;#1;
   // Full 9-bit immediate input space.
   for(i=0;i<256;i++)for(j=0;j<2;j++)begin
     imm=i;sign_mode=j;#1;
     if(extended!==(j&&i>=128?16'(i+65280):16'(i)))$fatal(1,"IMM fail");n_imm++;
   end
   // ALU: all a with four b patterns and all 8 selectors, plus random pairs.
   for(i=0;i<65536;i++)for(j=0;j<4;j++)for(k=0;k<8;k++)begin
     case(j)0:b=0;1:b=16'hffff;2:b=i;3:b=~16'(i);endcase
     alu_check(i,b,k);
   end
   for(i=0;i<10000;i++)begin
     rng=nxt(rng);a=rng[15:0];rng=nxt(rng);b=rng[15:0];
     for(k=0;k<8;k++)alu_check(a,b,k);
   end
   // Every write-data value to every RF destination, plus all port combinations.
   for(i=0;i<4;i++)for(j=0;j<65536;j++)rf_check(0,1,i,i,(i+1)%4,j);
   for(i=0;i<4;i++)for(j=0;j<4;j++)for(k=0;k<4;k++)for(v=0;v<4;v++)
     rf_check(v[1],v[0],i,j,k,16'h5aa5^i);
   for(i=0;i<1000;i++)begin rng=nxt(rng);rf_check(rng[0],rng[1],rng[3:2],rng[5:4],rng[7:6],rng[23:8]);end
   // Every PC value x 8 control combinations, re-seeding by a legal redirect.
   for(i=0;i<65536;i++)for(j=0;j<8;j++)begin
     pc_check(0,0,1,i);
     pc_check(j[2],j[1],j[0],~16'(i));
   end
   // Absolute target: all immediate values. Relative: all offsets at six boundaries.
   relative=0;for(i=0;i<256;i++)begin imm=i;#1;if(bt!==16'(i))$fatal(1,"ABS target");n_target++;end
   relative=1;
   for(i=0;i<6;i++)for(j=0;j<256;j++)begin
     case(i)0:branch_pc=0;1:branch_pc=1;2:branch_pc=127;3:branch_pc=255;4:branch_pc=16'h7fff;5:branch_pc=16'hffff;endcase
     imm=j;#1;if(bt!==16'(int'(branch_pc)+1+(j>=128?j-256:j)))$fatal(1,"REL target");n_target++;
   end
   $display("PRE3_PASS imm=%0d alu=%0d rf_transactions=%0d pc_transitions=%0d targets=%0d",n_imm,n_alu,n_rf,n_pc,n_target);
   fd=$fopen("results.json","w");
   $fdisplay(fd,"{\"imm\":%0d,\"alu\":%0d,\"rf_transactions\":%0d,\"pc_transitions\":%0d,\"targets\":%0d,\"failures\":0}",n_imm,n_alu,n_rf,n_pc,n_target);
   $fclose(fd);$finish;
 end
endmodule
