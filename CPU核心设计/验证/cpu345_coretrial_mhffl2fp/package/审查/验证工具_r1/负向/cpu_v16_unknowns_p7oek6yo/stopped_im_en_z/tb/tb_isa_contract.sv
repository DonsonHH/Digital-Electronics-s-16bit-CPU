`timescale 1ns/1ps
// Independent approved v1.5 control contract, covering all binary words.
// Decoder agreement and directed ALU checks are not full CPU validation.
module tb_isa_contract;
  reg [15:0] inst=0;
  wire [1:0] rd,rs,asel,bsel;
  wire [7:0] imm;
  wire ur,us,signmode,rw,mr,mw,zw,cvw,wb,ja,jz,halt,bad;
  wire [2:0] aluop;
  isa_decode dut(.inst(inst),.rd(rd),.rs(rs),.imm(imm),
    .use_rd(ur),.use_rs(us),.alu_a_sel(asel),.alu_b_sel(bsel),
    .alu_op(aluop),.imm_signed(signmode),.reg_write(rw),
    .mem_read(mr),.mem_write(mw),.z_write(zw),.cv_write(cvw),
    .wb_sel(wb),.jump_abs(ja),.jump_z(jz),.halt(halt),.illegal(bad));
  wire [19:0] actual={ur,us,asel,bsel,aluop,signmode,rw,mr,mw,zw,cvw,wb,ja,jz,halt,bad};

  function automatic [19:0] target(input [3:0] opcode);
    reg eur,eus,es,erw,emr,emw,ez,ecv,ew,ej,ejz,eh,ei;
    reg [1:0] ea,eb;
    reg [2:0] eo;
    begin
      eur=0;eus=0;es=0;erw=0;emr=0;emw=0;ez=0;ecv=0;
      ew=0;ej=0;ejz=0;eh=0;ei=0;ea=0;eb=0;eo=0;
      case(opcode)
        0:begin eus=1;eb=1;erw=1;end
        1:begin eb=2;erw=1;end
        2:begin eur=1;eus=1;ea=1;eb=1;eo=3;erw=1;end
        3:begin eur=1;eus=1;ea=1;eb=1;eo=4;erw=1;end
        4:begin eur=1;eus=1;ea=1;eb=1;eo=1;erw=1;ecv=1;end
        5:begin eur=1;ea=1;eb=2;eo=1;erw=1;ecv=1;end
        6:begin eur=1;eus=1;ea=1;eb=1;eo=2;erw=1;ecv=1;end
        7:begin eur=1;ea=1;eb=2;eo=2;erw=1;ecv=1;end
        8:begin eus=1;ea=2;eb=2;eo=1;es=1;erw=1;emr=1;ew=1;end
        9:begin eur=1;eus=1;ea=2;eb=2;eo=1;es=1;emw=1;end
        10:begin eur=1;eus=1;ea=1;eb=1;ez=1;end
        12:ej=1;
        13:begin es=1;ejz=1;end
        14:eh=1;
        default:ei=1;
      endcase
      target={eur,eus,ea,eb,eo,es,erw,emr,emw,ez,ecv,ew,ej,ejz,eh,ei};
    end
  endfunction

  reg [15:0] a=0,b=0;
  reg [2:0] op=0;
  wire [15:0] result;
  wire eq,illegal,carry,overflow;
  alu16 alu(.a(a),.b(b),.op(op),.result(result),.eq(eq),
    .illegal(illegal),.carry(carry),.overflow(overflow));
  integer alu_checks=0;
  task automatic alu_vector(input [15:0] x,y,input [2:0] fn,
      input [15:0] er,input ec,ev,ei);
    begin
      a=x;b=y;op=fn;#1;
      if({result,carry,overflow,illegal,eq} !== {er,ec,ev,ei,(x==y)})
        $fatal(1,"ALU boundary mismatch a=%h b=%h op=%d",x,y,fn);
      alu_checks++;
    end
  endtask

  integer i,matched=0,mismatched=0;
  integer mismatch_by_opcode[0:15];
  integer fd;
  initial begin
    for(i=0;i<16;i++)mismatch_by_opcode[i]=0;
    for(i=0;i<65536;i++)begin
      inst=i;#1;
      if({rd,rs,imm} !== {inst[11:10],inst[9:8],inst[7:0]})
        $fatal(1,"Raw field extraction mismatch %h",inst);
      if(actual !== target(inst[15:12]))begin
        mismatched++;
        mismatch_by_opcode[inst[15:12]]++;
      end else matched++;
    end
    if(matched!=65536 || mismatched!=0)$fatal(1,"ISA v1.5 contract mismatch");
    for(i=0;i<16;i++)begin
      if(mismatch_by_opcode[i]!=0)$fatal(1,"Opcode contract mismatch %h",i);
    end
    alu_vector(16'hffff,16'h0001,1,16'h0000,1,0,0);
    alu_vector(16'h7fff,16'h0001,1,16'h8000,0,1,0);
    alu_vector(16'h8000,16'h8000,1,16'h0000,1,1,0);
    alu_vector(16'h0005,16'h0003,2,16'h0002,1,0,0);
    alu_vector(16'h0000,16'h0001,2,16'hffff,0,0,0);
    alu_vector(16'h8000,16'h0001,2,16'h7fff,1,1,0);
    alu_vector(16'h7fff,16'hffff,2,16'h8000,0,1,0);
    alu_vector(16'h1234,16'h1234,2,16'h0000,1,0,0);
    alu_vector(16'h1234,16'h00ff,0,16'h00ff,0,0,0);
    alu_vector(16'ha5a5,16'h0f0f,3,16'h0505,0,0,0);
    alu_vector(16'ha500,16'h00a5,4,16'ha5a5,0,0,0);
    alu_vector(16'h1234,16'h1234,5,16'h0000,0,0,1);
    alu_vector(16'h0000,16'h0001,6,16'h0000,0,0,1);
    alu_vector(16'hffff,16'hffff,7,16'h0000,0,0,1);
    $display("ISA_CONTRACT_PASS words=65536 mismatches=0");
    $display("ALU_BOUNDARY_PASS checks=%0d scope=directed_not_exhaustive",alu_checks);
    fd=$fopen("isa_contract_results.json","w");
    if(fd==0)$fatal(1,"Cannot write audit receipt");
    $fdisplay(fd,"{\"scope\":\"approved binary decoder contract and directed ALU checks, not exhaustive CPU validation\",\"status\":\"PASS\",\"spec_version\":\"1.6\",\"decode_words_checked\":65536,\"compatible\":%0d,\"incompatible\":%0d,\"alu_directed_checks\":%0d}",matched,mismatched,alu_checks);
    $fclose(fd);
    $finish;
  end
endmodule
