`timescale 1ns/1ps
// Reuses the main CPU checker and timing assertions; does not duplicate ISA.
module tb_hazards;
 tb_datapath #(.EXTENDED(1)) test();
endmodule
