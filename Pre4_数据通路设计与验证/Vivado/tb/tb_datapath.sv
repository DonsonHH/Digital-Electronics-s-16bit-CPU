`timescale 1ns/1ps
module tb_datapath;
 reg clk=0,rst=1;always #5 clk=~clk;
 wire halted,fault;pre4_system dut(clk,rst,halted,fault);
 reg [15:0] initial_r[0:3],expected_r[0:3],expected_dm[0:255];
 reg initial_z,initial_c,initial_v,expected_z,expected_c,expected_v;
 reg [15:0] ref_pc,ins,a,b,imm,rslt;
 integer step,op,rd,rs,addr,wide,sa,sb,signed_result,ref_n,expected_fault,expected_halt;
 integer event_pc[0:511],event_op[0:511],event_rd[0:511],event_data[0:511],event_addr[0:511];
 reg event_z[0:511],event_c[0:511],event_v[0:511];
 integer seen,cycles,stalls,redirects,total_cases=0,total_retired=0;
 integer instr_count[0:15];
 integer i,j,fd,tracefd,timingfd;
 string name,generated_label;
 bit run_case=0;
 bit saw_fetch_fault,pre_mem_fault,pre_w_halt,pre_w_fault;
 reg [2:0] pre_mode;
 reg [15:0] pre_fetch_pc,pre_im_dout;
 reg [15:0] witness_required,witness_seen,witness_pending;
 integer reset_probes=0;
 reg [15:0] reset_dm[0:255];
 reg [31:0] random_state=32'h20261008;
 function automatic [31:0] nxt(input [31:0] x);reg [31:0]t;begin t=x^(x<<13);t=t^(t>>17);nxt=t^(t<<5);end endfunction
 task automatic clear_case(input string label);
  begin
   // Copy dynamic labels before a timing yield. Older XSim releases can
   // mishandle temporary string expressions retained across task delays.
   name=label;
   @(negedge clk);rst=1;run_case=0;
   repeat(2)@(posedge clk);#1;
   if(dut.core.PC_fetch!==0||{dut.core.u_flags.Z,dut.core.u_flags.C,dut.core.u_flags.V}!==0||dut.core.mode!==0||dut.core.d_valid||dut.core.x_valid||dut.core.m_valid||dut.core.w_valid||halted||fault)$fatal(1,"Case reset state");
   for(integer k=0;k<256;k++)begin dut.im.mem[k]=16'hb000;dut.dm.mem[k]=0;end
   for(integer k=0;k<4;k++)initial_r[k]=0;
   initial_z=0;initial_c=0;initial_v=0;
  end
 endtask
 task automatic load(input integer pos,input [15:0] word);dut.im.mem[pos]=word;endtask
 task automatic reference;
  begin
   for(integer k=0;k<4;k++)expected_r[k]=initial_r[k];
   for(integer k=0;k<256;k++)expected_dm[k]=dut.dm.mem[k];
   expected_z=initial_z;expected_c=initial_c;expected_v=initial_v;
   ref_pc=0;ref_n=0;expected_fault=0;expected_halt=0;
   for(step=0;step<500 && !expected_fault && !expected_halt;step++)begin
    if(ref_pc>255)expected_fault=1;
    else begin
     ins=dut.im.mem[ref_pc];op=ins[15:12];rd=ins[11:10];rs=ins[9:8];a=expected_r[rd];b=expected_r[rs];
     imm=(op==2||op==3||op==13)?16'($signed(ins[7:0])):{8'h00,ins[7:0]};
     event_pc[ref_n]=ref_pc;event_op[ref_n]=op;event_rd[ref_n]=rd;event_data[ref_n]=0;event_addr[ref_n]=0;
     rslt=0;
     case(op)
      0:expected_r[rd]=b;
      1:expected_r[rd]=imm;
      2,3:begin
       // Keep an unsigned 0..65535 integer for range checking. A signed
       // sized cast assigned to integer would turn FFFF into -1 and index
       // the reference array incorrectly, masking an out-of-range access.
       addr=(int'(b)+int'(imm)) & 32'h0000ffff;
       if(addr>255)expected_fault=1;
       else if(op==2)expected_r[rd]=expected_dm[addr];
       else begin expected_dm[addr]=a;event_addr[ref_n]=addr;event_data[ref_n]=a;end
      end
      4,5,6,7:begin
       if(op==5||op==7)b=imm;
       sa=$signed(a);sb=$signed(b);
       if(op==4||op==5)begin wide=int'(a)+int'(b);signed_result=sa+sb;expected_c=wide>65535;end
       else begin wide=int'(a)+65536-int'(b);signed_result=sa-sb;expected_c=a>=b;end
       expected_r[rd]=16'(wide);expected_v=(signed_result>32767 || signed_result< -32768);
      end
      8:expected_r[rd]=a&b;
      9:expected_r[rd]=a|b;
      10:expected_z=(a==b);
      12:ref_pc={8'h00,ins[7:0]}-16'd1;
      13:if(expected_z)ref_pc=ref_pc+imm;
      14:expected_halt=1;
      default:expected_fault=1;
     endcase
     if(!expected_fault)begin
      if(op!=3)event_data[ref_n]=expected_r[rd];
      event_z[ref_n]=expected_z;event_c[ref_n]=expected_c;event_v[ref_n]=expected_v;
      ref_n++;ref_pc=ref_pc+16'd1;
     end
    end
   end
   if(!expected_fault&&!expected_halt)$fatal(1,"Reference timeout %s",name);
  end
 endtask
 task automatic run_program(input integer expected_cycles,input integer expected_stalls);
  reg saved_halted,saved_fault;
  reg [2:0] saved_stop_mode;
  begin
   reference();
   @(negedge clk);
   for(integer k=0;k<4;k++)dut.core.u_rf.regs[k]=initial_r[k];
   dut.core.u_flags.Z=initial_z;dut.core.u_flags.C=initial_c;dut.core.u_flags.V=initial_v;
   rst=0;cycles=0;seen=0;stalls=0;redirects=0;run_case=1;saw_fetch_fault=0;
   $fdisplay(timingfd,"%s,%0t",name,$time);
   // Each named timing assertion must have a real witness, rather than
   // silently passing because a guarded condition was never reached.
   witness_required=0;witness_seen=0;witness_pending=0;
   if(expected_halt)witness_required[0]=1;
   if(expected_fault)witness_required[1]=1;
   if(name=="T05"||name=="T17a"||name=="T17b")witness_required[2]=1;
   if(name=="T07")witness_required[3]=1;
   if(name=="T08")witness_required[4]=1;
   if(name=="T16")witness_required[5]=1;
   if(name=="T17a"||name=="T17b")witness_required[6]=1;
   if(name=="T18a"||name=="T18b")witness_required[7]=1;
   if(name=="T18a")witness_required[8]=1;
   if(name=="T18b")witness_required[9]=1;
   if(name=="LEGAL_STR_BEFORE_EX_FAULT")witness_required[10]=1;
   if(name=="MEM_FAULT_OVER_REDIRECT")witness_required[11]=1;
   if(name=="NEWEST_M_OVER_W")witness_required[12]=1;
   if(name=="LOAD_MOV_NO_FALSE_STALL")witness_required[13]=1;
   if(name=="LOAD_STR_BASE")begin witness_required[14]=1;witness_required[15]=1;end
   while(!halted&&!fault&&cycles<250)begin
    @(posedge clk);cycles++;
    // Compare side-effect events in age order: older WB, then successful MEM STR.
    if(dut.core.w_valid&&!dut.core.w_fault)begin
     if(seen>=ref_n||dut.core.w_pc!==16'(event_pc[seen]))$fatal(1,"Event mismatch %s WBpc=%h index=%0d refpc=%0d",name,dut.core.w_pc,seen,event_pc[seen]);
     if(dut.core.rf_we !== (event_op[seen]==0||event_op[seen]==1||event_op[seen]==2||(event_op[seen]>=4&&event_op[seen]<=9)))$fatal(1,"RW mask %s",name);
     if(dut.core.z_we !== (event_op[seen]==10))$fatal(1,"ZW mask %s",name);
     if(dut.core.cv_we !== (event_op[seen]>=4&&event_op[seen]<=7))$fatal(1,"CVW mask %s",name);
     if(dut.core.w_halt !== (event_op[seen]==14))$fatal(1,"HALT token mask %s",name);
     if(dut.core.w_wb_sel !== (event_op[seen]==2))$fatal(1,"WB select mask %s",name);
     if(dut.core.rf_we&&dut.core.w_rd!==2'(event_rd[seen]))$fatal(1,"WB destination %s",name);
     if(dut.core.rf_we && dut.core.wb_data!==16'(event_data[seen]))$fatal(1,"WBdata %s pc=%h",name,dut.core.w_pc);
     if(dut.core.z_we && dut.core.w_cmp_z!==event_z[seen])$fatal(1,"Z candidate %s",name);
     if(dut.core.cv_we && {dut.core.w_c,dut.core.w_v}!=={event_c[seen],event_v[seen]})$fatal(1,"CV candidate %s",name);
     instr_count[event_op[seen]]++;seen++;
    end
    if(dut.dm_we)begin
     if(seen>=ref_n||event_op[seen]!=3||dut.core.m_pc!==16'(event_pc[seen])||dut.dm_addr!==16'(event_addr[seen])||dut.dm_din!==16'(event_data[seen]))$fatal(1,"Store event mismatch %s",name);
     instr_count[3]++;seen++;
    end
    if(dut.core.load_use)stalls++;
    if(dut.core.qualified_redirect)redirects++;
    pre_mem_fault=dut.core.m_fault_event;pre_w_halt=dut.core.w_valid&&dut.core.w_halt&&!dut.core.w_fault;pre_w_fault=dut.core.w_valid&&dut.core.w_fault;
    pre_mode=dut.core.mode;pre_fetch_pc=dut.core.PC_fetch;pre_im_dout=dut.im_dout;
    witness_pending=0;
    if(pre_w_halt&&pre_mode!==3'd1)$fatal(1,"HALT token outside DRAIN_HALT %s",name);
    if(pre_w_fault&&pre_mode!==3'd2)$fatal(1,"Fault token outside DRAIN_FAULT %s",name);
    if(pre_w_fault&&(!expected_fault||dut.core.w_pc!==ref_pc||seen!=ref_n))$fatal(1,"Fault PC or retirement age mismatch %s got=%h expected=%h",name,dut.core.w_pc,ref_pc);
    if(pre_w_fault&&(dut.core.rf_we||dut.core.z_we||dut.core.cv_we))$fatal(1,"Fault token has write intent %s",name);
    if(pre_mem_fault&&(dut.dm_en||dut.dm_we||dut.core.qualified_redirect||dut.core.qualified_halt))$fatal(1,"MEM age/guard %s",name);
    if(dut.im_addr>255&&dut.im_en)$fatal(1,"Fetch range guard %s",name);
    if(dut.core.d_valid&&dut.core.d_fetch_fault&&dut.core.d_pc==16'h0100)begin saw_fetch_fault=1;witness_seen[7]=1;end
    if(name=="T05"&&cycles==5)begin
     if(dut.core.m_valid!==1||dut.core.m_pc!==16'h0001||dut.core.m_mem_read!==1||pre_mem_fault!==1||dut.dm_addr!==16'h0100||dut.core.w_valid!==1||dut.core.w_pc!==16'h0000||dut.core.rf_we!==1||dut.core.cv_we!==1||dut.core.wb_data!==16'h8000||{dut.core.w_c,dut.core.w_v}!==2'b01)$fatal(1,"T05 MEM fault and older WB witness");
     witness_pending[2]=1;
    end
    if(name=="T07"&&cycles==5)begin
     if(dut.core.m_valid!==1||dut.core.m_halt!==1||dut.core.m_pc!==16'h0001||dut.core.w_valid!==1||dut.core.w_pc!==16'h0000||dut.core.rf_we!==1||dut.core.wb_data!==16'h1234||halted!==0)$fatal(1,"T07 HALT MEM with older load WB witness");
     witness_pending[3]=1;
    end
    if(name=="T08"&&cycles==5)begin
     if(dut.core.load_use!==1||dut.core.x_valid!==1||dut.core.x_pc!==16'h0002||dut.core.d_valid!==1||dut.core.d_pc!==16'h0003||dut.core.w_valid!==1||dut.core.w_pc!==16'h0000||dut.core.cv_we!==1)$fatal(1,"T08 stall with older flag WB witness");
     witness_pending[4]=1;
    end
    if(name=="T16"&&cycles==4)begin
     if(pre_mem_fault!==1||dut.core.m_pc!==16'h0000||dut.core.x_valid!==1||dut.core.x_pc!==16'h0001||dut.core.x_halt!==1||dut.core.qualified_halt!==0)$fatal(1,"T16 older MEM fault defeats EX HALT witness");
     witness_pending[5]=1;
    end
    if((name=="T17a"||name=="T17b")&&cycles==5)begin
     if(pre_mem_fault!==1||dut.core.m_valid!==1||dut.core.m_pc!==16'h0001||dut.core.m_mem_write!==1||dut.dm_en!==0||dut.dm_we!==0||dut.core.w_valid!==1||dut.core.w_pc!==16'h0000||dut.core.rf_we!==1)$fatal(1,"T17 fault STR blocked with older WB witness %s",name);
     if(dut.dm_addr!==(name=="T17a"?16'h0100:16'hffff))$fatal(1,"T17 full EA %s",name);
     witness_pending[2]=1;witness_pending[6]=1;
    end
    if(name=="T18a"&&cycles==7)begin
     if(dut.core.x_valid!==1||dut.core.x_pc!==16'h0100||dut.core.x_fault!==1||dut.core.x_fault_event!==1||dut.core.m_valid!==1||dut.core.m_pc!==16'h00ff)$fatal(1,"T18a correct-path fetch fault EX witness");
     witness_pending[8]=1;
    end
    if(name=="T18b"&&dut.core.x_valid&&dut.core.x_pc==16'h0100)$fatal(1,"T18b canceled fetch fault reached valid EX");
    if(name=="T18b"&&cycles==6)begin
     if(dut.core.x_valid!==1||dut.core.x_pc!==16'h00ff||dut.core.d_valid!==1||dut.core.d_pc!==16'h0100||dut.core.d_fetch_fault!==1||dut.core.qualified_redirect!==1||dut.core.branch_target!==16'h0002)$fatal(1,"T18b older branch cancels fetch fault witness");
     witness_pending[9]=1;
    end
    if(name=="LEGAL_STR_BEFORE_EX_FAULT"&&cycles==4)begin
     if(dut.dm_we!==1||dut.core.m_pc!==0||dut.core.x_fault_event!==1||dut.core.x_pc!==1)$fatal(1,"Older legal STR with EX fault witness");
     witness_pending[10]=1;
    end
    if(name=="MEM_FAULT_OVER_REDIRECT"&&cycles==4)begin
     if(pre_mem_fault!==1||dut.core.branch_req!==1||dut.core.x_pc!==1||dut.core.qualified_redirect!==0)$fatal(1,"Older MEM fault defeats EX branch witness");
     witness_pending[11]=1;
    end
    if(name=="NEWEST_M_OVER_W"&&cycles==5)begin
     if(dut.core.x_pc!==2||dut.core.m_pc!==1||dut.core.w_pc!==0||dut.core.rs_fwd_sel!==2'd1||dut.core.rs_fwd!==16'h0002)$fatal(1,"Nearest M beats older W witness");
     witness_pending[12]=1;
    end
    if(name=="LOAD_MOV_NO_FALSE_STALL"&&cycles==3)begin
     if(dut.core.x_mem_read!==1||dut.core.x_pc!==0||dut.core.d_pc!==1||dut.core.d_use_rd!==0||dut.core.d_use_rs!==0||dut.core.load_use!==0)$fatal(1,"No false load-MOV stall witness");
     witness_pending[13]=1;
    end
    if(name=="LOAD_STR_BASE"&&cycles==3)begin
     if(dut.core.load_use!==1||dut.core.d_use_rs!==1||dut.core.d_rs!==0)$fatal(1,"Load-STR base stall witness");
     witness_pending[14]=1;
    end
    if(name=="LOAD_STR_BASE"&&cycles==5)begin
     if(dut.core.x_valid!==1||dut.core.x_pc!==1||dut.core.w_valid!==1||dut.core.w_pc!==0||dut.core.rs_fwd_sel!==2'd2||dut.core.rs_fwd!==16'h0021||dut.core.x_store_data!==16'hbeef)$fatal(1,"Load-STR base WB forward witness");
     witness_pending[15]=1;
    end
    if(name=="BASELINE")$fdisplay(tracefd,"%0d,%04h,%b,%04h,%b,%04h,%b,%04h,%b,%04h,%b,%b,%b,%b,%04h,%04h,%b,%b,%b",cycles,dut.im_addr,dut.core.d_valid,dut.core.d_pc,dut.core.x_valid,dut.core.x_pc,dut.core.m_valid,dut.core.m_pc,dut.core.w_valid,dut.core.w_pc,dut.core.load_use,dut.core.qualified_redirect,dut.dm_en,dut.dm_we,dut.dm_addr,dut.dm_din,dut.core.u_flags.Z,dut.core.u_flags.C,dut.core.u_flags.V);
    #1;
    if(pre_mem_fault&&dut.core.mode!=3'd2)$fatal(1,"MEM fault must enter DRAIN_FAULT %s",name);
    if(pre_w_halt)begin
     if({halted,fault}!==2'b10||dut.core.mode!==3'd3)$fatal(1,"HALT not at exact WB edge %s",name);
     witness_seen[0]=1;
    end else if(pre_w_fault)begin
     if({halted,fault}!==2'b01||dut.core.mode!==3'd4)$fatal(1,"Fault not at exact WB edge %s",name);
     witness_seen[1]=1;
    end else if({halted,fault}!==2'b00)$fatal(1,"Stopped before a valid WB stop token %s",name);
    if((halted||fault)&&({dut.core.d_valid,dut.core.x_valid,dut.core.m_valid,dut.core.w_valid}!==4'b0000))$fatal(1,"Stop before empty %s",name);
    if(witness_pending[2])begin
     if(dut.core.w_valid!==1||dut.core.w_fault!==1||dut.core.w_pc!==16'h0001)$fatal(1,"MEM fault token must reach valid WB %s",name);
     if(name=="T05"||name=="T17a")begin
      if(dut.core.u_rf.regs[0]!==16'h8000||{dut.core.C,dut.core.V}!==2'b01)$fatal(1,"Older arithmetic WB lost under MEM fault %s",name);
     end else if(dut.core.u_rf.regs[0]!==16'h0001)$fatal(1,"Older MOV WB lost under MEM fault %s",name);
    end
    if(witness_pending[3]&&(dut.core.u_rf.regs[1]!==16'h1234||dut.core.w_valid!==1||dut.core.w_halt!==1||halted!==0))$fatal(1,"HALT stopped early or blocked older load");
    if(witness_pending[4]&&(dut.core.d_valid!==1||dut.core.d_pc!==16'h0003||dut.core.x_valid!==0||dut.core.m_valid!==1||dut.core.m_pc!==16'h0002||dut.core.PC_fetch!==pre_fetch_pc||dut.im_dout!==pre_im_dout||{dut.core.C,dut.core.V}!==2'b01))$fatal(1,"T08 interlock must hold frontend only, preserve older WB");
    if(witness_pending[5]&&(dut.core.mode!==3'd2||dut.core.m_valid!==0||dut.core.w_valid!==1||dut.core.w_fault!==1||dut.core.w_pc!==0))$fatal(1,"T16 HALT must be canceled by older fault");
    if(witness_pending[6]&&(dut.core.w_reg_write!==0||dut.core.w_z_write!==0||dut.core.w_cv_write!==0))$fatal(1,"Fault STR WB token has write intent");
    if(witness_pending[8]&&(dut.core.mode!==3'd2||dut.core.m_valid!==1||dut.core.m_fault!==1||dut.core.m_pc!==16'h0100||dut.core.w_valid!==1||dut.core.w_pc!==16'h00ff))$fatal(1,"T18a older MOV must remain ahead of fetch fault");
    if(witness_pending[9]&&(dut.core.PC_fetch!==16'h0002||dut.core.d_valid!==0||dut.core.x_valid!==0||dut.core.mode!==0))$fatal(1,"T18b redirect must cancel young fault without draining");
    if(witness_pending[10]&&(dut.dm.mem[32]!==16'hcafe||dut.core.mode!==3'd2||dut.core.w_valid!==0||dut.core.m_valid!==1||dut.core.m_fault!==1))$fatal(1,"EX fault must preserve older legal STR");
    if(witness_pending[11]&&(dut.core.mode!==3'd2||dut.core.PC_fetch!==pre_fetch_pc||dut.core.m_valid!==0))$fatal(1,"MEM fault must cancel branch movement");
    witness_seen=witness_seen|witness_pending;
   end
   if(cycles>=250)$fatal(1,"RTL timeout %s",name);
   if(halted!==1'(expected_halt)||fault!==1'(expected_fault)||seen!=ref_n)$fatal(1,"Stop/event count mismatch %s seen=%0d expected=%0d",name,seen,ref_n);
   for(integer k=0;k<4;k++)if(dut.core.u_rf.regs[k]!==expected_r[k])$fatal(1,"Final RF %s R%0d got=%h expected=%h",name,k,dut.core.u_rf.regs[k],expected_r[k]);
   if({dut.core.u_flags.Z,dut.core.u_flags.C,dut.core.u_flags.V}!=={expected_z,expected_c,expected_v})$fatal(1,"Final flags %s",name);
   for(integer k=0;k<256;k++)if(dut.dm.mem[k]!==expected_dm[k])$fatal(1,"Final DM %s addr=%0d",name,k);
   if(expected_cycles>=0&&cycles!=expected_cycles)$fatal(1,"Cycle %s got=%0d expected=%0d",name,cycles,expected_cycles);
   if(expected_stalls>=0&&stalls!=expected_stalls)$fatal(1,"Stall %s got=%0d expected=%0d",name,stalls,expected_stalls);
   if((name=="T18a"||name=="T18b")&&!saw_fetch_fault)$fatal(1,"Fetch fault tag never observed %s",name);
   if((witness_seen&witness_required)!==witness_required)$fatal(1,"Missing timing witness %s seen=%h required=%h",name,witness_seen,witness_required);
   saved_halted=halted;saved_fault=fault;saved_stop_mode=dut.core.mode;
   repeat(3)begin
    @(posedge clk);if(dut.im_en||dut.dm_en||dut.core.rf_we||dut.core.z_we||dut.core.cv_we)$fatal(1,"Side effect after stop %s",name);
    #1;if({halted,fault}!=={saved_halted,saved_fault}||dut.core.mode!==saved_stop_mode||{dut.core.d_valid,dut.core.x_valid,dut.core.m_valid,dut.core.w_valid}!==0)$fatal(1,"Stop state did not hold %s",name);
   end
   total_cases++;total_retired+=seen;
   $display("CASE_PASS %s cycles=%0d retired=%0d stalls=%0d redirects=%0d RF=%h/%h/%h/%h ZCV=%b%b%b halt=%b fault=%b",name,cycles,seen,stalls,redirects,expected_r[0],expected_r[1],expected_r[2],expected_r[3],expected_z,expected_c,expected_v,halted,fault);
   $fdisplay(fd,"%s,%0d,%0d,%0d,%0d,%b,%b,%04h,%04h",name,cycles,seen,stalls,redirects,halted,fault,witness_seen,witness_required);
   run_case=0;
  end
 endtask
 task automatic reset_probe(input integer phase,input bit fault_sequence);
  string reset_label;
  reg [2:0] reset_old_mode;
  bit reset_pending_store;
  begin
   reset_label=$sformatf("T09_fault%0d_phase_%0d",fault_sequence,phase);
   clear_case(reset_label);
   if(fault_sequence)begin load(0,'h1001);load(1,'hb000);load(2,'he000);end
   else begin load(0,'h1020);load(1,'h1405);load(2,'h3400);load(3,'h2800);load(4,'ha200);load(5,'he000);end
   dut.dm.mem[255]=16'hcafe;
   @(negedge clk);
   // Nonzero fixture state makes reset clearing observable even when the
   // short program has not yet written every architectural field.
   dut.core.u_rf.regs[3]=16'h55aa;
   dut.core.u_flags.Z=1;dut.core.u_flags.C=1;dut.core.u_flags.V=1;
   rst=0;
   repeat(phase)@(posedge clk);
   @(negedge clk);
   reset_old_mode=dut.core.mode;
   reset_pending_store=dut.core.m_valid&&dut.core.m_mem_write&&!dut.core.m_fault;
   if(!fault_sequence&&phase==5&&!reset_pending_store)$fatal(1,"T09 pending MEM store witness absent");
   if(!fault_sequence&&phase==6&&dut.dm.mem[32]!==16'h0005)$fatal(1,"T09 already completed store witness absent");
   if(fault_sequence&&phase<6&&reset_old_mode!==3'd2)$fatal(1,"T09 DRAIN_FAULT witness absent");
   if(fault_sequence&&phase==6&&reset_old_mode!==3'd4)$fatal(1,"T09 FAULTED witness absent");
   for(integer k=0;k<256;k++)reset_dm[k]=dut.dm.mem[k];
   rst=1;#1;
   if(dut.im_en||dut.dm_en||dut.dm_we||dut.core.rf_we||dut.core.z_we||dut.core.cv_we)$fatal(1,"Reset qualification");
   @(posedge clk);#1;
   for(integer k=0;k<4;k++)if(dut.core.u_rf.regs[k]!==0)$fatal(1,"Reset RF");
   for(integer k=0;k<256;k++)if(dut.dm.mem[k]!==reset_dm[k])$fatal(1,"Reset DM write");
   if(dut.core.PC_fetch!==0||{dut.core.u_flags.Z,dut.core.u_flags.C,dut.core.u_flags.V}!==0||dut.core.mode!==0||dut.core.d_valid||dut.core.x_valid||dut.core.m_valid||dut.core.w_valid||halted||fault)$fatal(1,"Reset state");
   reset_probes++;
   $display("RESET_PASS fault_sequence=%0d phase=%0d old_mode=%0d pending_store=%b",fault_sequence,phase,reset_old_mode,reset_pending_store);
  end
 endtask
 initial begin
  for(i=0;i<16;i++)instr_count[i]=0;
  fd=$fopen("case_results.csv","w");tracefd=$fopen("baseline_trace.csv","w");timingfd=$fopen("case_timings.csv","w");
  if(!fd||!tracefd||!timingfd)$fatal(1,"Cannot open result receipts");
  $fdisplay(timingfd,"case,start_ps");
  $fdisplay(fd,"case,cycles,retired,stalls,redirects,halted,fault,witness_seen,witness_required");
  $fdisplay(tracefd,"cycle,fetch_pc,d_valid,d_pc,x_valid,x_pc,m_valid,m_pc,w_valid,w_pc,stall,redirect,dm_en,dm_we,dm_addr,dm_din,Z,C,V");
  clear_case("BASELINE");
  load(0,'h1005);load(1,'h1403);load(2,'h4100);load(3,'h7401);load(4,'h1c20);load(5,'h3300);load(6,'h2b00);load(7,'ha200);load(8,'hd001);load(9,'h14ff);load(10,'he000);
  run_program(17,1);
  clear_case("T01");initial_r[0]=1;initial_r[1]=1;initial_r[2]='hffff;load(0,'ha100);load(1,'h5801);load(2,'hd001);load(3,'h1c55);load(4,'he000);run_program(10,0);
  clear_case("T02");initial_r[0]=1;initial_r[1]=2;load(0,'ha000);load(1,'ha100);load(2,'hd001);load(3,'h1855);load(4,'he000);run_program(9,0);
  clear_case("T03");initial_r[0]='h7fff;initial_r[1]='h20;dut.dm.mem[31]='hbeef;load(0,'h5001);load(1,'h29ff);load(2,'h3900);load(3,'he000);run_program(9,1);
  clear_case("T04");initial_r[0]='hffff;load(0,'hc003);load(1,'h5001);load(2,'ha000);load(3,'he000);run_program(8,0);
  clear_case("T05");initial_r[0]='h7fff;initial_r[1]='hff;load(0,'h5001);load(1,'h2901);load(2,'h5801);load(3,'he000);run_program(6,1);
  clear_case("T06");initial_r[1]='h20;initial_r[2]=1;dut.dm.mem[32]=1;load(0,'h2100);load(1,'ha200);load(2,'hd001);load(3,'h1c55);load(4,'he000);run_program(11,1);
  clear_case("T07");initial_r[0]='h20;dut.dm.mem[32]='h1234;load(0,'h2400);load(1,'he000);load(2,'h3401);run_program(6,0);
  clear_case("T08");initial_r[0]='h7fff;initial_r[1]='h20;dut.dm.mem[32]=1;load(0,'h5001);load(1,'h1c00);load(2,'h2900);load(3,'h4a00);load(4,'he000);run_program(10,1);
  clear_case("T10");initial_r[0]='h55aa;initial_z=1;initial_c=1;initial_v=1;load(0,'h140f);load(1,'h0100);load(2,'he000);run_program(7,0);
  clear_case("T11a");initial_r[0]='h8000;initial_r[1]=1;initial_z=1;load(0,'h6100);load(1,'he000);run_program(6,0);
  clear_case("T11b");initial_r[1]=1;initial_z=1;load(0,'h6100);load(1,'he000);run_program(6,0);
  clear_case("T12");initial_r[0]='ha5a5;initial_r[1]='h0f0f;initial_z=1;initial_c=1;initial_v=1;load(0,'h8100);load(1,'he000);run_program(6,0);
  clear_case("T13");initial_r[0]='ha500;initial_r[1]='ha5;initial_z=1;initial_c=1;initial_v=1;load(0,'h9100);load(1,'he000);run_program(6,0);
  clear_case("T14a");load(0,'h1001);load(1,'hb000);load(2,'h1402);load(3,'he000);run_program(6,0);
  clear_case("T14b");load(0,'h1001);load(1,'hf000);load(2,'h1402);load(3,'he000);run_program(6,0);
  clear_case("T15");load(0,'h1002);load(1,'h1401);load(2,'h7001);load(3,'ha100);load(4,'hd0fd);load(5,'he000);run_program(15,0);
  clear_case("T16");initial_r[1]='hff;initial_r[2]='h55aa;load(0,'h2901);load(1,'he000);load(2,'h1001);run_program(5,0);
  clear_case("T17a");initial_r[0]='h7fff;initial_r[1]='hff;initial_z=1;dut.dm.mem[0]='hcafe;dut.dm.mem[255]='hbeef;load(0,'h5001);load(1,'h3101);load(2,'h1c55);load(3,'he000);run_program(6,0);
  clear_case("T17b");dut.dm.mem[255]='hbeef;load(0,'h1001);load(1,'h31ff);load(2,'he000);run_program(6,0);
  clear_case("T18a");load(0,'hc0ff);load(255,'h1001);run_program(9,0);
  clear_case("T18b");load(0,'hc0ff);load(255,'hc002);load(2,'he000);run_program(11,0);
  clear_case("LOAD_MOV_NO_FALSE_STALL");initial_r[1]=32;dut.dm.mem[32]=7;load(0,'h2100);load(1,'h1005);load(2,'he000);run_program(7,0);
  clear_case("LOAD_STR_BASE");initial_r[1]=32;initial_r[2]='hbeef;dut.dm.mem[32]=33;load(0,'h2100);load(1,'h3800);load(2,'he000);run_program(8,1);
  clear_case("NEWEST_M_OVER_W");load(0,'h1001);load(1,'h1002);load(2,'h0400);load(3,'he000);run_program(8,0);
  clear_case("MEM_FAULT_OVER_REDIRECT");initial_r[1]=255;load(0,'h2901);load(1,'hc003);load(2,'h1001);load(3,'he000);run_program(5,0);
  clear_case("LEGAL_STR_BEFORE_EX_FAULT");initial_r[0]='hcafe;initial_r[1]=32;load(0,'h3100);load(1,'hb000);run_program(6,0);
  clear_case("WRAPPED_EA");initial_r[0]='hcafe;initial_r[1]='hffff;load(0,'h3101);load(1,'h2901);load(2,'he000);run_program(7,0);
  for(j=0;j<=12;j++)reset_probe(j,0);
  for(j=4;j<=6;j++)reset_probe(j,1);
  // 100 constrained straight-line programs: valid memory base R3=32,
  // destinations R0..R2, random regs/immediates/flags; no branch here.
  for(j=0;j<100;j++)begin
   generated_label=$sformatf("RANDOM_%0d",j);clear_case(generated_label);initial_r[3]=32;
   for(i=0;i<3;i++)begin random_state=nxt(random_state);initial_r[i]=random_state[15:0];end
   for(i=0;i<32;i++)begin
    random_state=nxt(random_state);op=random_state%11;rd=(random_state>>8)%3;rs=(random_state>>10)%4;imm=random_state[23:16];
    if(op==2||op==3)begin rs=3;imm=random_state%16;end
    load(i,16'((op<<12)|(rd<<10)|(rs<<8)|imm[7:0]));
   end
   load(32,'he000);run_program(-1,-1);
  end
  for(i=0;i<16;i++)if(i!=11&&i!=15&&instr_count[i]==0)$fatal(1,"Missing legal Opcode %h",i);
   $display("DATAPATH_PASS cases=%0d reset_probes=%0d retired=%0d failures=0 legal_opcode_coverage=14/14",total_cases,reset_probes,total_retired);
  $fclose(fd);$fclose(tracefd);$fclose(timingfd);$finish;
 end
endmodule
