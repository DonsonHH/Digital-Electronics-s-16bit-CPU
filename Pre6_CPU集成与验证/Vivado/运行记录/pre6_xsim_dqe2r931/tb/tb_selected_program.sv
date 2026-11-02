`timescale 1ns/1ps
// Uses the same DEFAULT dut_im/dut_dm paths as the synthesized application.
module tb_selected_program;
 `include "selected_expected.svh"
 reg clk=0,btn_n=1,reset_request=1;always #5 clk=~clk;
 wire[255:0] state;wire[159:0]perf;wire[127:0]ev;wire[7:0]led;wire rst;
 ees331_application #(.RELEASE_BITS(3),.BUILD_ID(64'habcdef0123456789)) dut(.clk(clk),.reset_btn_n(btn_n),.debug_reset(reset_request),.state_probe(state),.perf_probe(perf),.event_probe(ev),.led(led),.core_reset(rst));
 reg[63:0] gold[0:255],packet;reg[79:0]store_gold[0:255],store_packet;
 integer n=0,s=0,cycles=0,stalls=0,redirects=0;
 integer trace,trace_tick=0;
 initial begin
  trace=$fopen("selected_trace.csv","w");if(!trace)$fatal(1,"SELECTED_TRACE_OPEN");
  $fdisplay(trace,"tick,state_before,perf_before,events_before");
  $readmemh("programs/selected_events.mem",gold,0,EXPECTED_N-1);
  $readmemh("programs/selected_stores.mem",store_gold,0,EXPECTED_STORES>0?EXPECTED_STORES-1:0);
  repeat(5)@(negedge clk);reset_request=0;
 end
 always @(posedge clk)begin trace_tick=trace_tick+1;$fdisplay(trace,"%0d,%h,%h,%h",trace_tick,state,perf,ev);end
 always @(posedge clk)begin
  if(rst)begin n=0;s=0;cycles=0;stalls=0;redirects=0;end
  else if(!state[88]&&!state[89])begin
   cycles=cycles+1;
   if(ev[0])begin
    if(n>=EXPECTED_N)$fatal(1,"SELECTED_EXTRA_WB");packet=gold[n];
    if(ev[24:9]!==packet[15:0]||{ev[1],ev[3],ev[2],ev[6],ev[5],ev[4]}!==packet[46:41])$fatal(1,"SELECTED_WB_ORDER index=%0d",n);
    if(ev[4]&&(ev[8:7]!==packet[21:20]||ev[40:25]!==packet[37:22]))$fatal(1,"SELECTED_RF_WRITE");
    if(ev[5]&&ev[43]!==packet[40])$fatal(1,"SELECTED_Z_WRITE");
    if(ev[6]&&ev[42:41]!==packet[39:38])$fatal(1,"SELECTED_CV_WRITE");n=n+1;
   end
   if(ev[45])begin
    if(s>=EXPECTED_STORES)$fatal(1,"SELECTED_EXTRA_STORE");store_packet=store_gold[s];
    if(ev[44]!==1||ev[61:46]!==store_packet[62:47]||ev[77:62]!==store_packet[37:22]||store_packet[79:63]!==n)$fatal(1,"SELECTED_STORE_ORDER");s=s+1;
   end
   if(ev[78])stalls=stalls+1;if(ev[79])redirects=redirects+1;
   #1;if(state[86])begin
    if(state[88]!==1||state[89]!==0||state[87]!==1||state[82:67]!==EXPECTED_PC||state[85:83]!==1||state[66:64]!==EXPECTED_FLAGS||state[63:0]!==EXPECTED_RF||state[90]!==1||state[106:91]!==EXPECTED_PC)$fatal(1,"SELECTED_STOP_STATE");
    if(state[107]!==(EXPECTED_STORES>0)||state[140]!==0||state[191:142]!==0||state[255:192]!==64'habcdef0123456789)$fatal(1,"SELECTED_STOP_LAYOUT");
    if(led[7:1]!==7'b0010110)$fatal(1,"SELECTED_LED_POLARITY");
    if(EXPECTED_STORES>0&&(state[123:108]!==store_packet[62:47]||state[139:124]!==store_packet[37:22]))$fatal(1,"SELECTED_LAST_STORE");
    if(perf!=={32'(EXPECTED_STORES),32'(EXPECTED_REDIRECTS),32'(EXPECTED_STALLS),32'(EXPECTED_N),32'(EXPECTED_CYCLES)}||cycles!==EXPECTED_CYCLES||n!==EXPECTED_N||s!==EXPECTED_STORES||stalls!==EXPECTED_STALLS||redirects!==EXPECTED_REDIRECTS)$fatal(1,"SELECTED_COUNTERS");
    $display("BOARD_SELECTED_PASS program=%s cycles=%0d completed=%0d stalls=%0d redirects=%0d stores=%0d",PROGRAM,cycles,n,stalls,redirects,s);$fclose(trace);$finish;
   end
  end
 end
 initial begin #100000;$fatal(1,"SELECTED_TIMEOUT");end
endmodule
