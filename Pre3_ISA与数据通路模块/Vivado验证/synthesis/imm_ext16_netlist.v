// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2025.2 (win64) Build 6299465 Fri Nov 14 19:35:11 GMT 2025
// Date        : Sun Sep 20 21:16:26 2026
// Host        : LAPTOP-BSM79J69 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim synthesis/imm_ext16_netlist.v
// Design      : imm_ext16
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z010clg400-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* NotValidForBitStream *)
module imm_ext16
   (imm,
    sign_mode,
    value);
  input [7:0]imm;
  input sign_mode;
  output [15:0]value;

  wire [7:0]imm;
  wire sign_mode;
  wire sign_mode_IBUF;
  wire [15:0]value;
  wire [8:0]value_OBUF;

  IBUF \imm_IBUF[0]_inst 
       (.I(imm[0]),
        .O(value_OBUF[0]));
  IBUF \imm_IBUF[1]_inst 
       (.I(imm[1]),
        .O(value_OBUF[1]));
  IBUF \imm_IBUF[2]_inst 
       (.I(imm[2]),
        .O(value_OBUF[2]));
  IBUF \imm_IBUF[3]_inst 
       (.I(imm[3]),
        .O(value_OBUF[3]));
  IBUF \imm_IBUF[4]_inst 
       (.I(imm[4]),
        .O(value_OBUF[4]));
  IBUF \imm_IBUF[5]_inst 
       (.I(imm[5]),
        .O(value_OBUF[5]));
  IBUF \imm_IBUF[6]_inst 
       (.I(imm[6]),
        .O(value_OBUF[6]));
  IBUF \imm_IBUF[7]_inst 
       (.I(imm[7]),
        .O(value_OBUF[7]));
  IBUF sign_mode_IBUF_inst
       (.I(sign_mode),
        .O(sign_mode_IBUF));
  OBUF \value_OBUF[0]_inst 
       (.I(value_OBUF[0]),
        .O(value[0]));
  OBUF \value_OBUF[10]_inst 
       (.I(value_OBUF[8]),
        .O(value[10]));
  OBUF \value_OBUF[11]_inst 
       (.I(value_OBUF[8]),
        .O(value[11]));
  OBUF \value_OBUF[12]_inst 
       (.I(value_OBUF[8]),
        .O(value[12]));
  OBUF \value_OBUF[13]_inst 
       (.I(value_OBUF[8]),
        .O(value[13]));
  OBUF \value_OBUF[14]_inst 
       (.I(value_OBUF[8]),
        .O(value[14]));
  OBUF \value_OBUF[15]_inst 
       (.I(value_OBUF[8]),
        .O(value[15]));
  LUT2 #(
    .INIT(4'h8)) 
    \value_OBUF[15]_inst_i_1 
       (.I0(sign_mode_IBUF),
        .I1(value_OBUF[7]),
        .O(value_OBUF[8]));
  OBUF \value_OBUF[1]_inst 
       (.I(value_OBUF[1]),
        .O(value[1]));
  OBUF \value_OBUF[2]_inst 
       (.I(value_OBUF[2]),
        .O(value[2]));
  OBUF \value_OBUF[3]_inst 
       (.I(value_OBUF[3]),
        .O(value[3]));
  OBUF \value_OBUF[4]_inst 
       (.I(value_OBUF[4]),
        .O(value[4]));
  OBUF \value_OBUF[5]_inst 
       (.I(value_OBUF[5]),
        .O(value[5]));
  OBUF \value_OBUF[6]_inst 
       (.I(value_OBUF[6]),
        .O(value[6]));
  OBUF \value_OBUF[7]_inst 
       (.I(value_OBUF[7]),
        .O(value[7]));
  OBUF \value_OBUF[8]_inst 
       (.I(value_OBUF[8]),
        .O(value[8]));
  OBUF \value_OBUF[9]_inst 
       (.I(value_OBUF[8]),
        .O(value[9]));
endmodule
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;
    parameter GRES_WIDTH = 10000;
    parameter GRES_START = 10000;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    wire GRESTORE;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;
    reg GRESTORE_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;
    assign (strong1, weak0) GRESTORE = GRESTORE_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

    initial begin 
	GRESTORE_int = 1'b0;
	#(GRES_START);
	GRESTORE_int = 1'b1;
	#(GRES_WIDTH);
	GRESTORE_int = 1'b0;
    end

endmodule
`endif
