`timescale 1ns/1ps
module tb_wb_guards;
  reg clk=0,rst=1;always #5 clk=~clk;
  wire[15:0]im_addr,dm_addr,dm_din;
  wire im_en,dm_en,dm_we,halted,fault;
  reg[15:0]im_dout=0,dm_dout=0;
  reg[15:0]im[0:255],dm[0:255];
  datapath_core dut(.clk(clk),.rst(rst),.im_addr(im_addr),.im_en(im_en),.im_dout(im_dout),
    .dm_addr(dm_addr),.dm_en(dm_en),.dm_we(dm_we),.dm_din(dm_din),.dm_dout(dm_dout),.halted(halted),.fault(fault));
  always @(posedge clk)begin
    if(im_en)im_dout<=im[im_addr];
    if(dm_en)begin if(dm_we)dm[dm_addr]<=dm_din;else dm_dout<=dm[dm_addr];end
  end
  integer kind,cycles,stores,stalls,passed=0,fd;
  bit injected,done,previous_store;
  task automatic edge_check;
    begin
      @(posedge clk);
      if(rst)begin
        if({im_en,dm_en,dm_we,dut.rf_we,dut.z_we,dut.cv_we}!==0)$fatal(1,"GUARD_RESET_WRITE");
      end else begin
        cycles++;
        if(dut.load_use)stalls++;
        if(kind==8 && dut.x_valid && dut.x_mem_read && dut.d_valid && dut.d_inst[15:12]==9
           && dut.load_use!==1)$fatal(1,"GUARD_BASE_STALL");
        if(previous_store && !(dut.w_valid && dut.w_store && dut.w_pc==1))$fatal(1,"GUARD_STORE_WB_TOKEN");
        previous_store=0;
        if(dm_we===1'b1)begin
          if(kind!=0 && kind!=8)$fatal(1,"GUARD_FORBIDDEN_WRITE kind=%0d",kind);
          if(dm_addr!==33 || dm_din!==(kind==8?16'd33:16'hbeef))$fatal(1,"GUARD_STORE_VALUE");
          stores++;previous_store=1;
        end
        if($isunknown({dm_en,dm_we}))$fatal(1,"GUARD_UNKNOWN_ENABLE");
      end
      #1;
      if(rst && dut.m_store_pending!==0)$fatal(1,"GUARD_RESET_PENDING");
      if(halted||fault)done=1;
    end
  endtask
  initial begin
    fd=$fopen("guards.csv","w");if(!fd)$fatal(1,"GUARD_OUTPUT");
    $fdisplay(fd,"kind,cycles,stores,stalls,injected,halted,fault,stop_reason");
    for(kind=0;kind<10;kind++)begin
      @(negedge clk);rst=1;cycles=0;stores=0;stalls=0;injected=0;done=0;previous_store=0;
      for(integer i=0;i<256;i++)begin im[i]=16'hb000;dm[i]=0;end
      im[0]=16'h8300;im[1]=(kind==8?16'h9000:16'h9301);im[2]=16'he000;im[3]=16'h9702;
      dm[32]=(kind==8?16'd33:16'hbeef);dm[33]=16'h1234;
      repeat(2)begin @(posedge clk);#1;if(dut.m_store_pending!==0)$fatal(1,"GUARD_RESET_PENDING");end
      @(negedge clk);dut.u_rf.regs[3]=32;rst=0;#1;
      while(!done && cycles<80)begin
        if(!injected && dut.m_valid && dut.m_store_pending)begin
          case(kind)
            1:dut.w_valid=0;
            2:dut.w_reg_write=0;
            3:dut.w_wb_sel=0;
            4:dut.w_rd=1;
            5:dut.w_fault=1;
            6:dut.w_wb_sel=1'bx;
            7:rst=1;
            9:begin dut.m_exec_value=256;dut.w_valid=0;end
            default:begin end
          endcase
          injected=1;#1;
          if(kind>=1 && kind<=6 && (dut.m_store_data_ready!==0 || dut.m_store_data_fault!==1 || {dm_en,dm_we}!==0))
            $fatal(1,"GUARD_READY_FAIL_CLOSED kind=%0d",kind);
          if(kind==9 && (dut.m_fault_event!==1 || {dm_en,dm_we}!==0))$fatal(1,"GUARD_ADDRESS_PRIORITY");
          $display("GUARD_REAL_WITNESS kind=%0d pending=%b",kind,dut.m_store_pending);
        end
        edge_check();
        if(kind==7 && rst)begin
          if(dm[33]!==16'h1234)$fatal(1,"GUARD_RESET_STORE_OCCURRED");
          @(negedge clk);im[0]=16'he000;im[1]=16'hb000;rst=0;#1;
        end else if(!done)begin @(negedge clk);#1;end
      end
      if(!done)$fatal(1,"GUARD_TIMEOUT kind=%0d",kind);
      if(kind!=8 && !injected)$fatal(1,"GUARD_WITNESS_MISSING");
      if(kind==0 || kind==8)begin
        if(!halted || fault || stores!=1 || dm[33]!==(kind==8?16'd33:16'hbeef))$fatal(1,"GUARD_NORMAL");
        if(stalls!=(kind==8?1:0))$fatal(1,"GUARD_STALL_COUNT");
      end else if(kind==7)begin
        if(!halted || fault || stores!=0 || dm[33]!==16'h1234)$fatal(1,"GUARD_RESET_RESULT");
      end else begin
        if(halted || !fault || stores!=0 || dut.stop_reason!==(kind==9?3'd4:3'd5) || dut.stop_pc!==1)
          $fatal(1,"GUARD_FAULT_RESULT kind=%0d reason=%0d",kind,dut.stop_reason);
        if(dm[33]!==16'h1234)$fatal(1,"GUARD_CORRUPT_MEMORY");
      end
      repeat(3)begin @(posedge clk);if({im_en,dm_en,dm_we,dut.rf_we,dut.z_we,dut.cv_we}!==0)$fatal(1,"GUARD_STOP_WRITE");end
      $fdisplay(fd,"%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d",kind,cycles,stores,stalls,injected,halted,fault,dut.stop_reason);
      passed++;$display("WB_GUARD_CASE_PASS kind=%0d",kind);
    end
    if(passed!=10)$fatal(1,"GUARD_COVERAGE");
    $display("WB_GUARDS_PASS cases=10 reset_pending=1 missing_producer=6 address_priority=1");
    $fclose(fd);$finish;
  end
endmodule
