`timescale 1ns/1ps
module ees331_top #(parameter [63:0] BUILD_ID=64'd0)(input wire clk100,reset_btn_n,output wire[7:0]led);
    wire clk;BUFG clock_buffer(.I(clk100),.O(clk));
    wire[255:0]state_probe;wire[159:0]perf_probe;wire debug_reset;
    ees331_application #(.BUILD_ID(BUILD_ID)) application_i(.clk(clk),.reset_btn_n(reset_btn_n),.debug_reset(debug_reset),
        .state_probe(state_probe),.perf_probe(perf_probe),.led(led));
    // INIT=1 keeps the CPU in reset until a deliberate JTAG release.
    ees331_vio debug_i(.clk(clk),.probe_in0(state_probe),.probe_in1(perf_probe),.probe_out0(debug_reset));
endmodule
