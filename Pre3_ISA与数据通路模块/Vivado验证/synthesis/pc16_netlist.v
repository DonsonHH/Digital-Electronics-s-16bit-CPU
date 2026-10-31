// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2025.2 (win64) Build 6299465 Fri Nov 14 19:35:11 GMT 2025
// Date        : Sun Sep 20 21:15:55 2026
// Host        : LAPTOP-BSM79J69 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim synthesis/pc16_netlist.v
// Design      : pc16
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z010clg400-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* NotValidForBitStream *)
module pc16
   (clk,
    rst,
    hold,
    redirect,
    target,
    pc);
  input clk;
  input rst;
  input hold;
  input redirect;
  input [15:0]target;
  output [15:0]pc;

  wire clk;
  wire clk_IBUF;
  wire clk_IBUF_BUFG;
  wire hold;
  wire hold_IBUF;
  wire [15:0]pc;
  wire \pc[0]_i_1_n_0 ;
  wire \pc[0]_i_3_n_0 ;
  wire \pc[0]_i_4_n_0 ;
  wire \pc[0]_i_5_n_0 ;
  wire \pc[0]_i_6_n_0 ;
  wire \pc[0]_i_7_n_0 ;
  wire \pc[12]_i_2_n_0 ;
  wire \pc[12]_i_3_n_0 ;
  wire \pc[12]_i_4_n_0 ;
  wire \pc[12]_i_5_n_0 ;
  wire \pc[4]_i_2_n_0 ;
  wire \pc[4]_i_3_n_0 ;
  wire \pc[4]_i_4_n_0 ;
  wire \pc[4]_i_5_n_0 ;
  wire \pc[8]_i_2_n_0 ;
  wire \pc[8]_i_3_n_0 ;
  wire \pc[8]_i_4_n_0 ;
  wire \pc[8]_i_5_n_0 ;
  wire [15:0]pc_OBUF;
  wire \pc_reg[0]_i_2_n_0 ;
  wire \pc_reg[0]_i_2_n_1 ;
  wire \pc_reg[0]_i_2_n_2 ;
  wire \pc_reg[0]_i_2_n_3 ;
  wire \pc_reg[0]_i_2_n_4 ;
  wire \pc_reg[0]_i_2_n_5 ;
  wire \pc_reg[0]_i_2_n_6 ;
  wire \pc_reg[0]_i_2_n_7 ;
  wire \pc_reg[12]_i_1_n_1 ;
  wire \pc_reg[12]_i_1_n_2 ;
  wire \pc_reg[12]_i_1_n_3 ;
  wire \pc_reg[12]_i_1_n_4 ;
  wire \pc_reg[12]_i_1_n_5 ;
  wire \pc_reg[12]_i_1_n_6 ;
  wire \pc_reg[12]_i_1_n_7 ;
  wire \pc_reg[4]_i_1_n_0 ;
  wire \pc_reg[4]_i_1_n_1 ;
  wire \pc_reg[4]_i_1_n_2 ;
  wire \pc_reg[4]_i_1_n_3 ;
  wire \pc_reg[4]_i_1_n_4 ;
  wire \pc_reg[4]_i_1_n_5 ;
  wire \pc_reg[4]_i_1_n_6 ;
  wire \pc_reg[4]_i_1_n_7 ;
  wire \pc_reg[8]_i_1_n_0 ;
  wire \pc_reg[8]_i_1_n_1 ;
  wire \pc_reg[8]_i_1_n_2 ;
  wire \pc_reg[8]_i_1_n_3 ;
  wire \pc_reg[8]_i_1_n_4 ;
  wire \pc_reg[8]_i_1_n_5 ;
  wire \pc_reg[8]_i_1_n_6 ;
  wire \pc_reg[8]_i_1_n_7 ;
  wire redirect;
  wire redirect_IBUF;
  wire rst;
  wire rst_IBUF;
  wire [15:0]target;
  wire [15:0]target_IBUF;
  wire [3:3]\NLW_pc_reg[12]_i_1_CO_UNCONNECTED ;

  BUFG clk_IBUF_BUFG_inst
       (.I(clk_IBUF),
        .O(clk_IBUF_BUFG));
  IBUF clk_IBUF_inst
       (.I(clk),
        .O(clk_IBUF));
  IBUF hold_IBUF_inst
       (.I(hold),
        .O(hold_IBUF));
  LUT2 #(
    .INIT(4'hB)) 
    \pc[0]_i_1 
       (.I0(redirect_IBUF),
        .I1(hold_IBUF),
        .O(\pc[0]_i_1_n_0 ));
  LUT3 #(
    .INIT(8'hB8)) 
    \pc[0]_i_3 
       (.I0(target_IBUF[0]),
        .I1(redirect_IBUF),
        .I2(pc_OBUF[0]),
        .O(\pc[0]_i_3_n_0 ));
  LUT3 #(
    .INIT(8'hB8)) 
    \pc[0]_i_4 
       (.I0(target_IBUF[3]),
        .I1(redirect_IBUF),
        .I2(pc_OBUF[3]),
        .O(\pc[0]_i_4_n_0 ));
  LUT3 #(
    .INIT(8'hB8)) 
    \pc[0]_i_5 
       (.I0(target_IBUF[2]),
        .I1(redirect_IBUF),
        .I2(pc_OBUF[2]),
        .O(\pc[0]_i_5_n_0 ));
  LUT3 #(
    .INIT(8'hB8)) 
    \pc[0]_i_6 
       (.I0(target_IBUF[1]),
        .I1(redirect_IBUF),
        .I2(pc_OBUF[1]),
        .O(\pc[0]_i_6_n_0 ));
  LUT3 #(
    .INIT(8'hC5)) 
    \pc[0]_i_7 
       (.I0(pc_OBUF[0]),
        .I1(target_IBUF[0]),
        .I2(redirect_IBUF),
        .O(\pc[0]_i_7_n_0 ));
  LUT3 #(
    .INIT(8'hB8)) 
    \pc[12]_i_2 
       (.I0(target_IBUF[15]),
        .I1(redirect_IBUF),
        .I2(pc_OBUF[15]),
        .O(\pc[12]_i_2_n_0 ));
  LUT3 #(
    .INIT(8'hB8)) 
    \pc[12]_i_3 
       (.I0(target_IBUF[14]),
        .I1(redirect_IBUF),
        .I2(pc_OBUF[14]),
        .O(\pc[12]_i_3_n_0 ));
  LUT3 #(
    .INIT(8'hB8)) 
    \pc[12]_i_4 
       (.I0(target_IBUF[13]),
        .I1(redirect_IBUF),
        .I2(pc_OBUF[13]),
        .O(\pc[12]_i_4_n_0 ));
  LUT3 #(
    .INIT(8'hB8)) 
    \pc[12]_i_5 
       (.I0(target_IBUF[12]),
        .I1(redirect_IBUF),
        .I2(pc_OBUF[12]),
        .O(\pc[12]_i_5_n_0 ));
  LUT3 #(
    .INIT(8'hB8)) 
    \pc[4]_i_2 
       (.I0(target_IBUF[7]),
        .I1(redirect_IBUF),
        .I2(pc_OBUF[7]),
        .O(\pc[4]_i_2_n_0 ));
  LUT3 #(
    .INIT(8'hB8)) 
    \pc[4]_i_3 
       (.I0(target_IBUF[6]),
        .I1(redirect_IBUF),
        .I2(pc_OBUF[6]),
        .O(\pc[4]_i_3_n_0 ));
  LUT3 #(
    .INIT(8'hB8)) 
    \pc[4]_i_4 
       (.I0(target_IBUF[5]),
        .I1(redirect_IBUF),
        .I2(pc_OBUF[5]),
        .O(\pc[4]_i_4_n_0 ));
  LUT3 #(
    .INIT(8'hB8)) 
    \pc[4]_i_5 
       (.I0(target_IBUF[4]),
        .I1(redirect_IBUF),
        .I2(pc_OBUF[4]),
        .O(\pc[4]_i_5_n_0 ));
  LUT3 #(
    .INIT(8'hB8)) 
    \pc[8]_i_2 
       (.I0(target_IBUF[11]),
        .I1(redirect_IBUF),
        .I2(pc_OBUF[11]),
        .O(\pc[8]_i_2_n_0 ));
  LUT3 #(
    .INIT(8'hB8)) 
    \pc[8]_i_3 
       (.I0(target_IBUF[10]),
        .I1(redirect_IBUF),
        .I2(pc_OBUF[10]),
        .O(\pc[8]_i_3_n_0 ));
  LUT3 #(
    .INIT(8'hB8)) 
    \pc[8]_i_4 
       (.I0(target_IBUF[9]),
        .I1(redirect_IBUF),
        .I2(pc_OBUF[9]),
        .O(\pc[8]_i_4_n_0 ));
  LUT3 #(
    .INIT(8'hB8)) 
    \pc[8]_i_5 
       (.I0(target_IBUF[8]),
        .I1(redirect_IBUF),
        .I2(pc_OBUF[8]),
        .O(\pc[8]_i_5_n_0 ));
  OBUF \pc_OBUF[0]_inst 
       (.I(pc_OBUF[0]),
        .O(pc[0]));
  OBUF \pc_OBUF[10]_inst 
       (.I(pc_OBUF[10]),
        .O(pc[10]));
  OBUF \pc_OBUF[11]_inst 
       (.I(pc_OBUF[11]),
        .O(pc[11]));
  OBUF \pc_OBUF[12]_inst 
       (.I(pc_OBUF[12]),
        .O(pc[12]));
  OBUF \pc_OBUF[13]_inst 
       (.I(pc_OBUF[13]),
        .O(pc[13]));
  OBUF \pc_OBUF[14]_inst 
       (.I(pc_OBUF[14]),
        .O(pc[14]));
  OBUF \pc_OBUF[15]_inst 
       (.I(pc_OBUF[15]),
        .O(pc[15]));
  OBUF \pc_OBUF[1]_inst 
       (.I(pc_OBUF[1]),
        .O(pc[1]));
  OBUF \pc_OBUF[2]_inst 
       (.I(pc_OBUF[2]),
        .O(pc[2]));
  OBUF \pc_OBUF[3]_inst 
       (.I(pc_OBUF[3]),
        .O(pc[3]));
  OBUF \pc_OBUF[4]_inst 
       (.I(pc_OBUF[4]),
        .O(pc[4]));
  OBUF \pc_OBUF[5]_inst 
       (.I(pc_OBUF[5]),
        .O(pc[5]));
  OBUF \pc_OBUF[6]_inst 
       (.I(pc_OBUF[6]),
        .O(pc[6]));
  OBUF \pc_OBUF[7]_inst 
       (.I(pc_OBUF[7]),
        .O(pc[7]));
  OBUF \pc_OBUF[8]_inst 
       (.I(pc_OBUF[8]),
        .O(pc[8]));
  OBUF \pc_OBUF[9]_inst 
       (.I(pc_OBUF[9]),
        .O(pc[9]));
  FDRE \pc_reg[0] 
       (.C(clk_IBUF_BUFG),
        .CE(\pc[0]_i_1_n_0 ),
        .D(\pc_reg[0]_i_2_n_7 ),
        .Q(pc_OBUF[0]),
        .R(rst_IBUF));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \pc_reg[0]_i_2 
       (.CI(1'b0),
        .CO({\pc_reg[0]_i_2_n_0 ,\pc_reg[0]_i_2_n_1 ,\pc_reg[0]_i_2_n_2 ,\pc_reg[0]_i_2_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,\pc[0]_i_3_n_0 }),
        .O({\pc_reg[0]_i_2_n_4 ,\pc_reg[0]_i_2_n_5 ,\pc_reg[0]_i_2_n_6 ,\pc_reg[0]_i_2_n_7 }),
        .S({\pc[0]_i_4_n_0 ,\pc[0]_i_5_n_0 ,\pc[0]_i_6_n_0 ,\pc[0]_i_7_n_0 }));
  FDRE \pc_reg[10] 
       (.C(clk_IBUF_BUFG),
        .CE(\pc[0]_i_1_n_0 ),
        .D(\pc_reg[8]_i_1_n_5 ),
        .Q(pc_OBUF[10]),
        .R(rst_IBUF));
  FDRE \pc_reg[11] 
       (.C(clk_IBUF_BUFG),
        .CE(\pc[0]_i_1_n_0 ),
        .D(\pc_reg[8]_i_1_n_4 ),
        .Q(pc_OBUF[11]),
        .R(rst_IBUF));
  FDRE \pc_reg[12] 
       (.C(clk_IBUF_BUFG),
        .CE(\pc[0]_i_1_n_0 ),
        .D(\pc_reg[12]_i_1_n_7 ),
        .Q(pc_OBUF[12]),
        .R(rst_IBUF));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \pc_reg[12]_i_1 
       (.CI(\pc_reg[8]_i_1_n_0 ),
        .CO({\NLW_pc_reg[12]_i_1_CO_UNCONNECTED [3],\pc_reg[12]_i_1_n_1 ,\pc_reg[12]_i_1_n_2 ,\pc_reg[12]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\pc_reg[12]_i_1_n_4 ,\pc_reg[12]_i_1_n_5 ,\pc_reg[12]_i_1_n_6 ,\pc_reg[12]_i_1_n_7 }),
        .S({\pc[12]_i_2_n_0 ,\pc[12]_i_3_n_0 ,\pc[12]_i_4_n_0 ,\pc[12]_i_5_n_0 }));
  FDRE \pc_reg[13] 
       (.C(clk_IBUF_BUFG),
        .CE(\pc[0]_i_1_n_0 ),
        .D(\pc_reg[12]_i_1_n_6 ),
        .Q(pc_OBUF[13]),
        .R(rst_IBUF));
  FDRE \pc_reg[14] 
       (.C(clk_IBUF_BUFG),
        .CE(\pc[0]_i_1_n_0 ),
        .D(\pc_reg[12]_i_1_n_5 ),
        .Q(pc_OBUF[14]),
        .R(rst_IBUF));
  FDRE \pc_reg[15] 
       (.C(clk_IBUF_BUFG),
        .CE(\pc[0]_i_1_n_0 ),
        .D(\pc_reg[12]_i_1_n_4 ),
        .Q(pc_OBUF[15]),
        .R(rst_IBUF));
  FDRE \pc_reg[1] 
       (.C(clk_IBUF_BUFG),
        .CE(\pc[0]_i_1_n_0 ),
        .D(\pc_reg[0]_i_2_n_6 ),
        .Q(pc_OBUF[1]),
        .R(rst_IBUF));
  FDRE \pc_reg[2] 
       (.C(clk_IBUF_BUFG),
        .CE(\pc[0]_i_1_n_0 ),
        .D(\pc_reg[0]_i_2_n_5 ),
        .Q(pc_OBUF[2]),
        .R(rst_IBUF));
  FDRE \pc_reg[3] 
       (.C(clk_IBUF_BUFG),
        .CE(\pc[0]_i_1_n_0 ),
        .D(\pc_reg[0]_i_2_n_4 ),
        .Q(pc_OBUF[3]),
        .R(rst_IBUF));
  FDRE \pc_reg[4] 
       (.C(clk_IBUF_BUFG),
        .CE(\pc[0]_i_1_n_0 ),
        .D(\pc_reg[4]_i_1_n_7 ),
        .Q(pc_OBUF[4]),
        .R(rst_IBUF));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \pc_reg[4]_i_1 
       (.CI(\pc_reg[0]_i_2_n_0 ),
        .CO({\pc_reg[4]_i_1_n_0 ,\pc_reg[4]_i_1_n_1 ,\pc_reg[4]_i_1_n_2 ,\pc_reg[4]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\pc_reg[4]_i_1_n_4 ,\pc_reg[4]_i_1_n_5 ,\pc_reg[4]_i_1_n_6 ,\pc_reg[4]_i_1_n_7 }),
        .S({\pc[4]_i_2_n_0 ,\pc[4]_i_3_n_0 ,\pc[4]_i_4_n_0 ,\pc[4]_i_5_n_0 }));
  FDRE \pc_reg[5] 
       (.C(clk_IBUF_BUFG),
        .CE(\pc[0]_i_1_n_0 ),
        .D(\pc_reg[4]_i_1_n_6 ),
        .Q(pc_OBUF[5]),
        .R(rst_IBUF));
  FDRE \pc_reg[6] 
       (.C(clk_IBUF_BUFG),
        .CE(\pc[0]_i_1_n_0 ),
        .D(\pc_reg[4]_i_1_n_5 ),
        .Q(pc_OBUF[6]),
        .R(rst_IBUF));
  FDRE \pc_reg[7] 
       (.C(clk_IBUF_BUFG),
        .CE(\pc[0]_i_1_n_0 ),
        .D(\pc_reg[4]_i_1_n_4 ),
        .Q(pc_OBUF[7]),
        .R(rst_IBUF));
  FDRE \pc_reg[8] 
       (.C(clk_IBUF_BUFG),
        .CE(\pc[0]_i_1_n_0 ),
        .D(\pc_reg[8]_i_1_n_7 ),
        .Q(pc_OBUF[8]),
        .R(rst_IBUF));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \pc_reg[8]_i_1 
       (.CI(\pc_reg[4]_i_1_n_0 ),
        .CO({\pc_reg[8]_i_1_n_0 ,\pc_reg[8]_i_1_n_1 ,\pc_reg[8]_i_1_n_2 ,\pc_reg[8]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\pc_reg[8]_i_1_n_4 ,\pc_reg[8]_i_1_n_5 ,\pc_reg[8]_i_1_n_6 ,\pc_reg[8]_i_1_n_7 }),
        .S({\pc[8]_i_2_n_0 ,\pc[8]_i_3_n_0 ,\pc[8]_i_4_n_0 ,\pc[8]_i_5_n_0 }));
  FDRE \pc_reg[9] 
       (.C(clk_IBUF_BUFG),
        .CE(\pc[0]_i_1_n_0 ),
        .D(\pc_reg[8]_i_1_n_6 ),
        .Q(pc_OBUF[9]),
        .R(rst_IBUF));
  IBUF redirect_IBUF_inst
       (.I(redirect),
        .O(redirect_IBUF));
  IBUF rst_IBUF_inst
       (.I(rst),
        .O(rst_IBUF));
  IBUF \target_IBUF[0]_inst 
       (.I(target[0]),
        .O(target_IBUF[0]));
  IBUF \target_IBUF[10]_inst 
       (.I(target[10]),
        .O(target_IBUF[10]));
  IBUF \target_IBUF[11]_inst 
       (.I(target[11]),
        .O(target_IBUF[11]));
  IBUF \target_IBUF[12]_inst 
       (.I(target[12]),
        .O(target_IBUF[12]));
  IBUF \target_IBUF[13]_inst 
       (.I(target[13]),
        .O(target_IBUF[13]));
  IBUF \target_IBUF[14]_inst 
       (.I(target[14]),
        .O(target_IBUF[14]));
  IBUF \target_IBUF[15]_inst 
       (.I(target[15]),
        .O(target_IBUF[15]));
  IBUF \target_IBUF[1]_inst 
       (.I(target[1]),
        .O(target_IBUF[1]));
  IBUF \target_IBUF[2]_inst 
       (.I(target[2]),
        .O(target_IBUF[2]));
  IBUF \target_IBUF[3]_inst 
       (.I(target[3]),
        .O(target_IBUF[3]));
  IBUF \target_IBUF[4]_inst 
       (.I(target[4]),
        .O(target_IBUF[4]));
  IBUF \target_IBUF[5]_inst 
       (.I(target[5]),
        .O(target_IBUF[5]));
  IBUF \target_IBUF[6]_inst 
       (.I(target[6]),
        .O(target_IBUF[6]));
  IBUF \target_IBUF[7]_inst 
       (.I(target[7]),
        .O(target_IBUF[7]));
  IBUF \target_IBUF[8]_inst 
       (.I(target[8]),
        .O(target_IBUF[8]));
  IBUF \target_IBUF[9]_inst 
       (.I(target[9]),
        .O(target_IBUF[9]));
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
