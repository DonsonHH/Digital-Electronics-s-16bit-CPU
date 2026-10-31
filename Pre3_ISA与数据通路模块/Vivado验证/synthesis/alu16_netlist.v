// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2025.2 (win64) Build 6299465 Fri Nov 14 19:35:11 GMT 2025
// Date        : Sun Sep 20 21:15:21 2026
// Host        : LAPTOP-BSM79J69 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim synthesis/alu16_netlist.v
// Design      : alu16
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z010clg400-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* ADD = "3'b001" *) (* AND_OP = "3'b011" *) (* OR_OP = "3'b100" *) 
(* PASS_B = "3'b000" *) (* SUB = "3'b010" *) 
(* NotValidForBitStream *)
module alu16
   (a,
    b,
    op,
    result,
    illegal,
    eq);
  input [15:0]a;
  input [15:0]b;
  input [2:0]op;
  output [15:0]result;
  output illegal;
  output eq;

  wire [15:0]a;
  wire [15:0]a_IBUF;
  wire [15:0]b;
  wire [15:0]b_IBUF;
  wire [15:0]data1;
  wire [15:0]data2;
  wire eq;
  wire eq_OBUF;
  wire eq_OBUF_inst_i_1_n_3;
  wire eq_OBUF_inst_i_2_n_0;
  wire eq_OBUF_inst_i_2_n_1;
  wire eq_OBUF_inst_i_2_n_2;
  wire eq_OBUF_inst_i_2_n_3;
  wire eq_OBUF_inst_i_3_n_0;
  wire eq_OBUF_inst_i_4_n_0;
  wire eq_OBUF_inst_i_5_n_0;
  wire eq_OBUF_inst_i_6_n_0;
  wire eq_OBUF_inst_i_7_n_0;
  wire eq_OBUF_inst_i_8_n_0;
  wire illegal;
  wire illegal_OBUF;
  wire [2:0]op;
  wire [2:0]op_IBUF;
  wire [15:0]result;
  wire [15:0]result_OBUF;
  wire \result_OBUF[0]_inst_i_2_n_0 ;
  wire \result_OBUF[10]_inst_i_2_n_0 ;
  wire \result_OBUF[11]_inst_i_10_n_0 ;
  wire \result_OBUF[11]_inst_i_11_n_0 ;
  wire \result_OBUF[11]_inst_i_12_n_0 ;
  wire \result_OBUF[11]_inst_i_2_n_0 ;
  wire \result_OBUF[11]_inst_i_3_n_0 ;
  wire \result_OBUF[11]_inst_i_3_n_1 ;
  wire \result_OBUF[11]_inst_i_3_n_2 ;
  wire \result_OBUF[11]_inst_i_3_n_3 ;
  wire \result_OBUF[11]_inst_i_4_n_0 ;
  wire \result_OBUF[11]_inst_i_4_n_1 ;
  wire \result_OBUF[11]_inst_i_4_n_2 ;
  wire \result_OBUF[11]_inst_i_4_n_3 ;
  wire \result_OBUF[11]_inst_i_5_n_0 ;
  wire \result_OBUF[11]_inst_i_6_n_0 ;
  wire \result_OBUF[11]_inst_i_7_n_0 ;
  wire \result_OBUF[11]_inst_i_8_n_0 ;
  wire \result_OBUF[11]_inst_i_9_n_0 ;
  wire \result_OBUF[12]_inst_i_2_n_0 ;
  wire \result_OBUF[13]_inst_i_2_n_0 ;
  wire \result_OBUF[14]_inst_i_2_n_0 ;
  wire \result_OBUF[15]_inst_i_10_n_0 ;
  wire \result_OBUF[15]_inst_i_11_n_0 ;
  wire \result_OBUF[15]_inst_i_12_n_0 ;
  wire \result_OBUF[15]_inst_i_2_n_0 ;
  wire \result_OBUF[15]_inst_i_3_n_1 ;
  wire \result_OBUF[15]_inst_i_3_n_2 ;
  wire \result_OBUF[15]_inst_i_3_n_3 ;
  wire \result_OBUF[15]_inst_i_4_n_1 ;
  wire \result_OBUF[15]_inst_i_4_n_2 ;
  wire \result_OBUF[15]_inst_i_4_n_3 ;
  wire \result_OBUF[15]_inst_i_5_n_0 ;
  wire \result_OBUF[15]_inst_i_6_n_0 ;
  wire \result_OBUF[15]_inst_i_7_n_0 ;
  wire \result_OBUF[15]_inst_i_8_n_0 ;
  wire \result_OBUF[15]_inst_i_9_n_0 ;
  wire \result_OBUF[1]_inst_i_2_n_0 ;
  wire \result_OBUF[2]_inst_i_2_n_0 ;
  wire \result_OBUF[3]_inst_i_10_n_0 ;
  wire \result_OBUF[3]_inst_i_11_n_0 ;
  wire \result_OBUF[3]_inst_i_12_n_0 ;
  wire \result_OBUF[3]_inst_i_2_n_0 ;
  wire \result_OBUF[3]_inst_i_3_n_0 ;
  wire \result_OBUF[3]_inst_i_3_n_1 ;
  wire \result_OBUF[3]_inst_i_3_n_2 ;
  wire \result_OBUF[3]_inst_i_3_n_3 ;
  wire \result_OBUF[3]_inst_i_4_n_0 ;
  wire \result_OBUF[3]_inst_i_4_n_1 ;
  wire \result_OBUF[3]_inst_i_4_n_2 ;
  wire \result_OBUF[3]_inst_i_4_n_3 ;
  wire \result_OBUF[3]_inst_i_5_n_0 ;
  wire \result_OBUF[3]_inst_i_6_n_0 ;
  wire \result_OBUF[3]_inst_i_7_n_0 ;
  wire \result_OBUF[3]_inst_i_8_n_0 ;
  wire \result_OBUF[3]_inst_i_9_n_0 ;
  wire \result_OBUF[4]_inst_i_2_n_0 ;
  wire \result_OBUF[5]_inst_i_2_n_0 ;
  wire \result_OBUF[6]_inst_i_2_n_0 ;
  wire \result_OBUF[7]_inst_i_10_n_0 ;
  wire \result_OBUF[7]_inst_i_11_n_0 ;
  wire \result_OBUF[7]_inst_i_12_n_0 ;
  wire \result_OBUF[7]_inst_i_2_n_0 ;
  wire \result_OBUF[7]_inst_i_3_n_0 ;
  wire \result_OBUF[7]_inst_i_3_n_1 ;
  wire \result_OBUF[7]_inst_i_3_n_2 ;
  wire \result_OBUF[7]_inst_i_3_n_3 ;
  wire \result_OBUF[7]_inst_i_4_n_0 ;
  wire \result_OBUF[7]_inst_i_4_n_1 ;
  wire \result_OBUF[7]_inst_i_4_n_2 ;
  wire \result_OBUF[7]_inst_i_4_n_3 ;
  wire \result_OBUF[7]_inst_i_5_n_0 ;
  wire \result_OBUF[7]_inst_i_6_n_0 ;
  wire \result_OBUF[7]_inst_i_7_n_0 ;
  wire \result_OBUF[7]_inst_i_8_n_0 ;
  wire \result_OBUF[7]_inst_i_9_n_0 ;
  wire \result_OBUF[8]_inst_i_2_n_0 ;
  wire \result_OBUF[9]_inst_i_2_n_0 ;
  wire [3:2]NLW_eq_OBUF_inst_i_1_CO_UNCONNECTED;
  wire [3:0]NLW_eq_OBUF_inst_i_1_O_UNCONNECTED;
  wire [3:0]NLW_eq_OBUF_inst_i_2_O_UNCONNECTED;
  wire [3:3]\NLW_result_OBUF[15]_inst_i_3_CO_UNCONNECTED ;
  wire [3:3]\NLW_result_OBUF[15]_inst_i_4_CO_UNCONNECTED ;

  IBUF \a_IBUF[0]_inst 
       (.I(a[0]),
        .O(a_IBUF[0]));
  IBUF \a_IBUF[10]_inst 
       (.I(a[10]),
        .O(a_IBUF[10]));
  IBUF \a_IBUF[11]_inst 
       (.I(a[11]),
        .O(a_IBUF[11]));
  IBUF \a_IBUF[12]_inst 
       (.I(a[12]),
        .O(a_IBUF[12]));
  IBUF \a_IBUF[13]_inst 
       (.I(a[13]),
        .O(a_IBUF[13]));
  IBUF \a_IBUF[14]_inst 
       (.I(a[14]),
        .O(a_IBUF[14]));
  IBUF \a_IBUF[15]_inst 
       (.I(a[15]),
        .O(a_IBUF[15]));
  IBUF \a_IBUF[1]_inst 
       (.I(a[1]),
        .O(a_IBUF[1]));
  IBUF \a_IBUF[2]_inst 
       (.I(a[2]),
        .O(a_IBUF[2]));
  IBUF \a_IBUF[3]_inst 
       (.I(a[3]),
        .O(a_IBUF[3]));
  IBUF \a_IBUF[4]_inst 
       (.I(a[4]),
        .O(a_IBUF[4]));
  IBUF \a_IBUF[5]_inst 
       (.I(a[5]),
        .O(a_IBUF[5]));
  IBUF \a_IBUF[6]_inst 
       (.I(a[6]),
        .O(a_IBUF[6]));
  IBUF \a_IBUF[7]_inst 
       (.I(a[7]),
        .O(a_IBUF[7]));
  IBUF \a_IBUF[8]_inst 
       (.I(a[8]),
        .O(a_IBUF[8]));
  IBUF \a_IBUF[9]_inst 
       (.I(a[9]),
        .O(a_IBUF[9]));
  IBUF \b_IBUF[0]_inst 
       (.I(b[0]),
        .O(b_IBUF[0]));
  IBUF \b_IBUF[10]_inst 
       (.I(b[10]),
        .O(b_IBUF[10]));
  IBUF \b_IBUF[11]_inst 
       (.I(b[11]),
        .O(b_IBUF[11]));
  IBUF \b_IBUF[12]_inst 
       (.I(b[12]),
        .O(b_IBUF[12]));
  IBUF \b_IBUF[13]_inst 
       (.I(b[13]),
        .O(b_IBUF[13]));
  IBUF \b_IBUF[14]_inst 
       (.I(b[14]),
        .O(b_IBUF[14]));
  IBUF \b_IBUF[15]_inst 
       (.I(b[15]),
        .O(b_IBUF[15]));
  IBUF \b_IBUF[1]_inst 
       (.I(b[1]),
        .O(b_IBUF[1]));
  IBUF \b_IBUF[2]_inst 
       (.I(b[2]),
        .O(b_IBUF[2]));
  IBUF \b_IBUF[3]_inst 
       (.I(b[3]),
        .O(b_IBUF[3]));
  IBUF \b_IBUF[4]_inst 
       (.I(b[4]),
        .O(b_IBUF[4]));
  IBUF \b_IBUF[5]_inst 
       (.I(b[5]),
        .O(b_IBUF[5]));
  IBUF \b_IBUF[6]_inst 
       (.I(b[6]),
        .O(b_IBUF[6]));
  IBUF \b_IBUF[7]_inst 
       (.I(b[7]),
        .O(b_IBUF[7]));
  IBUF \b_IBUF[8]_inst 
       (.I(b[8]),
        .O(b_IBUF[8]));
  IBUF \b_IBUF[9]_inst 
       (.I(b[9]),
        .O(b_IBUF[9]));
  OBUF eq_OBUF_inst
       (.I(eq_OBUF),
        .O(eq));
  CARRY4 eq_OBUF_inst_i_1
       (.CI(eq_OBUF_inst_i_2_n_0),
        .CO({NLW_eq_OBUF_inst_i_1_CO_UNCONNECTED[3:2],eq_OBUF,eq_OBUF_inst_i_1_n_3}),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O(NLW_eq_OBUF_inst_i_1_O_UNCONNECTED[3:0]),
        .S({1'b0,1'b0,eq_OBUF_inst_i_3_n_0,eq_OBUF_inst_i_4_n_0}));
  CARRY4 eq_OBUF_inst_i_2
       (.CI(1'b0),
        .CO({eq_OBUF_inst_i_2_n_0,eq_OBUF_inst_i_2_n_1,eq_OBUF_inst_i_2_n_2,eq_OBUF_inst_i_2_n_3}),
        .CYINIT(1'b1),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O(NLW_eq_OBUF_inst_i_2_O_UNCONNECTED[3:0]),
        .S({eq_OBUF_inst_i_5_n_0,eq_OBUF_inst_i_6_n_0,eq_OBUF_inst_i_7_n_0,eq_OBUF_inst_i_8_n_0}));
  LUT2 #(
    .INIT(4'h9)) 
    eq_OBUF_inst_i_3
       (.I0(b_IBUF[15]),
        .I1(a_IBUF[15]),
        .O(eq_OBUF_inst_i_3_n_0));
  LUT6 #(
    .INIT(64'h9009000000009009)) 
    eq_OBUF_inst_i_4
       (.I0(a_IBUF[12]),
        .I1(b_IBUF[12]),
        .I2(b_IBUF[14]),
        .I3(a_IBUF[14]),
        .I4(b_IBUF[13]),
        .I5(a_IBUF[13]),
        .O(eq_OBUF_inst_i_4_n_0));
  LUT6 #(
    .INIT(64'h9009000000009009)) 
    eq_OBUF_inst_i_5
       (.I0(a_IBUF[9]),
        .I1(b_IBUF[9]),
        .I2(b_IBUF[11]),
        .I3(a_IBUF[11]),
        .I4(b_IBUF[10]),
        .I5(a_IBUF[10]),
        .O(eq_OBUF_inst_i_5_n_0));
  LUT6 #(
    .INIT(64'h9009000000009009)) 
    eq_OBUF_inst_i_6
       (.I0(a_IBUF[6]),
        .I1(b_IBUF[6]),
        .I2(b_IBUF[8]),
        .I3(a_IBUF[8]),
        .I4(b_IBUF[7]),
        .I5(a_IBUF[7]),
        .O(eq_OBUF_inst_i_6_n_0));
  LUT6 #(
    .INIT(64'h9009000000009009)) 
    eq_OBUF_inst_i_7
       (.I0(a_IBUF[3]),
        .I1(b_IBUF[3]),
        .I2(b_IBUF[5]),
        .I3(a_IBUF[5]),
        .I4(b_IBUF[4]),
        .I5(a_IBUF[4]),
        .O(eq_OBUF_inst_i_7_n_0));
  LUT6 #(
    .INIT(64'h9009000000009009)) 
    eq_OBUF_inst_i_8
       (.I0(a_IBUF[0]),
        .I1(b_IBUF[0]),
        .I2(b_IBUF[2]),
        .I3(a_IBUF[2]),
        .I4(b_IBUF[1]),
        .I5(a_IBUF[1]),
        .O(eq_OBUF_inst_i_8_n_0));
  OBUF illegal_OBUF_inst
       (.I(illegal_OBUF),
        .O(illegal));
  LUT3 #(
    .INIT(8'hA8)) 
    illegal_OBUF_inst_i_1
       (.I0(op_IBUF[2]),
        .I1(op_IBUF[0]),
        .I2(op_IBUF[1]),
        .O(illegal_OBUF));
  IBUF \op_IBUF[0]_inst 
       (.I(op[0]),
        .O(op_IBUF[0]));
  IBUF \op_IBUF[1]_inst 
       (.I(op[1]),
        .O(op_IBUF[1]));
  IBUF \op_IBUF[2]_inst 
       (.I(op[2]),
        .O(op_IBUF[2]));
  OBUF \result_OBUF[0]_inst 
       (.I(result_OBUF[0]),
        .O(result[0]));
  LUT6 #(
    .INIT(64'h0A0A0A0A3A3A3A0A)) 
    \result_OBUF[0]_inst_i_1 
       (.I0(\result_OBUF[0]_inst_i_2_n_0 ),
        .I1(op_IBUF[1]),
        .I2(op_IBUF[2]),
        .I3(b_IBUF[0]),
        .I4(a_IBUF[0]),
        .I5(op_IBUF[0]),
        .O(result_OBUF[0]));
  LUT6 #(
    .INIT(64'hAFA0CFCF0F00C0C0)) 
    \result_OBUF[0]_inst_i_2 
       (.I0(a_IBUF[0]),
        .I1(data2[0]),
        .I2(op_IBUF[1]),
        .I3(data1[0]),
        .I4(op_IBUF[0]),
        .I5(b_IBUF[0]),
        .O(\result_OBUF[0]_inst_i_2_n_0 ));
  OBUF \result_OBUF[10]_inst 
       (.I(result_OBUF[10]),
        .O(result[10]));
  LUT6 #(
    .INIT(64'h0A0A0A0A3A3A3A0A)) 
    \result_OBUF[10]_inst_i_1 
       (.I0(\result_OBUF[10]_inst_i_2_n_0 ),
        .I1(op_IBUF[1]),
        .I2(op_IBUF[2]),
        .I3(b_IBUF[10]),
        .I4(a_IBUF[10]),
        .I5(op_IBUF[0]),
        .O(result_OBUF[10]));
  LUT6 #(
    .INIT(64'hAFA0CFCF0F00C0C0)) 
    \result_OBUF[10]_inst_i_2 
       (.I0(a_IBUF[10]),
        .I1(data2[10]),
        .I2(op_IBUF[1]),
        .I3(data1[10]),
        .I4(op_IBUF[0]),
        .I5(b_IBUF[10]),
        .O(\result_OBUF[10]_inst_i_2_n_0 ));
  OBUF \result_OBUF[11]_inst 
       (.I(result_OBUF[11]),
        .O(result[11]));
  LUT6 #(
    .INIT(64'h0A0A0A0A3A3A3A0A)) 
    \result_OBUF[11]_inst_i_1 
       (.I0(\result_OBUF[11]_inst_i_2_n_0 ),
        .I1(op_IBUF[1]),
        .I2(op_IBUF[2]),
        .I3(b_IBUF[11]),
        .I4(a_IBUF[11]),
        .I5(op_IBUF[0]),
        .O(result_OBUF[11]));
  LUT2 #(
    .INIT(4'h6)) 
    \result_OBUF[11]_inst_i_10 
       (.I0(a_IBUF[10]),
        .I1(b_IBUF[10]),
        .O(\result_OBUF[11]_inst_i_10_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \result_OBUF[11]_inst_i_11 
       (.I0(a_IBUF[9]),
        .I1(b_IBUF[9]),
        .O(\result_OBUF[11]_inst_i_11_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \result_OBUF[11]_inst_i_12 
       (.I0(a_IBUF[8]),
        .I1(b_IBUF[8]),
        .O(\result_OBUF[11]_inst_i_12_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCF0F00C0C0)) 
    \result_OBUF[11]_inst_i_2 
       (.I0(a_IBUF[11]),
        .I1(data2[11]),
        .I2(op_IBUF[1]),
        .I3(data1[11]),
        .I4(op_IBUF[0]),
        .I5(b_IBUF[11]),
        .O(\result_OBUF[11]_inst_i_2_n_0 ));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \result_OBUF[11]_inst_i_3 
       (.CI(\result_OBUF[7]_inst_i_3_n_0 ),
        .CO({\result_OBUF[11]_inst_i_3_n_0 ,\result_OBUF[11]_inst_i_3_n_1 ,\result_OBUF[11]_inst_i_3_n_2 ,\result_OBUF[11]_inst_i_3_n_3 }),
        .CYINIT(1'b0),
        .DI(a_IBUF[11:8]),
        .O(data2[11:8]),
        .S({\result_OBUF[11]_inst_i_5_n_0 ,\result_OBUF[11]_inst_i_6_n_0 ,\result_OBUF[11]_inst_i_7_n_0 ,\result_OBUF[11]_inst_i_8_n_0 }));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \result_OBUF[11]_inst_i_4 
       (.CI(\result_OBUF[7]_inst_i_4_n_0 ),
        .CO({\result_OBUF[11]_inst_i_4_n_0 ,\result_OBUF[11]_inst_i_4_n_1 ,\result_OBUF[11]_inst_i_4_n_2 ,\result_OBUF[11]_inst_i_4_n_3 }),
        .CYINIT(1'b0),
        .DI(a_IBUF[11:8]),
        .O(data1[11:8]),
        .S({\result_OBUF[11]_inst_i_9_n_0 ,\result_OBUF[11]_inst_i_10_n_0 ,\result_OBUF[11]_inst_i_11_n_0 ,\result_OBUF[11]_inst_i_12_n_0 }));
  LUT2 #(
    .INIT(4'h9)) 
    \result_OBUF[11]_inst_i_5 
       (.I0(b_IBUF[11]),
        .I1(a_IBUF[11]),
        .O(\result_OBUF[11]_inst_i_5_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \result_OBUF[11]_inst_i_6 
       (.I0(b_IBUF[10]),
        .I1(a_IBUF[10]),
        .O(\result_OBUF[11]_inst_i_6_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \result_OBUF[11]_inst_i_7 
       (.I0(b_IBUF[9]),
        .I1(a_IBUF[9]),
        .O(\result_OBUF[11]_inst_i_7_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \result_OBUF[11]_inst_i_8 
       (.I0(b_IBUF[8]),
        .I1(a_IBUF[8]),
        .O(\result_OBUF[11]_inst_i_8_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \result_OBUF[11]_inst_i_9 
       (.I0(a_IBUF[11]),
        .I1(b_IBUF[11]),
        .O(\result_OBUF[11]_inst_i_9_n_0 ));
  OBUF \result_OBUF[12]_inst 
       (.I(result_OBUF[12]),
        .O(result[12]));
  LUT6 #(
    .INIT(64'h0A0A0A0A3A3A3A0A)) 
    \result_OBUF[12]_inst_i_1 
       (.I0(\result_OBUF[12]_inst_i_2_n_0 ),
        .I1(op_IBUF[1]),
        .I2(op_IBUF[2]),
        .I3(b_IBUF[12]),
        .I4(a_IBUF[12]),
        .I5(op_IBUF[0]),
        .O(result_OBUF[12]));
  LUT6 #(
    .INIT(64'hAFA0CFCF0F00C0C0)) 
    \result_OBUF[12]_inst_i_2 
       (.I0(a_IBUF[12]),
        .I1(data2[12]),
        .I2(op_IBUF[1]),
        .I3(data1[12]),
        .I4(op_IBUF[0]),
        .I5(b_IBUF[12]),
        .O(\result_OBUF[12]_inst_i_2_n_0 ));
  OBUF \result_OBUF[13]_inst 
       (.I(result_OBUF[13]),
        .O(result[13]));
  LUT6 #(
    .INIT(64'h0A0A0A0A3A3A3A0A)) 
    \result_OBUF[13]_inst_i_1 
       (.I0(\result_OBUF[13]_inst_i_2_n_0 ),
        .I1(op_IBUF[1]),
        .I2(op_IBUF[2]),
        .I3(b_IBUF[13]),
        .I4(a_IBUF[13]),
        .I5(op_IBUF[0]),
        .O(result_OBUF[13]));
  LUT6 #(
    .INIT(64'hAFA0CFCF0F00C0C0)) 
    \result_OBUF[13]_inst_i_2 
       (.I0(a_IBUF[13]),
        .I1(data2[13]),
        .I2(op_IBUF[1]),
        .I3(data1[13]),
        .I4(op_IBUF[0]),
        .I5(b_IBUF[13]),
        .O(\result_OBUF[13]_inst_i_2_n_0 ));
  OBUF \result_OBUF[14]_inst 
       (.I(result_OBUF[14]),
        .O(result[14]));
  LUT6 #(
    .INIT(64'h0A0A0A0A3A3A3A0A)) 
    \result_OBUF[14]_inst_i_1 
       (.I0(\result_OBUF[14]_inst_i_2_n_0 ),
        .I1(op_IBUF[1]),
        .I2(op_IBUF[2]),
        .I3(b_IBUF[14]),
        .I4(a_IBUF[14]),
        .I5(op_IBUF[0]),
        .O(result_OBUF[14]));
  LUT6 #(
    .INIT(64'hAFA0CFCF0F00C0C0)) 
    \result_OBUF[14]_inst_i_2 
       (.I0(a_IBUF[14]),
        .I1(data2[14]),
        .I2(op_IBUF[1]),
        .I3(data1[14]),
        .I4(op_IBUF[0]),
        .I5(b_IBUF[14]),
        .O(\result_OBUF[14]_inst_i_2_n_0 ));
  OBUF \result_OBUF[15]_inst 
       (.I(result_OBUF[15]),
        .O(result[15]));
  LUT6 #(
    .INIT(64'h0A0A0A0A3A3A3A0A)) 
    \result_OBUF[15]_inst_i_1 
       (.I0(\result_OBUF[15]_inst_i_2_n_0 ),
        .I1(op_IBUF[1]),
        .I2(op_IBUF[2]),
        .I3(b_IBUF[15]),
        .I4(a_IBUF[15]),
        .I5(op_IBUF[0]),
        .O(result_OBUF[15]));
  LUT2 #(
    .INIT(4'h6)) 
    \result_OBUF[15]_inst_i_10 
       (.I0(a_IBUF[14]),
        .I1(b_IBUF[14]),
        .O(\result_OBUF[15]_inst_i_10_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \result_OBUF[15]_inst_i_11 
       (.I0(a_IBUF[13]),
        .I1(b_IBUF[13]),
        .O(\result_OBUF[15]_inst_i_11_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \result_OBUF[15]_inst_i_12 
       (.I0(a_IBUF[12]),
        .I1(b_IBUF[12]),
        .O(\result_OBUF[15]_inst_i_12_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCF0F00C0C0)) 
    \result_OBUF[15]_inst_i_2 
       (.I0(a_IBUF[15]),
        .I1(data2[15]),
        .I2(op_IBUF[1]),
        .I3(data1[15]),
        .I4(op_IBUF[0]),
        .I5(b_IBUF[15]),
        .O(\result_OBUF[15]_inst_i_2_n_0 ));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \result_OBUF[15]_inst_i_3 
       (.CI(\result_OBUF[11]_inst_i_3_n_0 ),
        .CO({\NLW_result_OBUF[15]_inst_i_3_CO_UNCONNECTED [3],\result_OBUF[15]_inst_i_3_n_1 ,\result_OBUF[15]_inst_i_3_n_2 ,\result_OBUF[15]_inst_i_3_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,a_IBUF[14:12]}),
        .O(data2[15:12]),
        .S({\result_OBUF[15]_inst_i_5_n_0 ,\result_OBUF[15]_inst_i_6_n_0 ,\result_OBUF[15]_inst_i_7_n_0 ,\result_OBUF[15]_inst_i_8_n_0 }));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \result_OBUF[15]_inst_i_4 
       (.CI(\result_OBUF[11]_inst_i_4_n_0 ),
        .CO({\NLW_result_OBUF[15]_inst_i_4_CO_UNCONNECTED [3],\result_OBUF[15]_inst_i_4_n_1 ,\result_OBUF[15]_inst_i_4_n_2 ,\result_OBUF[15]_inst_i_4_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,a_IBUF[14:12]}),
        .O(data1[15:12]),
        .S({\result_OBUF[15]_inst_i_9_n_0 ,\result_OBUF[15]_inst_i_10_n_0 ,\result_OBUF[15]_inst_i_11_n_0 ,\result_OBUF[15]_inst_i_12_n_0 }));
  LUT2 #(
    .INIT(4'h9)) 
    \result_OBUF[15]_inst_i_5 
       (.I0(b_IBUF[15]),
        .I1(a_IBUF[15]),
        .O(\result_OBUF[15]_inst_i_5_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \result_OBUF[15]_inst_i_6 
       (.I0(b_IBUF[14]),
        .I1(a_IBUF[14]),
        .O(\result_OBUF[15]_inst_i_6_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \result_OBUF[15]_inst_i_7 
       (.I0(b_IBUF[13]),
        .I1(a_IBUF[13]),
        .O(\result_OBUF[15]_inst_i_7_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \result_OBUF[15]_inst_i_8 
       (.I0(b_IBUF[12]),
        .I1(a_IBUF[12]),
        .O(\result_OBUF[15]_inst_i_8_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \result_OBUF[15]_inst_i_9 
       (.I0(a_IBUF[15]),
        .I1(b_IBUF[15]),
        .O(\result_OBUF[15]_inst_i_9_n_0 ));
  OBUF \result_OBUF[1]_inst 
       (.I(result_OBUF[1]),
        .O(result[1]));
  LUT6 #(
    .INIT(64'h0A0A0A0A3A3A3A0A)) 
    \result_OBUF[1]_inst_i_1 
       (.I0(\result_OBUF[1]_inst_i_2_n_0 ),
        .I1(op_IBUF[1]),
        .I2(op_IBUF[2]),
        .I3(b_IBUF[1]),
        .I4(a_IBUF[1]),
        .I5(op_IBUF[0]),
        .O(result_OBUF[1]));
  LUT6 #(
    .INIT(64'hAFA0CFCF0F00C0C0)) 
    \result_OBUF[1]_inst_i_2 
       (.I0(a_IBUF[1]),
        .I1(data2[1]),
        .I2(op_IBUF[1]),
        .I3(data1[1]),
        .I4(op_IBUF[0]),
        .I5(b_IBUF[1]),
        .O(\result_OBUF[1]_inst_i_2_n_0 ));
  OBUF \result_OBUF[2]_inst 
       (.I(result_OBUF[2]),
        .O(result[2]));
  LUT6 #(
    .INIT(64'h0A0A0A0A3A3A3A0A)) 
    \result_OBUF[2]_inst_i_1 
       (.I0(\result_OBUF[2]_inst_i_2_n_0 ),
        .I1(op_IBUF[1]),
        .I2(op_IBUF[2]),
        .I3(b_IBUF[2]),
        .I4(a_IBUF[2]),
        .I5(op_IBUF[0]),
        .O(result_OBUF[2]));
  LUT6 #(
    .INIT(64'hAFA0CFCF0F00C0C0)) 
    \result_OBUF[2]_inst_i_2 
       (.I0(a_IBUF[2]),
        .I1(data2[2]),
        .I2(op_IBUF[1]),
        .I3(data1[2]),
        .I4(op_IBUF[0]),
        .I5(b_IBUF[2]),
        .O(\result_OBUF[2]_inst_i_2_n_0 ));
  OBUF \result_OBUF[3]_inst 
       (.I(result_OBUF[3]),
        .O(result[3]));
  LUT6 #(
    .INIT(64'h0A0A0A0A3A3A3A0A)) 
    \result_OBUF[3]_inst_i_1 
       (.I0(\result_OBUF[3]_inst_i_2_n_0 ),
        .I1(op_IBUF[1]),
        .I2(op_IBUF[2]),
        .I3(b_IBUF[3]),
        .I4(a_IBUF[3]),
        .I5(op_IBUF[0]),
        .O(result_OBUF[3]));
  LUT2 #(
    .INIT(4'h6)) 
    \result_OBUF[3]_inst_i_10 
       (.I0(a_IBUF[2]),
        .I1(b_IBUF[2]),
        .O(\result_OBUF[3]_inst_i_10_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \result_OBUF[3]_inst_i_11 
       (.I0(a_IBUF[1]),
        .I1(b_IBUF[1]),
        .O(\result_OBUF[3]_inst_i_11_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \result_OBUF[3]_inst_i_12 
       (.I0(a_IBUF[0]),
        .I1(b_IBUF[0]),
        .O(\result_OBUF[3]_inst_i_12_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCF0F00C0C0)) 
    \result_OBUF[3]_inst_i_2 
       (.I0(a_IBUF[3]),
        .I1(data2[3]),
        .I2(op_IBUF[1]),
        .I3(data1[3]),
        .I4(op_IBUF[0]),
        .I5(b_IBUF[3]),
        .O(\result_OBUF[3]_inst_i_2_n_0 ));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \result_OBUF[3]_inst_i_3 
       (.CI(1'b0),
        .CO({\result_OBUF[3]_inst_i_3_n_0 ,\result_OBUF[3]_inst_i_3_n_1 ,\result_OBUF[3]_inst_i_3_n_2 ,\result_OBUF[3]_inst_i_3_n_3 }),
        .CYINIT(1'b1),
        .DI(a_IBUF[3:0]),
        .O(data2[3:0]),
        .S({\result_OBUF[3]_inst_i_5_n_0 ,\result_OBUF[3]_inst_i_6_n_0 ,\result_OBUF[3]_inst_i_7_n_0 ,\result_OBUF[3]_inst_i_8_n_0 }));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \result_OBUF[3]_inst_i_4 
       (.CI(1'b0),
        .CO({\result_OBUF[3]_inst_i_4_n_0 ,\result_OBUF[3]_inst_i_4_n_1 ,\result_OBUF[3]_inst_i_4_n_2 ,\result_OBUF[3]_inst_i_4_n_3 }),
        .CYINIT(1'b0),
        .DI(a_IBUF[3:0]),
        .O(data1[3:0]),
        .S({\result_OBUF[3]_inst_i_9_n_0 ,\result_OBUF[3]_inst_i_10_n_0 ,\result_OBUF[3]_inst_i_11_n_0 ,\result_OBUF[3]_inst_i_12_n_0 }));
  LUT2 #(
    .INIT(4'h9)) 
    \result_OBUF[3]_inst_i_5 
       (.I0(b_IBUF[3]),
        .I1(a_IBUF[3]),
        .O(\result_OBUF[3]_inst_i_5_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \result_OBUF[3]_inst_i_6 
       (.I0(b_IBUF[2]),
        .I1(a_IBUF[2]),
        .O(\result_OBUF[3]_inst_i_6_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \result_OBUF[3]_inst_i_7 
       (.I0(b_IBUF[1]),
        .I1(a_IBUF[1]),
        .O(\result_OBUF[3]_inst_i_7_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \result_OBUF[3]_inst_i_8 
       (.I0(b_IBUF[0]),
        .I1(a_IBUF[0]),
        .O(\result_OBUF[3]_inst_i_8_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \result_OBUF[3]_inst_i_9 
       (.I0(a_IBUF[3]),
        .I1(b_IBUF[3]),
        .O(\result_OBUF[3]_inst_i_9_n_0 ));
  OBUF \result_OBUF[4]_inst 
       (.I(result_OBUF[4]),
        .O(result[4]));
  LUT6 #(
    .INIT(64'h0A0A0A0A3A3A3A0A)) 
    \result_OBUF[4]_inst_i_1 
       (.I0(\result_OBUF[4]_inst_i_2_n_0 ),
        .I1(op_IBUF[1]),
        .I2(op_IBUF[2]),
        .I3(b_IBUF[4]),
        .I4(a_IBUF[4]),
        .I5(op_IBUF[0]),
        .O(result_OBUF[4]));
  LUT6 #(
    .INIT(64'hAFA0CFCF0F00C0C0)) 
    \result_OBUF[4]_inst_i_2 
       (.I0(a_IBUF[4]),
        .I1(data2[4]),
        .I2(op_IBUF[1]),
        .I3(data1[4]),
        .I4(op_IBUF[0]),
        .I5(b_IBUF[4]),
        .O(\result_OBUF[4]_inst_i_2_n_0 ));
  OBUF \result_OBUF[5]_inst 
       (.I(result_OBUF[5]),
        .O(result[5]));
  LUT6 #(
    .INIT(64'h0A0A0A0A3A3A3A0A)) 
    \result_OBUF[5]_inst_i_1 
       (.I0(\result_OBUF[5]_inst_i_2_n_0 ),
        .I1(op_IBUF[1]),
        .I2(op_IBUF[2]),
        .I3(b_IBUF[5]),
        .I4(a_IBUF[5]),
        .I5(op_IBUF[0]),
        .O(result_OBUF[5]));
  LUT6 #(
    .INIT(64'hAFA0CFCF0F00C0C0)) 
    \result_OBUF[5]_inst_i_2 
       (.I0(a_IBUF[5]),
        .I1(data2[5]),
        .I2(op_IBUF[1]),
        .I3(data1[5]),
        .I4(op_IBUF[0]),
        .I5(b_IBUF[5]),
        .O(\result_OBUF[5]_inst_i_2_n_0 ));
  OBUF \result_OBUF[6]_inst 
       (.I(result_OBUF[6]),
        .O(result[6]));
  LUT6 #(
    .INIT(64'h0A0A0A0A3A3A3A0A)) 
    \result_OBUF[6]_inst_i_1 
       (.I0(\result_OBUF[6]_inst_i_2_n_0 ),
        .I1(op_IBUF[1]),
        .I2(op_IBUF[2]),
        .I3(b_IBUF[6]),
        .I4(a_IBUF[6]),
        .I5(op_IBUF[0]),
        .O(result_OBUF[6]));
  LUT6 #(
    .INIT(64'hAFA0CFCF0F00C0C0)) 
    \result_OBUF[6]_inst_i_2 
       (.I0(a_IBUF[6]),
        .I1(data2[6]),
        .I2(op_IBUF[1]),
        .I3(data1[6]),
        .I4(op_IBUF[0]),
        .I5(b_IBUF[6]),
        .O(\result_OBUF[6]_inst_i_2_n_0 ));
  OBUF \result_OBUF[7]_inst 
       (.I(result_OBUF[7]),
        .O(result[7]));
  LUT6 #(
    .INIT(64'h0A0A0A0A3A3A3A0A)) 
    \result_OBUF[7]_inst_i_1 
       (.I0(\result_OBUF[7]_inst_i_2_n_0 ),
        .I1(op_IBUF[1]),
        .I2(op_IBUF[2]),
        .I3(b_IBUF[7]),
        .I4(a_IBUF[7]),
        .I5(op_IBUF[0]),
        .O(result_OBUF[7]));
  LUT2 #(
    .INIT(4'h6)) 
    \result_OBUF[7]_inst_i_10 
       (.I0(a_IBUF[6]),
        .I1(b_IBUF[6]),
        .O(\result_OBUF[7]_inst_i_10_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \result_OBUF[7]_inst_i_11 
       (.I0(a_IBUF[5]),
        .I1(b_IBUF[5]),
        .O(\result_OBUF[7]_inst_i_11_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \result_OBUF[7]_inst_i_12 
       (.I0(a_IBUF[4]),
        .I1(b_IBUF[4]),
        .O(\result_OBUF[7]_inst_i_12_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCF0F00C0C0)) 
    \result_OBUF[7]_inst_i_2 
       (.I0(a_IBUF[7]),
        .I1(data2[7]),
        .I2(op_IBUF[1]),
        .I3(data1[7]),
        .I4(op_IBUF[0]),
        .I5(b_IBUF[7]),
        .O(\result_OBUF[7]_inst_i_2_n_0 ));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \result_OBUF[7]_inst_i_3 
       (.CI(\result_OBUF[3]_inst_i_3_n_0 ),
        .CO({\result_OBUF[7]_inst_i_3_n_0 ,\result_OBUF[7]_inst_i_3_n_1 ,\result_OBUF[7]_inst_i_3_n_2 ,\result_OBUF[7]_inst_i_3_n_3 }),
        .CYINIT(1'b0),
        .DI(a_IBUF[7:4]),
        .O(data2[7:4]),
        .S({\result_OBUF[7]_inst_i_5_n_0 ,\result_OBUF[7]_inst_i_6_n_0 ,\result_OBUF[7]_inst_i_7_n_0 ,\result_OBUF[7]_inst_i_8_n_0 }));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \result_OBUF[7]_inst_i_4 
       (.CI(\result_OBUF[3]_inst_i_4_n_0 ),
        .CO({\result_OBUF[7]_inst_i_4_n_0 ,\result_OBUF[7]_inst_i_4_n_1 ,\result_OBUF[7]_inst_i_4_n_2 ,\result_OBUF[7]_inst_i_4_n_3 }),
        .CYINIT(1'b0),
        .DI(a_IBUF[7:4]),
        .O(data1[7:4]),
        .S({\result_OBUF[7]_inst_i_9_n_0 ,\result_OBUF[7]_inst_i_10_n_0 ,\result_OBUF[7]_inst_i_11_n_0 ,\result_OBUF[7]_inst_i_12_n_0 }));
  LUT2 #(
    .INIT(4'h9)) 
    \result_OBUF[7]_inst_i_5 
       (.I0(b_IBUF[7]),
        .I1(a_IBUF[7]),
        .O(\result_OBUF[7]_inst_i_5_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \result_OBUF[7]_inst_i_6 
       (.I0(b_IBUF[6]),
        .I1(a_IBUF[6]),
        .O(\result_OBUF[7]_inst_i_6_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \result_OBUF[7]_inst_i_7 
       (.I0(b_IBUF[5]),
        .I1(a_IBUF[5]),
        .O(\result_OBUF[7]_inst_i_7_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \result_OBUF[7]_inst_i_8 
       (.I0(b_IBUF[4]),
        .I1(a_IBUF[4]),
        .O(\result_OBUF[7]_inst_i_8_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \result_OBUF[7]_inst_i_9 
       (.I0(a_IBUF[7]),
        .I1(b_IBUF[7]),
        .O(\result_OBUF[7]_inst_i_9_n_0 ));
  OBUF \result_OBUF[8]_inst 
       (.I(result_OBUF[8]),
        .O(result[8]));
  LUT6 #(
    .INIT(64'h0A0A0A0A3A3A3A0A)) 
    \result_OBUF[8]_inst_i_1 
       (.I0(\result_OBUF[8]_inst_i_2_n_0 ),
        .I1(op_IBUF[1]),
        .I2(op_IBUF[2]),
        .I3(b_IBUF[8]),
        .I4(a_IBUF[8]),
        .I5(op_IBUF[0]),
        .O(result_OBUF[8]));
  LUT6 #(
    .INIT(64'hAFA0CFCF0F00C0C0)) 
    \result_OBUF[8]_inst_i_2 
       (.I0(a_IBUF[8]),
        .I1(data2[8]),
        .I2(op_IBUF[1]),
        .I3(data1[8]),
        .I4(op_IBUF[0]),
        .I5(b_IBUF[8]),
        .O(\result_OBUF[8]_inst_i_2_n_0 ));
  OBUF \result_OBUF[9]_inst 
       (.I(result_OBUF[9]),
        .O(result[9]));
  LUT6 #(
    .INIT(64'h0A0A0A0A3A3A3A0A)) 
    \result_OBUF[9]_inst_i_1 
       (.I0(\result_OBUF[9]_inst_i_2_n_0 ),
        .I1(op_IBUF[1]),
        .I2(op_IBUF[2]),
        .I3(b_IBUF[9]),
        .I4(a_IBUF[9]),
        .I5(op_IBUF[0]),
        .O(result_OBUF[9]));
  LUT6 #(
    .INIT(64'hAFA0CFCF0F00C0C0)) 
    \result_OBUF[9]_inst_i_2 
       (.I0(a_IBUF[9]),
        .I1(data2[9]),
        .I2(op_IBUF[1]),
        .I3(data1[9]),
        .I4(op_IBUF[0]),
        .I5(b_IBUF[9]),
        .O(\result_OBUF[9]_inst_i_2_n_0 ));
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
