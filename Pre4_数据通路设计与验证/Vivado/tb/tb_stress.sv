`timescale 1ns/1ps
// Independent supplemental audit oracle: execute the ISA at observed completion
// events, then compare ALL architectural state after every edge. No DUT decoder,
// ALU candidates, forwarding selections or production reference() are reused.
module tb_stress;
  reg clk=0, rst=1; always #5 clk=~clk;
  wire halted,fault; pre4_system dut(clk,rst,halted,fault);
  reg [15:0] image[0:255], memory[0:255], rf[0:3], fixture[0:3];
  reg z,c,v,fixture_z,fixture_c,fixture_v;
  integer rpc,cycles,completed,total_cases=0,total_completed=0;
  integer op_hits[0:15],fault_hits=0,taken_hits=0,not_taken_hits=0;
  integer signed_memory_cases=0,loop_cases=0,random_cases=0,branch_edge_cases=0;
  integer receipt_fd;
  reg [7:0] initial_flag_coverage=0;
  bit expected_halt,expected_fault,sampled_halt,sampled_fault;
  reg [31:0] rng=32'hA9D41009;
  string case_name;
  function automatic [31:0] next_rng(input [31:0] x);
    reg [31:0] t; begin t=x^(x<<13);t=t^(t>>17);next_rng=t^(t<<5);end
  endfunction
  function automatic integer sx8(input [7:0] x); sx8=x[7] ? integer'(x)-256 : integer'(x);endfunction
  function automatic integer sx16(input [15:0] x); sx16=x[15] ? integer'(x)-65536 : integer'(x);endfunction
  function automatic integer effective_address(input [15:0] word);
    effective_address=(integer'(rf[word[9:8]])+sx8(word[7:0])+65536)%65536;
  endfunction
  function automatic bit instruction_fault;
    integer oc,ea;begin
      instruction_fault=0;
      if(rpc<0 || rpc>255)instruction_fault=1;
      else begin
        oc=image[rpc][15:12];
        if(oc==11||oc==15)instruction_fault=1;
        if(oc==2||oc==3)begin ea=effective_address(image[rpc]);if(ea>255)instruction_fault=1;end
      end
    end
  endfunction
  task automatic fresh(input string label);
    begin
      case_name=label;@(negedge clk);rst=1;
      repeat(2)@(posedge clk);#1;
      for(integer k=0;k<4;k++)fixture[k]=0;
      fixture_z=0;fixture_c=0;fixture_v=0;
      for(integer k=0;k<256;k++)begin image[k]=16'hb000;memory[k]=(k*16'h103+16'ha55a)&16'hffff;end
    end
  endtask
  task automatic advance_nonstore;
    reg [15:0] word;integer oc,d,s,aa,bb,exact,exact_signed,ea,nextpc;
    bit expect_rw,expect_zw,expect_cvw;
    begin
      if(expected_halt||expected_fault||instruction_fault())$fatal(1,"unexpected normal WB %s pc=%h reference=%h",case_name,dut.core.w_pc,rpc);
      if(dut.core.w_pc!==16'(rpc))$fatal(1,"WB age mismatch %s got=%h reference=%h",case_name,dut.core.w_pc,rpc);
      word=image[rpc];oc=word[15:12];d=word[11:10];s=word[9:8];aa=rf[d];bb=rf[s];nextpc=(rpc+1)%65536;
      expect_rw=(oc<=2)||(oc>=4&&oc<=9);expect_zw=(oc==10);expect_cvw=(oc>=4&&oc<=7);
      if({dut.core.rf_we,dut.core.z_we,dut.core.cv_we}!=={expect_rw,expect_zw,expect_cvw})$fatal(1,"write intent %s pc=%h",case_name,rpc);
      if(dut.core.w_halt!==(oc==14)||dut.core.w_wb_sel!==(oc==2))$fatal(1,"WB type %s",case_name);
      case(oc)
        0:rf[d]=rf[s];
        1:rf[d]=word[7:0];
        2:begin ea=effective_address(word);rf[d]=memory[ea];end
        3:$fatal(1,"successful STR appeared in WB %s",case_name);
        4,5,6,7:begin
          if(oc==5||oc==7)bb=word[7:0];
          if(oc==4||oc==5)begin exact=aa+bb;exact_signed=sx16(16'(aa))+sx16(16'(bb));c=exact>65535;end
          else begin exact=aa-bb+65536;exact_signed=sx16(16'(aa))-sx16(16'(bb));c=aa>=bb;end
          rf[d]=exact%65536;v=(exact_signed < -32768 || exact_signed >32767);
        end
        8:rf[d]=rf[d]&rf[s];
        9:rf[d]=rf[d]|rf[s];
        10:z=(rf[d]==rf[s]);
        12:begin nextpc=word[7:0];taken_hits++;end
        13:begin if(z)begin nextpc=(rpc+1+sx8(word[7:0])+65536)%65536;taken_hits++;end else not_taken_hits++;end
        14:expected_halt=1;
        default:$fatal(1,"reference illegal normal WB");
      endcase
      if(expect_rw && (dut.core.w_rd!==2'(d)||dut.core.wb_data!==rf[d]))$fatal(1,"WB destination/value %s",case_name);
      rpc=nextpc;op_hits[oc]++;completed++;
    end
  endtask
  task automatic advance_store;
    reg [15:0] word;integer ea;begin
      if(expected_halt||expected_fault||instruction_fault()||image[rpc][15:12]!=3)$fatal(1,"unexpected store %s pc=%h ref=%h",case_name,dut.core.m_pc,rpc);
      word=image[rpc];ea=effective_address(word);
      if(dut.core.m_pc!==16'(rpc)||dut.dm_addr!==16'(ea)||dut.dm_din!==rf[word[11:10]]||dut.dm_en!==1)$fatal(1,"store PC/address/value %s",case_name);
      memory[ea]=rf[word[11:10]];rpc=(rpc+1)%65536;op_hits[3]++;completed++;
    end
  endtask
  task automatic execute;
    begin
      @(negedge clk);
      for(integer k=0;k<256;k++)begin dut.im.mem[k]=image[k];dut.dm.mem[k]=memory[k];end
      for(integer k=0;k<4;k++)begin rf[k]=fixture[k];dut.core.u_rf.regs[k]=fixture[k];end
      z=fixture_z;c=fixture_c;v=fixture_v;dut.core.u_flags.Z=z;dut.core.u_flags.C=c;dut.core.u_flags.V=v;
      initial_flag_coverage[{fixture_z,fixture_c,fixture_v}]=1'b1;
      rpc=0;cycles=0;completed=0;expected_halt=0;expected_fault=0;rst=0;
      while(!halted&&!fault&&cycles<1024)begin
        @(posedge clk);cycles++;sampled_halt=0;sampled_fault=0;
        // Retirement order is older WB then younger successful MEM STR.
        if(dut.core.w_valid)begin
          if(dut.core.w_fault)begin
            if(!instruction_fault()||dut.core.w_pc!==16'(rpc))$fatal(1,"spurious/wrong-age fault %s actual=%h expected=%h",case_name,dut.core.w_pc,rpc);
            if(dut.core.rf_we||dut.core.z_we||dut.core.cv_we)$fatal(1,"fault has write intent");
            expected_fault=1;sampled_fault=1;fault_hits++;
          end else begin advance_nonstore();sampled_halt=expected_halt;end
        end
        if(dut.dm_we)advance_store();
        if(dut.dm_en&&(dut.dm_addr>255))$fatal(1,"physical memory alias");
        if(dut.im_en&&(dut.im_addr>255))$fatal(1,"physical IM alias");
        #1;
        for(integer k=0;k<4;k++)if(dut.core.u_rf.regs[k]!==rf[k])$fatal(1,"RF edge mismatch %s cycle=%0d R%0d actual=%h expected=%h",case_name,cycles,k,dut.core.u_rf.regs[k],rf[k]);
        if({dut.core.u_flags.Z,dut.core.u_flags.C,dut.core.u_flags.V}!=={z,c,v})$fatal(1,"flags edge mismatch %s cycle=%0d",case_name,cycles);
        for(integer k=0;k<256;k++)if(dut.dm.mem[k]!==memory[k])$fatal(1,"memory edge mismatch %s cycle=%0d addr=%0d",case_name,cycles,k);
        if(halted!==sampled_halt||fault!==sampled_fault)$fatal(1,"exact stop edge mismatch %s",case_name);
        if((halted||fault)&&{dut.core.d_valid,dut.core.x_valid,dut.core.m_valid,dut.core.w_valid}!==0)$fatal(1,"nonempty stop");
      end
      if(cycles>=1024)$fatal(1,"stress timeout %s",case_name);
      repeat(3)begin
        @(posedge clk);if(dut.im_en||dut.dm_en||dut.dm_we||dut.core.rf_we||dut.core.z_we||dut.core.cv_we)$fatal(1,"stopped side effects");
        #1;if(halted!==expected_halt||fault!==expected_fault)$fatal(1,"stop did not hold");
      end
      total_cases++;total_completed+=completed;
    end
  endtask
  integer base,offset,kind,p,i,d,s,oc,target,count,bits;
  reg [15:0] bases[0:6];
  initial begin
    for(i=0;i<16;i++)op_hits[i]=0;
    bases[0]=0;bases[1]=1;bases[2]=127;bases[3]=128;bases[4]=255;bases[5]=256;bases[6]=16'hffff;
    // Every signed offset encoding at seven address boundaries, both LDR/STR.
    // Arithmetic older than the access must still complete if the access faults.
    for(base=0;base<7;base++)for(offset=0;offset<256;offset++)for(kind=0;kind<2;kind++)begin
      fresh($sformatf("EA_%0d_%0d_%0d",base,offset,kind));
      fixture[0]=16'hcafe;fixture[1]=16'hbeef;fixture[2]=16'h7fff;fixture[3]=bases[base];fixture_z=1;fixture_c=1;fixture_v=1;
      image[0]=16'h5801; // ADD R2,#1, yields C=0 V=1, preserves Z.
      image[1]=kind ? (16'h3300|offset) : (16'h2700|offset);
      image[2]=16'he000;image[3]=16'h31ff; // canceled young illegal-address store.
      execute();signed_memory_cases++;
    end
    // Structured bounded loops mix negative offsets, store/load, load RAW,
    // arithmetic->CMP, CMP->JZ, taken/not-taken and JUMP squash of illegal code.
    for(p=0;p<100;p++)begin
      fresh($sformatf("LOOP_%0d",p));rng=next_rng(rng);count=1+(rng%31);fixture[0]=count;fixture[3]=128;
      rng=next_rng(rng);fixture[2]=rng[15:0];offset=rng[23:16];fixture_c=rng[24];fixture_v=rng[25];fixture_z=rng[26];
      image[0]=16'h3b00|offset;image[1]=16'h2b00|offset;image[2]=16'h5801;image[3]=16'h3b00|offset;
      image[4]=16'h7001;image[5]=16'ha100;image[6]=16'hd002;image[7]=16'hc001;image[8]=16'hf000;image[9]=16'he000;image[10]=16'h33ff;
      execute();loop_cases++;
    end
    // 500 deterministic forward-branch programs: all legal arithmetic and both
    // branches, variable register dependencies, ignored fields, negative memory
    // offsets, and all initial Z/C/V states. No unbounded random loops.
    for(p=0;p<500;p++)begin
      fresh($sformatf("FLOW_%0d",p));fixture[3]=32;
      for(i=0;i<3;i++)begin rng=next_rng(rng);fixture[i]=rng[15:0];end
      fixture_z=rng[16];fixture_c=rng[17];fixture_v=rng[18];
      for(i=0;i<64;i++)begin
        rng=next_rng(rng);oc=rng%13;if(oc==11)oc=12;else if(oc==12)oc=13;
        d=(rng>>8)%3;s=(rng>>10)%4;bits=rng[23:16];
        if(oc==2||oc==3)begin s=3;bits=(integer'(rng[7:0])%64)-32;end
        if(oc==12||oc==13)begin target=i+1+(rng%(64-i));bits=(oc==12)?target:target-i-1;end
        image[i]=16'((oc<<12)|(d<<10)|(s<<8)|(bits&255));
      end
      image[64]=16'he000;execute();random_cases++;
    end
    // All JZ immediates at PC=0 and PC=128. The -1 self-loop is deliberately
    // exercised not-taken; a taken self-loop has no finite stop by ISA design.
    for(kind=0;kind<2;kind++)for(offset=0;offset<256;offset++)begin
      fresh($sformatf("JZ_EDGE_%0d_%0d",kind,offset));
      for(i=0;i<256;i++)image[i]=16'he000;
      fixture_z=(offset!=255);fixture_c=1;fixture_v=1;
      if(kind==0)image[0]=16'hd000|offset;
      else begin image[0]=16'hc080;image[128]=16'hd000|offset;end
      execute();branch_edge_cases++;
    end
    for(i=0;i<16;i++)if(i!=11&&i!=15&&op_hits[i]==0)$fatal(1,"missing legal opcode %0d",i);
    if(initial_flag_coverage!==8'hff)$fatal(1,"missing initial flag state");
    if(total_cases!=4696 || signed_memory_cases!=3584 || loop_cases!=100 || random_cases!=500 || branch_edge_cases!=512)$fatal(1,"stress coverage count");
    receipt_fd=$fopen("stress_results.json","w");
    if(!receipt_fd)$fatal(1,"cannot write stress_results.json");
    $fdisplay(receipt_fd,"{\"status\":\"PASS\",\"failures\":0,\"spec_version\":\"1.4\",\"seed\":\"A9D41009\",\"cases\":%0d,\"memory_offset_boundary\":%0d,\"loops\":%0d,\"random_control_flow\":%0d,\"branch_offset_edges\":%0d,\"completed\":%0d,\"fault_tokens\":%0d,\"taken\":%0d,\"not_taken\":%0d,\"initial_flag_states\":8,\"legal_opcode_coverage\":14,\"oracle\":\"independent retirement-driven ISA scoreboard, all RF/flags/256-word DM checked after each edge\",\"scope\":\"all signed imm8 encodings at seven memory bases for LDR/STR; 100 bounded loops 1..31 iterations; 500 64-word acyclic forward-branch programs; 512 JZ edge cases at PC0/128, taken -1 self-loop excluded by forcing Z=0; not exhaustive CPU state space\"}",total_cases,signed_memory_cases,loop_cases,random_cases,branch_edge_cases,total_completed,fault_hits,taken_hits,not_taken_hits);
    $fclose(receipt_fd);
    $display("STRESS_PASS cases=%0d memory_offset_boundary=%0d loops=%0d random_control_flow=%0d branch_offset_edges=%0d completed=%0d fault_tokens=%0d taken=%0d not_taken=%0d legal_opcodes=14/14 failures=0 seed=A9D41009",total_cases,signed_memory_cases,loop_cases,random_cases,branch_edge_cases,total_completed,fault_hits,taken_hits,not_taken_hits);
    $finish;
  end
endmodule
