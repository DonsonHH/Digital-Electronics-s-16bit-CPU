`timescale 1ns/1ps
module tb_adder_only;
  reg [15:0] a=0,b=0;
  reg cin=0;
  wire [15:0] sg,sr;
  wire cg,cr;
  reg [16:0] expected;
  longint unsigned index,completed,stop_index;
  localparam longint unsigned START=64'd1207959552;
  localparam longint unsigned TOTAL=64'd8589934592;
  ripple_adder gate_dut(a,b,cin,sg,cg);
  adder_rtl rtl_dut(a,b,cin,sr,cr);
  initial begin
    completed=0;stop_index=TOTAL;
    if($value$plusargs("END=%d",stop_index)) begin end
    if(stop_index<=START || stop_index>TOTAL) $fatal(1,"Invalid END");
    $display("BEGIN_ADDER_RESUME start=%0d end_exclusive=%0d",START,stop_index);
    for(index=START;index<stop_index;index++) begin
      {a,b,cin}=index[32:0];
      expected={1'b0,a}+{1'b0,b}+{16'b0,cin};
      #1;
      if({cg,sg}!==expected || {cr,sr}!==expected)
        $fatal(1,"FAIL index=%0d a=%h b=%h cin=%b ripple=%h rtl=%h expected=%h",index,a,b,cin,{cg,sg},{cr,sr},expected);
      completed++;
      if(completed%64'd16777216==0)
        $display("PROGRESS suffix_completed=%0d cumulative_next_index=%0d",completed,index+1);
    end
    if(completed!==stop_index-START) $fatal(1,"Count mismatch");
    $display("ADDER_RANGE_PASS start=%0d end_exclusive=%0d completed_per_adder=%0d failures=0",START,stop_index,completed);
    $finish;
  end
endmodule
