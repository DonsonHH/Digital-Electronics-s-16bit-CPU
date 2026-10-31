// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2025.2 (win64) Build 6299465 Fri Nov 14 19:35:11 GMT 2025
// Date        : Wed Oct 14 01:06:53 2026
// Host        : LAPTOP-BSM79J69 running 64-bit major release  (build 9200)
// Command     : write_verilog -mode funcsim post_synth_netlist.v
// Design      : datapath_core
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z020clg484-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module addsub16_cla
   (a,
    b,
    sub,
    result,
    carry,
    overflow);
  input [15:0]a;
  input [15:0]b;
  input sub;
  output [15:0]result;
  output carry;
  output overflow;

  wire [15:0]a;
  wire [15:0]b;
  wire carry;
  wire overflow;
  wire [0:0]p_0_in;
  wire [15:0]result;
  wire \result[0]_INST_0_i_2_n_0 ;
  wire \result[0]_INST_0_i_3_n_0 ;
  wire \result[0]_INST_0_i_4_n_0 ;
  wire \result[0]_INST_0_i_5_n_0 ;
  wire \result[0]_INST_0_n_0 ;
  wire \result[0]_INST_0_n_1 ;
  wire \result[0]_INST_0_n_2 ;
  wire \result[0]_INST_0_n_3 ;
  wire \result[12]_INST_0_i_1_n_0 ;
  wire \result[12]_INST_0_i_2_n_0 ;
  wire \result[12]_INST_0_i_3_n_0 ;
  wire \result[12]_INST_0_i_4_n_0 ;
  wire \result[12]_INST_0_n_0 ;
  wire \result[12]_INST_0_n_1 ;
  wire \result[12]_INST_0_n_2 ;
  wire \result[12]_INST_0_n_3 ;
  wire \result[4]_INST_0_i_1_n_0 ;
  wire \result[4]_INST_0_i_2_n_0 ;
  wire \result[4]_INST_0_i_3_n_0 ;
  wire \result[4]_INST_0_i_4_n_0 ;
  wire \result[4]_INST_0_n_0 ;
  wire \result[4]_INST_0_n_1 ;
  wire \result[4]_INST_0_n_2 ;
  wire \result[4]_INST_0_n_3 ;
  wire \result[8]_INST_0_i_1_n_0 ;
  wire \result[8]_INST_0_i_2_n_0 ;
  wire \result[8]_INST_0_i_3_n_0 ;
  wire \result[8]_INST_0_i_4_n_0 ;
  wire \result[8]_INST_0_n_0 ;
  wire \result[8]_INST_0_n_1 ;
  wire \result[8]_INST_0_n_2 ;
  wire \result[8]_INST_0_n_3 ;
  wire sub;
  wire [3:0]NLW_carry_INST_0_CO_UNCONNECTED;
  wire [3:1]NLW_carry_INST_0_O_UNCONNECTED;

  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 carry_INST_0
       (.CI(\result[12]_INST_0_n_0 ),
        .CO(NLW_carry_INST_0_CO_UNCONNECTED[3:0]),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({NLW_carry_INST_0_O_UNCONNECTED[3:1],carry}),
        .S({1'b0,1'b0,1'b0,1'b0}));
  LUT4 #(
    .INIT(16'h1824)) 
    overflow_INST_0
       (.I0(sub),
        .I1(result[15]),
        .I2(a[15]),
        .I3(b[15]),
        .O(overflow));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \result[0]_INST_0 
       (.CI(1'b0),
        .CO({\result[0]_INST_0_n_0 ,\result[0]_INST_0_n_1 ,\result[0]_INST_0_n_2 ,\result[0]_INST_0_n_3 }),
        .CYINIT(p_0_in),
        .DI(a[3:0]),
        .O(result[3:0]),
        .S({\result[0]_INST_0_i_2_n_0 ,\result[0]_INST_0_i_3_n_0 ,\result[0]_INST_0_i_4_n_0 ,\result[0]_INST_0_i_5_n_0 }));
  LUT2 #(
    .INIT(4'h6)) 
    \result[0]_INST_0_i_1 
       (.I0(sub),
        .I1(b[0]),
        .O(p_0_in));
  LUT3 #(
    .INIT(8'h96)) 
    \result[0]_INST_0_i_2 
       (.I0(a[3]),
        .I1(b[3]),
        .I2(sub),
        .O(\result[0]_INST_0_i_2_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \result[0]_INST_0_i_3 
       (.I0(a[2]),
        .I1(b[2]),
        .I2(sub),
        .O(\result[0]_INST_0_i_3_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \result[0]_INST_0_i_4 
       (.I0(a[1]),
        .I1(b[1]),
        .I2(sub),
        .O(\result[0]_INST_0_i_4_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \result[0]_INST_0_i_5 
       (.I0(a[0]),
        .I1(sub),
        .O(\result[0]_INST_0_i_5_n_0 ));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \result[12]_INST_0 
       (.CI(\result[8]_INST_0_n_0 ),
        .CO({\result[12]_INST_0_n_0 ,\result[12]_INST_0_n_1 ,\result[12]_INST_0_n_2 ,\result[12]_INST_0_n_3 }),
        .CYINIT(1'b0),
        .DI(a[15:12]),
        .O(result[15:12]),
        .S({\result[12]_INST_0_i_1_n_0 ,\result[12]_INST_0_i_2_n_0 ,\result[12]_INST_0_i_3_n_0 ,\result[12]_INST_0_i_4_n_0 }));
  LUT3 #(
    .INIT(8'h96)) 
    \result[12]_INST_0_i_1 
       (.I0(a[15]),
        .I1(b[15]),
        .I2(sub),
        .O(\result[12]_INST_0_i_1_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \result[12]_INST_0_i_2 
       (.I0(a[14]),
        .I1(b[14]),
        .I2(sub),
        .O(\result[12]_INST_0_i_2_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \result[12]_INST_0_i_3 
       (.I0(a[13]),
        .I1(b[13]),
        .I2(sub),
        .O(\result[12]_INST_0_i_3_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \result[12]_INST_0_i_4 
       (.I0(a[12]),
        .I1(b[12]),
        .I2(sub),
        .O(\result[12]_INST_0_i_4_n_0 ));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \result[4]_INST_0 
       (.CI(\result[0]_INST_0_n_0 ),
        .CO({\result[4]_INST_0_n_0 ,\result[4]_INST_0_n_1 ,\result[4]_INST_0_n_2 ,\result[4]_INST_0_n_3 }),
        .CYINIT(1'b0),
        .DI(a[7:4]),
        .O(result[7:4]),
        .S({\result[4]_INST_0_i_1_n_0 ,\result[4]_INST_0_i_2_n_0 ,\result[4]_INST_0_i_3_n_0 ,\result[4]_INST_0_i_4_n_0 }));
  LUT3 #(
    .INIT(8'h96)) 
    \result[4]_INST_0_i_1 
       (.I0(a[7]),
        .I1(b[7]),
        .I2(sub),
        .O(\result[4]_INST_0_i_1_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \result[4]_INST_0_i_2 
       (.I0(a[6]),
        .I1(b[6]),
        .I2(sub),
        .O(\result[4]_INST_0_i_2_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \result[4]_INST_0_i_3 
       (.I0(a[5]),
        .I1(b[5]),
        .I2(sub),
        .O(\result[4]_INST_0_i_3_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \result[4]_INST_0_i_4 
       (.I0(a[4]),
        .I1(b[4]),
        .I2(sub),
        .O(\result[4]_INST_0_i_4_n_0 ));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \result[8]_INST_0 
       (.CI(\result[4]_INST_0_n_0 ),
        .CO({\result[8]_INST_0_n_0 ,\result[8]_INST_0_n_1 ,\result[8]_INST_0_n_2 ,\result[8]_INST_0_n_3 }),
        .CYINIT(1'b0),
        .DI(a[11:8]),
        .O(result[11:8]),
        .S({\result[8]_INST_0_i_1_n_0 ,\result[8]_INST_0_i_2_n_0 ,\result[8]_INST_0_i_3_n_0 ,\result[8]_INST_0_i_4_n_0 }));
  LUT3 #(
    .INIT(8'h96)) 
    \result[8]_INST_0_i_1 
       (.I0(a[11]),
        .I1(b[11]),
        .I2(sub),
        .O(\result[8]_INST_0_i_1_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \result[8]_INST_0_i_2 
       (.I0(a[10]),
        .I1(b[10]),
        .I2(sub),
        .O(\result[8]_INST_0_i_2_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \result[8]_INST_0_i_3 
       (.I0(a[9]),
        .I1(b[9]),
        .I2(sub),
        .O(\result[8]_INST_0_i_3_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \result[8]_INST_0_i_4 
       (.I0(a[8]),
        .I1(b[8]),
        .I2(sub),
        .O(\result[8]_INST_0_i_4_n_0 ));
endmodule

module alu16
   (a,
    b,
    op,
    result,
    eq,
    illegal,
    carry,
    overflow);
  input [15:0]a;
  input [15:0]b;
  input [2:0]op;
  output [15:0]result;
  output eq;
  output illegal;
  output carry;
  output overflow;

  wire [15:0]a;
  wire arithmetic_carry;
  wire arithmetic_overflow;
  wire [15:0]arithmetic_result;
  wire [15:0]b;
  wire carry;
  wire eq;
  wire eq_INST_0_i_1_n_0;
  wire eq_INST_0_i_1_n_1;
  wire eq_INST_0_i_1_n_2;
  wire eq_INST_0_i_1_n_3;
  wire eq_INST_0_i_2_n_0;
  wire eq_INST_0_i_3_n_0;
  wire eq_INST_0_i_4_n_0;
  wire eq_INST_0_i_5_n_0;
  wire eq_INST_0_i_6_n_0;
  wire eq_INST_0_i_7_n_0;
  wire eq_INST_0_n_3;
  wire illegal;
  wire [2:0]op;
  wire overflow;
  wire [15:0]result;
  wire u_addsub_i_1_n_0;
  wire [3:2]NLW_eq_INST_0_CO_UNCONNECTED;
  wire [3:0]NLW_eq_INST_0_O_UNCONNECTED;
  wire [3:0]NLW_eq_INST_0_i_1_O_UNCONNECTED;

  (* SOFT_HLUTNM = "soft_lutpair35" *) 
  LUT4 #(
    .INIT(16'h1400)) 
    carry_INST_0
       (.I0(op[2]),
        .I1(op[0]),
        .I2(op[1]),
        .I3(arithmetic_carry),
        .O(carry));
  CARRY4 eq_INST_0
       (.CI(eq_INST_0_i_1_n_0),
        .CO({NLW_eq_INST_0_CO_UNCONNECTED[3:2],eq,eq_INST_0_n_3}),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O(NLW_eq_INST_0_O_UNCONNECTED[3:0]),
        .S({1'b0,1'b0,eq_INST_0_i_2_n_0,eq_INST_0_i_3_n_0}));
  CARRY4 eq_INST_0_i_1
       (.CI(1'b0),
        .CO({eq_INST_0_i_1_n_0,eq_INST_0_i_1_n_1,eq_INST_0_i_1_n_2,eq_INST_0_i_1_n_3}),
        .CYINIT(1'b1),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O(NLW_eq_INST_0_i_1_O_UNCONNECTED[3:0]),
        .S({eq_INST_0_i_4_n_0,eq_INST_0_i_5_n_0,eq_INST_0_i_6_n_0,eq_INST_0_i_7_n_0}));
  LUT2 #(
    .INIT(4'h9)) 
    eq_INST_0_i_2
       (.I0(b[15]),
        .I1(a[15]),
        .O(eq_INST_0_i_2_n_0));
  LUT6 #(
    .INIT(64'h9009000000009009)) 
    eq_INST_0_i_3
       (.I0(a[12]),
        .I1(b[12]),
        .I2(b[14]),
        .I3(a[14]),
        .I4(b[13]),
        .I5(a[13]),
        .O(eq_INST_0_i_3_n_0));
  LUT6 #(
    .INIT(64'h9009000000009009)) 
    eq_INST_0_i_4
       (.I0(a[9]),
        .I1(b[9]),
        .I2(b[11]),
        .I3(a[11]),
        .I4(b[10]),
        .I5(a[10]),
        .O(eq_INST_0_i_4_n_0));
  LUT6 #(
    .INIT(64'h9009000000009009)) 
    eq_INST_0_i_5
       (.I0(a[6]),
        .I1(b[6]),
        .I2(b[8]),
        .I3(a[8]),
        .I4(b[7]),
        .I5(a[7]),
        .O(eq_INST_0_i_5_n_0));
  LUT6 #(
    .INIT(64'h9009000000009009)) 
    eq_INST_0_i_6
       (.I0(a[3]),
        .I1(b[3]),
        .I2(b[5]),
        .I3(a[5]),
        .I4(b[4]),
        .I5(a[4]),
        .O(eq_INST_0_i_6_n_0));
  LUT6 #(
    .INIT(64'h9009000000009009)) 
    eq_INST_0_i_7
       (.I0(a[0]),
        .I1(b[0]),
        .I2(b[2]),
        .I3(a[2]),
        .I4(b[1]),
        .I5(a[1]),
        .O(eq_INST_0_i_7_n_0));
  (* SOFT_HLUTNM = "soft_lutpair36" *) 
  LUT3 #(
    .INIT(8'hA8)) 
    illegal_INST_0
       (.I0(op[2]),
        .I1(op[1]),
        .I2(op[0]),
        .O(illegal));
  (* SOFT_HLUTNM = "soft_lutpair35" *) 
  LUT4 #(
    .INIT(16'h1400)) 
    overflow_INST_0
       (.I0(op[2]),
        .I1(op[0]),
        .I2(op[1]),
        .I3(arithmetic_overflow),
        .O(overflow));
  LUT6 #(
    .INIT(64'h0E0202023B383B08)) 
    \result[0]_INST_0 
       (.I0(arithmetic_result[0]),
        .I1(op[1]),
        .I2(op[2]),
        .I3(b[0]),
        .I4(a[0]),
        .I5(op[0]),
        .O(result[0]));
  LUT6 #(
    .INIT(64'h0E0202023B383B08)) 
    \result[10]_INST_0 
       (.I0(arithmetic_result[10]),
        .I1(op[1]),
        .I2(op[2]),
        .I3(b[10]),
        .I4(a[10]),
        .I5(op[0]),
        .O(result[10]));
  LUT6 #(
    .INIT(64'h0E0202023B383B08)) 
    \result[11]_INST_0 
       (.I0(arithmetic_result[11]),
        .I1(op[1]),
        .I2(op[2]),
        .I3(b[11]),
        .I4(a[11]),
        .I5(op[0]),
        .O(result[11]));
  LUT6 #(
    .INIT(64'h0E0202023B383B08)) 
    \result[12]_INST_0 
       (.I0(arithmetic_result[12]),
        .I1(op[1]),
        .I2(op[2]),
        .I3(b[12]),
        .I4(a[12]),
        .I5(op[0]),
        .O(result[12]));
  LUT6 #(
    .INIT(64'h0E0202023B383B08)) 
    \result[13]_INST_0 
       (.I0(arithmetic_result[13]),
        .I1(op[1]),
        .I2(op[2]),
        .I3(b[13]),
        .I4(a[13]),
        .I5(op[0]),
        .O(result[13]));
  LUT6 #(
    .INIT(64'h0E0202023B383B08)) 
    \result[14]_INST_0 
       (.I0(arithmetic_result[14]),
        .I1(op[1]),
        .I2(op[2]),
        .I3(b[14]),
        .I4(a[14]),
        .I5(op[0]),
        .O(result[14]));
  LUT6 #(
    .INIT(64'h0E0202023B383B08)) 
    \result[15]_INST_0 
       (.I0(arithmetic_result[15]),
        .I1(op[1]),
        .I2(op[2]),
        .I3(b[15]),
        .I4(a[15]),
        .I5(op[0]),
        .O(result[15]));
  LUT6 #(
    .INIT(64'h0E0202023B383B08)) 
    \result[1]_INST_0 
       (.I0(arithmetic_result[1]),
        .I1(op[1]),
        .I2(op[2]),
        .I3(b[1]),
        .I4(a[1]),
        .I5(op[0]),
        .O(result[1]));
  LUT6 #(
    .INIT(64'h0E0202023B383B08)) 
    \result[2]_INST_0 
       (.I0(arithmetic_result[2]),
        .I1(op[1]),
        .I2(op[2]),
        .I3(b[2]),
        .I4(a[2]),
        .I5(op[0]),
        .O(result[2]));
  LUT6 #(
    .INIT(64'h0E0202023B383B08)) 
    \result[3]_INST_0 
       (.I0(arithmetic_result[3]),
        .I1(op[1]),
        .I2(op[2]),
        .I3(b[3]),
        .I4(a[3]),
        .I5(op[0]),
        .O(result[3]));
  LUT6 #(
    .INIT(64'h0E0202023B383B08)) 
    \result[4]_INST_0 
       (.I0(arithmetic_result[4]),
        .I1(op[1]),
        .I2(op[2]),
        .I3(b[4]),
        .I4(a[4]),
        .I5(op[0]),
        .O(result[4]));
  LUT6 #(
    .INIT(64'h0E0202023B383B08)) 
    \result[5]_INST_0 
       (.I0(arithmetic_result[5]),
        .I1(op[1]),
        .I2(op[2]),
        .I3(b[5]),
        .I4(a[5]),
        .I5(op[0]),
        .O(result[5]));
  LUT6 #(
    .INIT(64'h0E0202023B383B08)) 
    \result[6]_INST_0 
       (.I0(arithmetic_result[6]),
        .I1(op[1]),
        .I2(op[2]),
        .I3(b[6]),
        .I4(a[6]),
        .I5(op[0]),
        .O(result[6]));
  LUT6 #(
    .INIT(64'h0E0202023B383B08)) 
    \result[7]_INST_0 
       (.I0(arithmetic_result[7]),
        .I1(op[1]),
        .I2(op[2]),
        .I3(b[7]),
        .I4(a[7]),
        .I5(op[0]),
        .O(result[7]));
  LUT6 #(
    .INIT(64'h0E0202023B383B08)) 
    \result[8]_INST_0 
       (.I0(arithmetic_result[8]),
        .I1(op[1]),
        .I2(op[2]),
        .I3(b[8]),
        .I4(a[8]),
        .I5(op[0]),
        .O(result[8]));
  LUT6 #(
    .INIT(64'h0E0202023B383B08)) 
    \result[9]_INST_0 
       (.I0(arithmetic_result[9]),
        .I1(op[1]),
        .I2(op[2]),
        .I3(b[9]),
        .I4(a[9]),
        .I5(op[0]),
        .O(result[9]));
  addsub16_cla u_addsub
       (.a(a),
        .b(b),
        .carry(arithmetic_carry),
        .overflow(arithmetic_overflow),
        .result(arithmetic_result),
        .sub(u_addsub_i_1_n_0));
  (* SOFT_HLUTNM = "soft_lutpair36" *) 
  LUT3 #(
    .INIT(8'h04)) 
    u_addsub_i_1
       (.I0(op[0]),
        .I1(op[1]),
        .I2(op[2]),
        .O(u_addsub_i_1_n_0));
endmodule

module branch_target16
   (branch_pc,
    imm,
    relative,
    target);
  input [15:0]branch_pc;
  input [7:0]imm;
  input relative;
  output [15:0]target;

  wire [15:0]branch_pc;
  wire [7:0]imm;
  wire relative;
  wire [15:0]target;
  wire [15:0]target0;
  wire \target[11]_INST_0_i_1_n_0 ;
  wire \target[11]_INST_0_i_1_n_1 ;
  wire \target[11]_INST_0_i_1_n_2 ;
  wire \target[11]_INST_0_i_1_n_3 ;
  wire \target[11]_INST_0_i_2_n_0 ;
  wire \target[11]_INST_0_i_3_n_0 ;
  wire \target[11]_INST_0_i_4_n_0 ;
  wire \target[11]_INST_0_i_5_n_0 ;
  wire \target[11]_INST_0_i_6_n_0 ;
  wire \target[15]_INST_0_i_1_n_1 ;
  wire \target[15]_INST_0_i_1_n_2 ;
  wire \target[15]_INST_0_i_1_n_3 ;
  wire \target[15]_INST_0_i_2_n_0 ;
  wire \target[15]_INST_0_i_3_n_0 ;
  wire \target[15]_INST_0_i_4_n_0 ;
  wire \target[15]_INST_0_i_5_n_0 ;
  wire \target[3]_INST_0_i_1_n_0 ;
  wire \target[3]_INST_0_i_1_n_1 ;
  wire \target[3]_INST_0_i_1_n_2 ;
  wire \target[3]_INST_0_i_1_n_3 ;
  wire \target[3]_INST_0_i_2_n_0 ;
  wire \target[3]_INST_0_i_3_n_0 ;
  wire \target[3]_INST_0_i_4_n_0 ;
  wire \target[3]_INST_0_i_5_n_0 ;
  wire \target[7]_INST_0_i_1_n_0 ;
  wire \target[7]_INST_0_i_1_n_1 ;
  wire \target[7]_INST_0_i_1_n_2 ;
  wire \target[7]_INST_0_i_1_n_3 ;
  wire \target[7]_INST_0_i_2_n_0 ;
  wire \target[7]_INST_0_i_3_n_0 ;
  wire \target[7]_INST_0_i_4_n_0 ;
  wire \target[7]_INST_0_i_5_n_0 ;
  wire [3:3]\NLW_target[15]_INST_0_i_1_CO_UNCONNECTED ;

  (* SOFT_HLUTNM = "soft_lutpair44" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \target[0]_INST_0 
       (.I0(target0[0]),
        .I1(imm[0]),
        .I2(relative),
        .O(target[0]));
  (* SOFT_HLUTNM = "soft_lutpair43" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \target[10]_INST_0 
       (.I0(relative),
        .I1(target0[10]),
        .O(target[10]));
  (* SOFT_HLUTNM = "soft_lutpair42" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \target[11]_INST_0 
       (.I0(relative),
        .I1(target0[11]),
        .O(target[11]));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \target[11]_INST_0_i_1 
       (.CI(\target[7]_INST_0_i_1_n_0 ),
        .CO({\target[11]_INST_0_i_1_n_0 ,\target[11]_INST_0_i_1_n_1 ,\target[11]_INST_0_i_1_n_2 ,\target[11]_INST_0_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({branch_pc[10:8],\target[11]_INST_0_i_2_n_0 }),
        .O(target0[11:8]),
        .S({\target[11]_INST_0_i_3_n_0 ,\target[11]_INST_0_i_4_n_0 ,\target[11]_INST_0_i_5_n_0 ,\target[11]_INST_0_i_6_n_0 }));
  LUT1 #(
    .INIT(2'h1)) 
    \target[11]_INST_0_i_2 
       (.I0(imm[7]),
        .O(\target[11]_INST_0_i_2_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \target[11]_INST_0_i_3 
       (.I0(branch_pc[10]),
        .I1(branch_pc[11]),
        .O(\target[11]_INST_0_i_3_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \target[11]_INST_0_i_4 
       (.I0(branch_pc[9]),
        .I1(branch_pc[10]),
        .O(\target[11]_INST_0_i_4_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \target[11]_INST_0_i_5 
       (.I0(branch_pc[8]),
        .I1(branch_pc[9]),
        .O(\target[11]_INST_0_i_5_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \target[11]_INST_0_i_6 
       (.I0(imm[7]),
        .I1(branch_pc[8]),
        .O(\target[11]_INST_0_i_6_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair40" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \target[12]_INST_0 
       (.I0(relative),
        .I1(target0[12]),
        .O(target[12]));
  (* SOFT_HLUTNM = "soft_lutpair37" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \target[13]_INST_0 
       (.I0(relative),
        .I1(target0[13]),
        .O(target[13]));
  (* SOFT_HLUTNM = "soft_lutpair39" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \target[14]_INST_0 
       (.I0(relative),
        .I1(target0[14]),
        .O(target[14]));
  (* SOFT_HLUTNM = "soft_lutpair38" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \target[15]_INST_0 
       (.I0(relative),
        .I1(target0[15]),
        .O(target[15]));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \target[15]_INST_0_i_1 
       (.CI(\target[11]_INST_0_i_1_n_0 ),
        .CO({\NLW_target[15]_INST_0_i_1_CO_UNCONNECTED [3],\target[15]_INST_0_i_1_n_1 ,\target[15]_INST_0_i_1_n_2 ,\target[15]_INST_0_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,branch_pc[13:11]}),
        .O(target0[15:12]),
        .S({\target[15]_INST_0_i_2_n_0 ,\target[15]_INST_0_i_3_n_0 ,\target[15]_INST_0_i_4_n_0 ,\target[15]_INST_0_i_5_n_0 }));
  LUT2 #(
    .INIT(4'h9)) 
    \target[15]_INST_0_i_2 
       (.I0(branch_pc[14]),
        .I1(branch_pc[15]),
        .O(\target[15]_INST_0_i_2_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \target[15]_INST_0_i_3 
       (.I0(branch_pc[13]),
        .I1(branch_pc[14]),
        .O(\target[15]_INST_0_i_3_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \target[15]_INST_0_i_4 
       (.I0(branch_pc[12]),
        .I1(branch_pc[13]),
        .O(\target[15]_INST_0_i_4_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \target[15]_INST_0_i_5 
       (.I0(branch_pc[11]),
        .I1(branch_pc[12]),
        .O(\target[15]_INST_0_i_5_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair43" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \target[1]_INST_0 
       (.I0(target0[1]),
        .I1(imm[1]),
        .I2(relative),
        .O(target[1]));
  (* SOFT_HLUTNM = "soft_lutpair42" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \target[2]_INST_0 
       (.I0(target0[2]),
        .I1(imm[2]),
        .I2(relative),
        .O(target[2]));
  (* SOFT_HLUTNM = "soft_lutpair41" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \target[3]_INST_0 
       (.I0(target0[3]),
        .I1(imm[3]),
        .I2(relative),
        .O(target[3]));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \target[3]_INST_0_i_1 
       (.CI(1'b0),
        .CO({\target[3]_INST_0_i_1_n_0 ,\target[3]_INST_0_i_1_n_1 ,\target[3]_INST_0_i_1_n_2 ,\target[3]_INST_0_i_1_n_3 }),
        .CYINIT(1'b1),
        .DI(branch_pc[3:0]),
        .O(target0[3:0]),
        .S({\target[3]_INST_0_i_2_n_0 ,\target[3]_INST_0_i_3_n_0 ,\target[3]_INST_0_i_4_n_0 ,\target[3]_INST_0_i_5_n_0 }));
  LUT2 #(
    .INIT(4'h6)) 
    \target[3]_INST_0_i_2 
       (.I0(branch_pc[3]),
        .I1(imm[3]),
        .O(\target[3]_INST_0_i_2_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \target[3]_INST_0_i_3 
       (.I0(branch_pc[2]),
        .I1(imm[2]),
        .O(\target[3]_INST_0_i_3_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \target[3]_INST_0_i_4 
       (.I0(branch_pc[1]),
        .I1(imm[1]),
        .O(\target[3]_INST_0_i_4_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \target[3]_INST_0_i_5 
       (.I0(branch_pc[0]),
        .I1(imm[0]),
        .O(\target[3]_INST_0_i_5_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair40" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \target[4]_INST_0 
       (.I0(target0[4]),
        .I1(imm[4]),
        .I2(relative),
        .O(target[4]));
  (* SOFT_HLUTNM = "soft_lutpair37" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \target[5]_INST_0 
       (.I0(target0[5]),
        .I1(imm[5]),
        .I2(relative),
        .O(target[5]));
  (* SOFT_HLUTNM = "soft_lutpair39" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \target[6]_INST_0 
       (.I0(target0[6]),
        .I1(imm[6]),
        .I2(relative),
        .O(target[6]));
  (* SOFT_HLUTNM = "soft_lutpair38" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \target[7]_INST_0 
       (.I0(target0[7]),
        .I1(imm[7]),
        .I2(relative),
        .O(target[7]));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \target[7]_INST_0_i_1 
       (.CI(\target[3]_INST_0_i_1_n_0 ),
        .CO({\target[7]_INST_0_i_1_n_0 ,\target[7]_INST_0_i_1_n_1 ,\target[7]_INST_0_i_1_n_2 ,\target[7]_INST_0_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({imm[7],branch_pc[6:4]}),
        .O(target0[7:4]),
        .S({\target[7]_INST_0_i_2_n_0 ,\target[7]_INST_0_i_3_n_0 ,\target[7]_INST_0_i_4_n_0 ,\target[7]_INST_0_i_5_n_0 }));
  LUT2 #(
    .INIT(4'h6)) 
    \target[7]_INST_0_i_2 
       (.I0(imm[7]),
        .I1(branch_pc[7]),
        .O(\target[7]_INST_0_i_2_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \target[7]_INST_0_i_3 
       (.I0(branch_pc[6]),
        .I1(imm[6]),
        .O(\target[7]_INST_0_i_3_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \target[7]_INST_0_i_4 
       (.I0(branch_pc[5]),
        .I1(imm[5]),
        .O(\target[7]_INST_0_i_4_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \target[7]_INST_0_i_5 
       (.I0(branch_pc[4]),
        .I1(imm[4]),
        .O(\target[7]_INST_0_i_5_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair44" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \target[8]_INST_0 
       (.I0(relative),
        .I1(target0[8]),
        .O(target[8]));
  (* SOFT_HLUTNM = "soft_lutpair41" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \target[9]_INST_0 
       (.I0(relative),
        .I1(target0[9]),
        .O(target[9]));
endmodule

(* DRAIN_FAULT = "3'b010" *) (* DRAIN_HALT = "3'b001" *) (* FAULTED = "3'b100" *) 
(* HALTED = "3'b011" *) (* RUN = "3'b000" *) 
(* NotValidForBitStream *)
module datapath_core
   (clk,
    rst,
    im_addr,
    im_en,
    im_dout,
    dm_addr,
    dm_en,
    dm_we,
    dm_din,
    dm_dout,
    halted,
    fault);
  input clk;
  input rst;
  output [15:0]im_addr;
  output im_en;
  input [15:0]im_dout;
  output [15:0]dm_addr;
  output dm_en;
  output dm_we;
  output [15:0]dm_din;
  input [15:0]dm_dout;
  output halted;
  output fault;

  (* RTL_KEEP = "true" *) wire C;
  wire \FSM_sequential_mode[0]_i_1_n_0 ;
  wire \FSM_sequential_mode[0]_i_2_n_0 ;
  wire \FSM_sequential_mode[0]_i_3_n_0 ;
  wire \FSM_sequential_mode[0]_i_4_n_0 ;
  wire \FSM_sequential_mode[1]_i_1_n_0 ;
  wire \FSM_sequential_mode[2]_i_1_n_0 ;
  wire \FSM_sequential_mode[2]_i_2_n_0 ;
  wire \FSM_sequential_mode[2]_i_3_n_0 ;
  wire \FSM_sequential_mode[2]_i_4_n_0 ;
  (* RTL_KEEP = "true" *) wire V;
  (* RTL_KEEP = "true" *) wire Z;
  wire [15:0]alu_a;
  wire [15:0]alu_b;
  wire alu_c;
  wire alu_eq;
  wire alu_illegal;
  wire [15:0]alu_result;
  wire alu_v;
  wire blocked_rd;
  wire blocked_rs;
  wire [15:0]branch_target;
  wire clk;
  wire cv_we;
  wire [1:0]d_alu_a_sel;
  wire [1:0]d_alu_b_sel;
  wire [2:0]d_alu_op;
  wire d_cv_write;
  wire d_fetch_fault;
  wire d_fetch_fault_i_1_n_0;
  wire d_fetch_fault_i_3_n_0;
  wire d_fetch_fault_i_4_n_0;
  wire d_fetch_fault_i_5_n_0;
  wire d_fetch_fault_i_6_n_0;
  wire d_fetch_fault_i_7_n_0;
  wire d_fetch_fault_i_8_n_0;
  wire d_fetch_fault_i_9_n_0;
  wire d_halt;
  wire d_illegal;
  wire [11:11]d_imm_ext;
  wire d_imm_signed;
  wire d_jump_abs;
  wire d_jump_z;
  wire d_mem_read;
  wire d_mem_write;
  wire [15:0]d_pc;
  wire [15:0]d_rd_value;
  wire d_reg_write;
  wire [15:0]d_rs_value;
  wire d_use_rd;
  wire d_use_rs;
  wire d_valid;
  wire d_valid_next6_out;
  wire d_z_write;
  wire [15:0]dm_addr;
  wire [15:0]dm_din;
  wire [15:0]dm_dout;
  wire dm_en;
  wire dm_en_INST_0_i_1_n_0;
  wire dm_en_INST_0_i_3_n_0;
  wire dm_we;
  wire fault;
  wire fetch_accept;
  wire halted;
  wire [15:0]im_addr;
  wire [15:0]im_dout;
  wire im_en;
  wire im_en_INST_0_i_1_n_0;
  wire im_en_INST_0_i_2_n_0;
  wire im_en_INST_0_i_3_n_0;
  wire im_en_INST_0_i_4_n_0;
  wire im_en_INST_0_i_5_n_0;
  wire im_en_INST_0_i_6_n_0;
  wire im_en_INST_0_i_7_n_0;
  wire m_c;
  wire m_cmp_z;
  wire m_cv_write;
  wire m_cv_write0;
  wire m_fault;
  wire m_fault0;
  wire m_halt;
  wire m_halt0;
  wire m_mem_read;
  wire m_mem_read0;
  wire m_mem_write;
  wire m_mem_write0;
  wire [1:0]m_rd;
  wire m_reg_write;
  wire m_reg_write0;
  wire m_v;
  wire m_valid;
  wire m_valid_next;
  wire m_wb_sel;
  wire m_z_write;
  wire m_z_write0;
  wire [2:0]mode;
  wire p_1_in;
  wire pc_hold;
  wire qualified_redirect;
  wire rf_we;
  wire [15:0]rs_fwd;
  wire rst;
  wire u_pc_i_10_n_0;
  wire u_pc_i_3_n_0;
  wire u_pc_i_4_n_0;
  wire u_pc_i_5_n_0;
  wire u_pc_i_6_n_0;
  wire u_pc_i_7_n_0;
  wire u_pc_i_8_n_0;
  wire u_pc_i_9_n_0;
  wire u_rf_i_18_n_0;
  wire w_c;
  wire w_cmp_z;
  wire w_cv_write;
  wire w_cv_write0;
  wire [15:0]w_exec_value;
  wire w_fault;
  wire w_fault0;
  wire w_fault_i_2_n_0;
  wire w_halt;
  wire w_halt0;
  wire [1:0]w_rd;
  wire w_reg_write;
  wire w_reg_write0;
  (* RTL_KEEP = "true" *) wire w_store;
  wire w_store_reg0;
  wire w_v;
  wire w_valid;
  wire w_valid_next;
  wire w_wb_sel;
  wire w_z_write;
  wire w_z_write0;
  wire [15:0]wb_data;
  wire [1:0]x_alu_a_sel;
  wire [1:0]x_alu_b_sel;
  wire [2:0]x_alu_op;
  wire x_cv_write;
  wire x_cv_write0;
  wire x_fault;
  wire x_fault_i_1_n_0;
  wire x_halt;
  wire x_halt0;
  wire x_halt_i_2_n_0;
  wire x_halt_i_3_n_0;
  wire x_halt_i_4_n_0;
  wire x_halt_i_5_n_0;
  wire x_halt_i_6_n_0;
  wire [7:0]x_imm_ext;
  wire [11:11]x_imm_ext__0;
  wire x_jump_abs;
  wire x_jump_abs0;
  wire x_jump_z;
  wire x_jump_z0;
  wire x_mem_read;
  wire x_mem_read0;
  wire x_mem_write;
  wire x_mem_write0;
  wire [15:0]x_pc;
  wire [1:0]x_rd;
  wire [15:0]x_rd_value;
  wire x_reg_write;
  wire x_reg_write0;
  wire [1:0]x_rs;
  wire [15:0]x_rs_value;
  wire [15:0]x_store_data;
  wire x_use_rd;
  wire x_use_rd0;
  wire x_use_rs;
  wire x_use_rs0;
  wire x_valid;
  wire x_valid_next;
  wire x_wb_sel;
  wire x_z_write;
  wire x_z_write0;
  wire z_we;
  wire NLW_u_decode_wb_sel_UNCONNECTED;
  wire [7:0]NLW_u_decode_imm_UNCONNECTED;
  wire [1:0]NLW_u_decode_rd_UNCONNECTED;
  wire [1:0]NLW_u_decode_rs_UNCONNECTED;
  wire [15:0]NLW_u_ext_value_UNCONNECTED;
  wire [1:0]NLW_u_forward_rd_sel_UNCONNECTED;
  wire [1:0]NLW_u_forward_rs_sel_UNCONNECTED;

  LUT6 #(
    .INIT(64'h0303FFFF00540000)) 
    \FSM_sequential_mode[0]_i_1 
       (.I0(\FSM_sequential_mode[0]_i_2_n_0 ),
        .I1(im_en_INST_0_i_1_n_0),
        .I2(\FSM_sequential_mode[0]_i_3_n_0 ),
        .I3(mode[1]),
        .I4(mode[2]),
        .I5(mode[0]),
        .O(\FSM_sequential_mode[0]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair45" *) 
  LUT4 #(
    .INIT(16'h0F08)) 
    \FSM_sequential_mode[0]_i_2 
       (.I0(x_valid),
        .I1(u_pc_i_3_n_0),
        .I2(im_en_INST_0_i_4_n_0),
        .I3(u_pc_i_4_n_0),
        .O(\FSM_sequential_mode[0]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h00000000005D0000)) 
    \FSM_sequential_mode[0]_i_3 
       (.I0(x_valid),
        .I1(u_pc_i_4_n_0),
        .I2(im_en_INST_0_i_4_n_0),
        .I3(m_valid),
        .I4(w_valid),
        .I5(\FSM_sequential_mode[0]_i_4_n_0 ),
        .O(\FSM_sequential_mode[0]_i_3_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair53" *) 
  LUT5 #(
    .INIT(32'hFFF1FFFF)) 
    \FSM_sequential_mode[0]_i_4 
       (.I0(w_halt),
        .I1(w_fault),
        .I2(rst),
        .I3(mode[2]),
        .I4(mode[1]),
        .O(\FSM_sequential_mode[0]_i_4_n_0 ));
  LUT6 #(
    .INIT(64'h3303445433030000)) 
    \FSM_sequential_mode[1]_i_1 
       (.I0(mode[0]),
        .I1(im_en_INST_0_i_1_n_0),
        .I2(\FSM_sequential_mode[2]_i_2_n_0 ),
        .I3(\FSM_sequential_mode[2]_i_3_n_0 ),
        .I4(mode[1]),
        .I5(mode[2]),
        .O(\FSM_sequential_mode[1]_i_1_n_0 ));
  LUT4 #(
    .INIT(16'h5100)) 
    \FSM_sequential_mode[2]_i_1 
       (.I0(im_en_INST_0_i_1_n_0),
        .I1(\FSM_sequential_mode[2]_i_2_n_0 ),
        .I2(\FSM_sequential_mode[2]_i_3_n_0 ),
        .I3(mode[2]),
        .O(\FSM_sequential_mode[2]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h54000000FFFFFFFF)) 
    \FSM_sequential_mode[2]_i_2 
       (.I0(im_en_INST_0_i_4_n_0),
        .I1(m_mem_read),
        .I2(m_mem_write),
        .I3(m_valid),
        .I4(dm_en_INST_0_i_1_n_0),
        .I5(x_valid),
        .O(\FSM_sequential_mode[2]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFABFF)) 
    \FSM_sequential_mode[2]_i_3 
       (.I0(\FSM_sequential_mode[2]_i_4_n_0 ),
        .I1(w_fault),
        .I2(w_halt),
        .I3(w_valid),
        .I4(m_valid),
        .O(\FSM_sequential_mode[2]_i_3_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair53" *) 
  LUT3 #(
    .INIT(8'hFD)) 
    \FSM_sequential_mode[2]_i_4 
       (.I0(mode[1]),
        .I1(mode[2]),
        .I2(rst),
        .O(\FSM_sequential_mode[2]_i_4_n_0 ));
  (* FSM_ENCODED_STATES = "RUN:100,HALTED:001,FAULTED:000,DRAIN_HALT:011,DRAIN_FAULT:010" *) 
  FDRE \FSM_sequential_mode_reg[0] 
       (.C(clk),
        .CE(1'b1),
        .D(\FSM_sequential_mode[0]_i_1_n_0 ),
        .Q(mode[0]),
        .R(rst));
  (* FSM_ENCODED_STATES = "RUN:100,HALTED:001,FAULTED:000,DRAIN_HALT:011,DRAIN_FAULT:010" *) 
  FDRE \FSM_sequential_mode_reg[1] 
       (.C(clk),
        .CE(1'b1),
        .D(\FSM_sequential_mode[1]_i_1_n_0 ),
        .Q(mode[1]),
        .R(rst));
  (* FSM_ENCODED_STATES = "RUN:100,HALTED:001,FAULTED:000,DRAIN_HALT:011,DRAIN_FAULT:010" *) 
  FDSE \FSM_sequential_mode_reg[2] 
       (.C(clk),
        .CE(1'b1),
        .D(\FSM_sequential_mode[2]_i_1_n_0 ),
        .Q(mode[2]),
        .S(rst));
  LUT6 #(
    .INIT(64'h2222222E00000000)) 
    d_fetch_fault_i_1
       (.I0(d_fetch_fault),
        .I1(p_1_in),
        .I2(im_en_INST_0_i_5_n_0),
        .I3(im_en_INST_0_i_4_n_0),
        .I4(d_fetch_fault_i_3_n_0),
        .I5(d_valid_next6_out),
        .O(d_fetch_fault_i_1_n_0));
  LUT6 #(
    .INIT(64'hFDFFFFFFFFFFFFFF)) 
    d_fetch_fault_i_2
       (.I0(x_valid),
        .I1(x_fault),
        .I2(im_en_INST_0_i_2_n_0),
        .I3(x_halt_i_2_n_0),
        .I4(d_valid),
        .I5(x_mem_read),
        .O(p_1_in));
  LUT6 #(
    .INIT(64'hFFFFFFFFFFFFFF32)) 
    d_fetch_fault_i_3
       (.I0(x_halt),
        .I1(d_fetch_fault_i_4_n_0),
        .I2(u_pc_i_5_n_0),
        .I3(d_fetch_fault_i_5_n_0),
        .I4(d_fetch_fault_i_6_n_0),
        .I5(x_halt_i_4_n_0),
        .O(d_fetch_fault_i_3_n_0));
  LUT6 #(
    .INIT(64'hFFFFFFFEFEFEFEFE)) 
    d_fetch_fault_i_4
       (.I0(d_fetch_fault_i_7_n_0),
        .I1(u_pc_i_6_n_0),
        .I2(d_fetch_fault_i_8_n_0),
        .I3(dm_en_INST_0_i_3_n_0),
        .I4(u_pc_i_7_n_0),
        .I5(d_fetch_fault_i_9_n_0),
        .O(d_fetch_fault_i_4_n_0));
  LUT6 #(
    .INIT(64'h00000000E0E0E000)) 
    d_fetch_fault_i_5
       (.I0(dm_en_INST_0_i_3_n_0),
        .I1(u_pc_i_7_n_0),
        .I2(m_valid),
        .I3(m_mem_write),
        .I4(m_mem_read),
        .I5(im_en_INST_0_i_4_n_0),
        .O(d_fetch_fault_i_5_n_0));
  LUT6 #(
    .INIT(64'h00000000FFFFFFFE)) 
    d_fetch_fault_i_6
       (.I0(u_pc_i_6_n_0),
        .I1(blocked_rd),
        .I2(x_fault),
        .I3(alu_illegal),
        .I4(blocked_rs),
        .I5(d_fetch_fault_i_8_n_0),
        .O(d_fetch_fault_i_6_n_0));
  (* SOFT_HLUTNM = "soft_lutpair46" *) 
  LUT4 #(
    .INIT(16'hFFFE)) 
    d_fetch_fault_i_7
       (.I0(blocked_rd),
        .I1(x_fault),
        .I2(alu_illegal),
        .I3(blocked_rs),
        .O(d_fetch_fault_i_7_n_0));
  (* SOFT_HLUTNM = "soft_lutpair51" *) 
  LUT5 #(
    .INIT(32'hFFFDFFFF)) 
    d_fetch_fault_i_8
       (.I0(mode[2]),
        .I1(mode[0]),
        .I2(mode[1]),
        .I3(rst),
        .I4(x_valid),
        .O(d_fetch_fault_i_8_n_0));
  (* SOFT_HLUTNM = "soft_lutpair48" *) 
  LUT3 #(
    .INIT(8'hA8)) 
    d_fetch_fault_i_9
       (.I0(m_valid),
        .I1(m_mem_write),
        .I2(m_mem_read),
        .O(d_fetch_fault_i_9_n_0));
  FDRE d_fetch_fault_reg
       (.C(clk),
        .CE(1'b1),
        .D(d_fetch_fault_i_1_n_0),
        .Q(d_fetch_fault),
        .R(1'b0));
  LUT5 #(
    .INIT(32'h00000051)) 
    \d_pc[15]_i_1 
       (.I0(im_en_INST_0_i_4_n_0),
        .I1(im_en_INST_0_i_3_n_0),
        .I2(im_en_INST_0_i_2_n_0),
        .I3(im_en_INST_0_i_1_n_0),
        .I4(qualified_redirect),
        .O(fetch_accept));
  FDRE \d_pc_reg[0] 
       (.C(clk),
        .CE(fetch_accept),
        .D(im_addr[0]),
        .Q(d_pc[0]),
        .R(rst));
  FDRE \d_pc_reg[10] 
       (.C(clk),
        .CE(fetch_accept),
        .D(im_addr[10]),
        .Q(d_pc[10]),
        .R(rst));
  FDRE \d_pc_reg[11] 
       (.C(clk),
        .CE(fetch_accept),
        .D(im_addr[11]),
        .Q(d_pc[11]),
        .R(rst));
  FDRE \d_pc_reg[12] 
       (.C(clk),
        .CE(fetch_accept),
        .D(im_addr[12]),
        .Q(d_pc[12]),
        .R(rst));
  FDRE \d_pc_reg[13] 
       (.C(clk),
        .CE(fetch_accept),
        .D(im_addr[13]),
        .Q(d_pc[13]),
        .R(rst));
  FDRE \d_pc_reg[14] 
       (.C(clk),
        .CE(fetch_accept),
        .D(im_addr[14]),
        .Q(d_pc[14]),
        .R(rst));
  FDRE \d_pc_reg[15] 
       (.C(clk),
        .CE(fetch_accept),
        .D(im_addr[15]),
        .Q(d_pc[15]),
        .R(rst));
  FDRE \d_pc_reg[1] 
       (.C(clk),
        .CE(fetch_accept),
        .D(im_addr[1]),
        .Q(d_pc[1]),
        .R(rst));
  FDRE \d_pc_reg[2] 
       (.C(clk),
        .CE(fetch_accept),
        .D(im_addr[2]),
        .Q(d_pc[2]),
        .R(rst));
  FDRE \d_pc_reg[3] 
       (.C(clk),
        .CE(fetch_accept),
        .D(im_addr[3]),
        .Q(d_pc[3]),
        .R(rst));
  FDRE \d_pc_reg[4] 
       (.C(clk),
        .CE(fetch_accept),
        .D(im_addr[4]),
        .Q(d_pc[4]),
        .R(rst));
  FDRE \d_pc_reg[5] 
       (.C(clk),
        .CE(fetch_accept),
        .D(im_addr[5]),
        .Q(d_pc[5]),
        .R(rst));
  FDRE \d_pc_reg[6] 
       (.C(clk),
        .CE(fetch_accept),
        .D(im_addr[6]),
        .Q(d_pc[6]),
        .R(rst));
  FDRE \d_pc_reg[7] 
       (.C(clk),
        .CE(fetch_accept),
        .D(im_addr[7]),
        .Q(d_pc[7]),
        .R(rst));
  FDRE \d_pc_reg[8] 
       (.C(clk),
        .CE(fetch_accept),
        .D(im_addr[8]),
        .Q(d_pc[8]),
        .R(rst));
  FDRE \d_pc_reg[9] 
       (.C(clk),
        .CE(fetch_accept),
        .D(im_addr[9]),
        .Q(d_pc[9]),
        .R(rst));
  LUT6 #(
    .INIT(64'h0000003300000037)) 
    d_valid_i_1
       (.I0(u_pc_i_5_n_0),
        .I1(x_valid),
        .I2(u_pc_i_3_n_0),
        .I3(im_en_INST_0_i_4_n_0),
        .I4(u_pc_i_4_n_0),
        .I5(x_halt),
        .O(d_valid_next6_out));
  FDRE d_valid_reg
       (.C(clk),
        .CE(1'b1),
        .D(d_valid_next6_out),
        .Q(d_valid),
        .R(rst));
  LUT4 #(
    .INIT(16'h0E00)) 
    dm_en_INST_0
       (.I0(m_mem_read),
        .I1(m_mem_write),
        .I2(dm_en_INST_0_i_1_n_0),
        .I3(w_valid_next),
        .O(dm_en));
  (* SOFT_HLUTNM = "soft_lutpair50" *) 
  LUT5 #(
    .INIT(32'hFFFFFFFE)) 
    dm_en_INST_0_i_1
       (.I0(dm_en_INST_0_i_3_n_0),
        .I1(dm_addr[15]),
        .I2(dm_addr[11]),
        .I3(dm_addr[8]),
        .I4(dm_addr[9]),
        .O(dm_en_INST_0_i_1_n_0));
  (* SOFT_HLUTNM = "soft_lutpair52" *) 
  LUT5 #(
    .INIT(32'h02060000)) 
    dm_en_INST_0_i_2
       (.I0(mode[1]),
        .I1(mode[2]),
        .I2(rst),
        .I3(mode[0]),
        .I4(m_valid),
        .O(w_valid_next));
  LUT5 #(
    .INIT(32'hFFFFFFFE)) 
    dm_en_INST_0_i_3
       (.I0(m_fault),
        .I1(dm_addr[13]),
        .I2(dm_addr[12]),
        .I3(dm_addr[10]),
        .I4(dm_addr[14]),
        .O(dm_en_INST_0_i_3_n_0));
  LUT3 #(
    .INIT(8'h40)) 
    dm_we_INST_0
       (.I0(dm_en_INST_0_i_1_n_0),
        .I1(m_mem_write),
        .I2(w_valid_next),
        .O(dm_we));
  LUT3 #(
    .INIT(8'h01)) 
    fault_INST_0
       (.I0(mode[2]),
        .I1(mode[1]),
        .I2(mode[0]),
        .O(fault));
  LUT3 #(
    .INIT(8'h10)) 
    halted_INST_0
       (.I0(mode[2]),
        .I1(mode[1]),
        .I2(mode[0]),
        .O(halted));
  LUT6 #(
    .INIT(64'h0000101100000000)) 
    im_en_INST_0
       (.I0(qualified_redirect),
        .I1(im_en_INST_0_i_1_n_0),
        .I2(im_en_INST_0_i_2_n_0),
        .I3(im_en_INST_0_i_3_n_0),
        .I4(im_en_INST_0_i_4_n_0),
        .I5(im_en_INST_0_i_5_n_0),
        .O(im_en));
  (* SOFT_HLUTNM = "soft_lutpair45" *) 
  LUT5 #(
    .INIT(32'h0F0E0C0C)) 
    im_en_INST_0_i_1
       (.I0(x_halt),
        .I1(u_pc_i_4_n_0),
        .I2(im_en_INST_0_i_4_n_0),
        .I3(u_pc_i_3_n_0),
        .I4(x_valid),
        .O(im_en_INST_0_i_1_n_0));
  LUT6 #(
    .INIT(64'h7DFFFF7D00000000)) 
    im_en_INST_0_i_2
       (.I0(d_use_rd),
        .I1(x_rd[0]),
        .I2(im_dout[10]),
        .I3(x_rd[1]),
        .I4(im_dout[11]),
        .I5(im_en_INST_0_i_6_n_0),
        .O(im_en_INST_0_i_2_n_0));
  LUT6 #(
    .INIT(64'h0000000800000000)) 
    im_en_INST_0_i_3
       (.I0(x_mem_read),
        .I1(d_valid),
        .I2(d_fetch_fault),
        .I3(d_illegal),
        .I4(x_fault),
        .I5(x_valid),
        .O(im_en_INST_0_i_3_n_0));
  (* SOFT_HLUTNM = "soft_lutpair51" *) 
  LUT4 #(
    .INIT(16'hFEFF)) 
    im_en_INST_0_i_4
       (.I0(rst),
        .I1(mode[1]),
        .I2(mode[0]),
        .I3(mode[2]),
        .O(im_en_INST_0_i_4_n_0));
  LUT5 #(
    .INIT(32'h00010000)) 
    im_en_INST_0_i_5
       (.I0(im_addr[12]),
        .I1(im_addr[13]),
        .I2(im_addr[14]),
        .I3(im_addr[15]),
        .I4(im_en_INST_0_i_7_n_0),
        .O(im_en_INST_0_i_5_n_0));
  LUT5 #(
    .INIT(32'h7DFFFF7D)) 
    im_en_INST_0_i_6
       (.I0(d_use_rs),
        .I1(x_rd[1]),
        .I2(im_dout[9]),
        .I3(im_dout[8]),
        .I4(x_rd[0]),
        .O(im_en_INST_0_i_6_n_0));
  LUT4 #(
    .INIT(16'h0001)) 
    im_en_INST_0_i_7
       (.I0(im_addr[9]),
        .I1(im_addr[8]),
        .I2(im_addr[11]),
        .I3(im_addr[10]),
        .O(im_en_INST_0_i_7_n_0));
  FDRE m_c_reg
       (.C(clk),
        .CE(1'b1),
        .D(alu_c),
        .Q(m_c),
        .R(rst));
  FDRE m_cmp_z_reg
       (.C(clk),
        .CE(1'b1),
        .D(alu_eq),
        .Q(m_cmp_z),
        .R(rst));
  (* SOFT_HLUTNM = "soft_lutpair59" *) 
  LUT4 #(
    .INIT(16'h0020)) 
    m_cv_write_i_1
       (.I0(x_cv_write),
        .I1(\FSM_sequential_mode[2]_i_2_n_0 ),
        .I2(u_rf_i_18_n_0),
        .I3(u_pc_i_3_n_0),
        .O(m_cv_write0));
  FDRE m_cv_write_reg
       (.C(clk),
        .CE(1'b1),
        .D(m_cv_write0),
        .Q(m_cv_write),
        .R(rst));
  FDRE \m_exec_value_reg[0] 
       (.C(clk),
        .CE(1'b1),
        .D(alu_result[0]),
        .Q(dm_addr[0]),
        .R(rst));
  FDRE \m_exec_value_reg[10] 
       (.C(clk),
        .CE(1'b1),
        .D(alu_result[10]),
        .Q(dm_addr[10]),
        .R(rst));
  FDRE \m_exec_value_reg[11] 
       (.C(clk),
        .CE(1'b1),
        .D(alu_result[11]),
        .Q(dm_addr[11]),
        .R(rst));
  FDRE \m_exec_value_reg[12] 
       (.C(clk),
        .CE(1'b1),
        .D(alu_result[12]),
        .Q(dm_addr[12]),
        .R(rst));
  FDRE \m_exec_value_reg[13] 
       (.C(clk),
        .CE(1'b1),
        .D(alu_result[13]),
        .Q(dm_addr[13]),
        .R(rst));
  FDRE \m_exec_value_reg[14] 
       (.C(clk),
        .CE(1'b1),
        .D(alu_result[14]),
        .Q(dm_addr[14]),
        .R(rst));
  FDRE \m_exec_value_reg[15] 
       (.C(clk),
        .CE(1'b1),
        .D(alu_result[15]),
        .Q(dm_addr[15]),
        .R(rst));
  FDRE \m_exec_value_reg[1] 
       (.C(clk),
        .CE(1'b1),
        .D(alu_result[1]),
        .Q(dm_addr[1]),
        .R(rst));
  FDRE \m_exec_value_reg[2] 
       (.C(clk),
        .CE(1'b1),
        .D(alu_result[2]),
        .Q(dm_addr[2]),
        .R(rst));
  FDRE \m_exec_value_reg[3] 
       (.C(clk),
        .CE(1'b1),
        .D(alu_result[3]),
        .Q(dm_addr[3]),
        .R(rst));
  FDRE \m_exec_value_reg[4] 
       (.C(clk),
        .CE(1'b1),
        .D(alu_result[4]),
        .Q(dm_addr[4]),
        .R(rst));
  FDRE \m_exec_value_reg[5] 
       (.C(clk),
        .CE(1'b1),
        .D(alu_result[5]),
        .Q(dm_addr[5]),
        .R(rst));
  FDRE \m_exec_value_reg[6] 
       (.C(clk),
        .CE(1'b1),
        .D(alu_result[6]),
        .Q(dm_addr[6]),
        .R(rst));
  FDRE \m_exec_value_reg[7] 
       (.C(clk),
        .CE(1'b1),
        .D(alu_result[7]),
        .Q(dm_addr[7]),
        .R(rst));
  FDRE \m_exec_value_reg[8] 
       (.C(clk),
        .CE(1'b1),
        .D(alu_result[8]),
        .Q(dm_addr[8]),
        .R(rst));
  FDRE \m_exec_value_reg[9] 
       (.C(clk),
        .CE(1'b1),
        .D(alu_result[9]),
        .Q(dm_addr[9]),
        .R(rst));
  (* SOFT_HLUTNM = "soft_lutpair49" *) 
  LUT5 #(
    .INIT(32'h00000A20)) 
    m_fault_i_1
       (.I0(u_pc_i_3_n_0),
        .I1(mode[0]),
        .I2(mode[2]),
        .I3(mode[1]),
        .I4(\FSM_sequential_mode[2]_i_2_n_0 ),
        .O(m_fault0));
  FDRE m_fault_reg
       (.C(clk),
        .CE(1'b1),
        .D(m_fault0),
        .Q(m_fault),
        .R(rst));
  (* SOFT_HLUTNM = "soft_lutpair60" *) 
  LUT4 #(
    .INIT(16'h0020)) 
    m_halt_i_1
       (.I0(x_halt),
        .I1(\FSM_sequential_mode[2]_i_2_n_0 ),
        .I2(u_rf_i_18_n_0),
        .I3(u_pc_i_3_n_0),
        .O(m_halt0));
  FDRE m_halt_reg
       (.C(clk),
        .CE(1'b1),
        .D(m_halt0),
        .Q(m_halt),
        .R(rst));
  (* SOFT_HLUTNM = "soft_lutpair61" *) 
  LUT4 #(
    .INIT(16'h0020)) 
    m_mem_read_i_1
       (.I0(x_mem_read),
        .I1(\FSM_sequential_mode[2]_i_2_n_0 ),
        .I2(u_rf_i_18_n_0),
        .I3(u_pc_i_3_n_0),
        .O(m_mem_read0));
  FDRE m_mem_read_reg
       (.C(clk),
        .CE(1'b1),
        .D(m_mem_read0),
        .Q(m_mem_read),
        .R(rst));
  (* SOFT_HLUTNM = "soft_lutpair60" *) 
  LUT4 #(
    .INIT(16'h0020)) 
    m_mem_write_i_1
       (.I0(x_mem_write),
        .I1(\FSM_sequential_mode[2]_i_2_n_0 ),
        .I2(u_rf_i_18_n_0),
        .I3(u_pc_i_3_n_0),
        .O(m_mem_write0));
  FDRE m_mem_write_reg
       (.C(clk),
        .CE(1'b1),
        .D(m_mem_write0),
        .Q(m_mem_write),
        .R(rst));
  FDRE \m_rd_reg[0] 
       (.C(clk),
        .CE(1'b1),
        .D(x_rd[0]),
        .Q(m_rd[0]),
        .R(rst));
  FDRE \m_rd_reg[1] 
       (.C(clk),
        .CE(1'b1),
        .D(x_rd[1]),
        .Q(m_rd[1]),
        .R(rst));
  (* SOFT_HLUTNM = "soft_lutpair59" *) 
  LUT4 #(
    .INIT(16'h0020)) 
    m_reg_write_i_1
       (.I0(x_reg_write),
        .I1(\FSM_sequential_mode[2]_i_2_n_0 ),
        .I2(u_rf_i_18_n_0),
        .I3(u_pc_i_3_n_0),
        .O(m_reg_write0));
  FDRE m_reg_write_reg
       (.C(clk),
        .CE(1'b1),
        .D(m_reg_write0),
        .Q(m_reg_write),
        .R(rst));
  FDRE \m_store_data_reg[0] 
       (.C(clk),
        .CE(1'b1),
        .D(x_store_data[0]),
        .Q(dm_din[0]),
        .R(rst));
  FDRE \m_store_data_reg[10] 
       (.C(clk),
        .CE(1'b1),
        .D(x_store_data[10]),
        .Q(dm_din[10]),
        .R(rst));
  FDRE \m_store_data_reg[11] 
       (.C(clk),
        .CE(1'b1),
        .D(x_store_data[11]),
        .Q(dm_din[11]),
        .R(rst));
  FDRE \m_store_data_reg[12] 
       (.C(clk),
        .CE(1'b1),
        .D(x_store_data[12]),
        .Q(dm_din[12]),
        .R(rst));
  FDRE \m_store_data_reg[13] 
       (.C(clk),
        .CE(1'b1),
        .D(x_store_data[13]),
        .Q(dm_din[13]),
        .R(rst));
  FDRE \m_store_data_reg[14] 
       (.C(clk),
        .CE(1'b1),
        .D(x_store_data[14]),
        .Q(dm_din[14]),
        .R(rst));
  FDRE \m_store_data_reg[15] 
       (.C(clk),
        .CE(1'b1),
        .D(x_store_data[15]),
        .Q(dm_din[15]),
        .R(rst));
  FDRE \m_store_data_reg[1] 
       (.C(clk),
        .CE(1'b1),
        .D(x_store_data[1]),
        .Q(dm_din[1]),
        .R(rst));
  FDRE \m_store_data_reg[2] 
       (.C(clk),
        .CE(1'b1),
        .D(x_store_data[2]),
        .Q(dm_din[2]),
        .R(rst));
  FDRE \m_store_data_reg[3] 
       (.C(clk),
        .CE(1'b1),
        .D(x_store_data[3]),
        .Q(dm_din[3]),
        .R(rst));
  FDRE \m_store_data_reg[4] 
       (.C(clk),
        .CE(1'b1),
        .D(x_store_data[4]),
        .Q(dm_din[4]),
        .R(rst));
  FDRE \m_store_data_reg[5] 
       (.C(clk),
        .CE(1'b1),
        .D(x_store_data[5]),
        .Q(dm_din[5]),
        .R(rst));
  FDRE \m_store_data_reg[6] 
       (.C(clk),
        .CE(1'b1),
        .D(x_store_data[6]),
        .Q(dm_din[6]),
        .R(rst));
  FDRE \m_store_data_reg[7] 
       (.C(clk),
        .CE(1'b1),
        .D(x_store_data[7]),
        .Q(dm_din[7]),
        .R(rst));
  FDRE \m_store_data_reg[8] 
       (.C(clk),
        .CE(1'b1),
        .D(x_store_data[8]),
        .Q(dm_din[8]),
        .R(rst));
  FDRE \m_store_data_reg[9] 
       (.C(clk),
        .CE(1'b1),
        .D(x_store_data[9]),
        .Q(dm_din[9]),
        .R(rst));
  FDRE m_v_reg
       (.C(clk),
        .CE(1'b1),
        .D(alu_v),
        .Q(m_v),
        .R(rst));
  (* SOFT_HLUTNM = "soft_lutpair49" *) 
  LUT4 #(
    .INIT(16'h0034)) 
    m_valid_i_1
       (.I0(mode[0]),
        .I1(mode[2]),
        .I2(mode[1]),
        .I3(\FSM_sequential_mode[2]_i_2_n_0 ),
        .O(m_valid_next));
  FDRE m_valid_reg
       (.C(clk),
        .CE(1'b1),
        .D(m_valid_next),
        .Q(m_valid),
        .R(rst));
  FDRE m_wb_sel_reg
       (.C(clk),
        .CE(1'b1),
        .D(x_wb_sel),
        .Q(m_wb_sel),
        .R(rst));
  (* SOFT_HLUTNM = "soft_lutpair61" *) 
  LUT4 #(
    .INIT(16'h0020)) 
    m_z_write_i_1
       (.I0(x_z_write),
        .I1(\FSM_sequential_mode[2]_i_2_n_0 ),
        .I2(u_rf_i_18_n_0),
        .I3(u_pc_i_3_n_0),
        .O(m_z_write0));
  FDRE m_z_write_reg
       (.C(clk),
        .CE(1'b1),
        .D(m_z_write0),
        .Q(m_z_write),
        .R(rst));
  alu16 u_alu
       (.a(alu_a),
        .b(alu_b),
        .carry(alu_c),
        .eq(alu_eq),
        .illegal(alu_illegal),
        .op(x_alu_op),
        .overflow(alu_v),
        .result(alu_result));
  LUT4 #(
    .INIT(16'h0AC0)) 
    u_alu_i_1
       (.I0(rs_fwd[15]),
        .I1(x_store_data[15]),
        .I2(x_alu_a_sel[0]),
        .I3(x_alu_a_sel[1]),
        .O(alu_a[15]));
  LUT4 #(
    .INIT(16'h0AC0)) 
    u_alu_i_10
       (.I0(rs_fwd[6]),
        .I1(x_store_data[6]),
        .I2(x_alu_a_sel[0]),
        .I3(x_alu_a_sel[1]),
        .O(alu_a[6]));
  LUT4 #(
    .INIT(16'h0AC0)) 
    u_alu_i_11
       (.I0(rs_fwd[5]),
        .I1(x_store_data[5]),
        .I2(x_alu_a_sel[0]),
        .I3(x_alu_a_sel[1]),
        .O(alu_a[5]));
  LUT4 #(
    .INIT(16'h0AC0)) 
    u_alu_i_12
       (.I0(rs_fwd[4]),
        .I1(x_store_data[4]),
        .I2(x_alu_a_sel[0]),
        .I3(x_alu_a_sel[1]),
        .O(alu_a[4]));
  LUT4 #(
    .INIT(16'h0AC0)) 
    u_alu_i_13
       (.I0(rs_fwd[3]),
        .I1(x_store_data[3]),
        .I2(x_alu_a_sel[0]),
        .I3(x_alu_a_sel[1]),
        .O(alu_a[3]));
  LUT4 #(
    .INIT(16'h0AC0)) 
    u_alu_i_14
       (.I0(rs_fwd[2]),
        .I1(x_store_data[2]),
        .I2(x_alu_a_sel[0]),
        .I3(x_alu_a_sel[1]),
        .O(alu_a[2]));
  LUT4 #(
    .INIT(16'h0AC0)) 
    u_alu_i_15
       (.I0(rs_fwd[1]),
        .I1(x_store_data[1]),
        .I2(x_alu_a_sel[0]),
        .I3(x_alu_a_sel[1]),
        .O(alu_a[1]));
  LUT4 #(
    .INIT(16'h0AC0)) 
    u_alu_i_16
       (.I0(rs_fwd[0]),
        .I1(x_store_data[0]),
        .I2(x_alu_a_sel[0]),
        .I3(x_alu_a_sel[1]),
        .O(alu_a[0]));
  (* SOFT_HLUTNM = "soft_lutpair57" *) 
  LUT4 #(
    .INIT(16'h3808)) 
    u_alu_i_17
       (.I0(rs_fwd[15]),
        .I1(x_alu_b_sel[0]),
        .I2(x_alu_b_sel[1]),
        .I3(x_imm_ext__0),
        .O(alu_b[15]));
  (* SOFT_HLUTNM = "soft_lutpair57" *) 
  LUT4 #(
    .INIT(16'h3808)) 
    u_alu_i_18
       (.I0(rs_fwd[14]),
        .I1(x_alu_b_sel[0]),
        .I2(x_alu_b_sel[1]),
        .I3(x_imm_ext__0),
        .O(alu_b[14]));
  (* SOFT_HLUTNM = "soft_lutpair56" *) 
  LUT4 #(
    .INIT(16'h3808)) 
    u_alu_i_19
       (.I0(rs_fwd[13]),
        .I1(x_alu_b_sel[0]),
        .I2(x_alu_b_sel[1]),
        .I3(x_imm_ext__0),
        .O(alu_b[13]));
  LUT4 #(
    .INIT(16'h0AC0)) 
    u_alu_i_2
       (.I0(rs_fwd[14]),
        .I1(x_store_data[14]),
        .I2(x_alu_a_sel[0]),
        .I3(x_alu_a_sel[1]),
        .O(alu_a[14]));
  (* SOFT_HLUTNM = "soft_lutpair56" *) 
  LUT4 #(
    .INIT(16'h3808)) 
    u_alu_i_20
       (.I0(rs_fwd[12]),
        .I1(x_alu_b_sel[0]),
        .I2(x_alu_b_sel[1]),
        .I3(x_imm_ext__0),
        .O(alu_b[12]));
  (* SOFT_HLUTNM = "soft_lutpair55" *) 
  LUT4 #(
    .INIT(16'h3808)) 
    u_alu_i_21
       (.I0(rs_fwd[11]),
        .I1(x_alu_b_sel[0]),
        .I2(x_alu_b_sel[1]),
        .I3(x_imm_ext__0),
        .O(alu_b[11]));
  (* SOFT_HLUTNM = "soft_lutpair55" *) 
  LUT4 #(
    .INIT(16'h3808)) 
    u_alu_i_22
       (.I0(rs_fwd[10]),
        .I1(x_alu_b_sel[0]),
        .I2(x_alu_b_sel[1]),
        .I3(x_imm_ext__0),
        .O(alu_b[10]));
  (* SOFT_HLUTNM = "soft_lutpair54" *) 
  LUT4 #(
    .INIT(16'h3808)) 
    u_alu_i_23
       (.I0(rs_fwd[9]),
        .I1(x_alu_b_sel[0]),
        .I2(x_alu_b_sel[1]),
        .I3(x_imm_ext__0),
        .O(alu_b[9]));
  (* SOFT_HLUTNM = "soft_lutpair54" *) 
  LUT4 #(
    .INIT(16'h3808)) 
    u_alu_i_24
       (.I0(rs_fwd[8]),
        .I1(x_alu_b_sel[0]),
        .I2(x_alu_b_sel[1]),
        .I3(x_imm_ext__0),
        .O(alu_b[8]));
  LUT4 #(
    .INIT(16'h3808)) 
    u_alu_i_25
       (.I0(rs_fwd[7]),
        .I1(x_alu_b_sel[0]),
        .I2(x_alu_b_sel[1]),
        .I3(x_imm_ext[7]),
        .O(alu_b[7]));
  LUT4 #(
    .INIT(16'h3808)) 
    u_alu_i_26
       (.I0(rs_fwd[6]),
        .I1(x_alu_b_sel[0]),
        .I2(x_alu_b_sel[1]),
        .I3(x_imm_ext[6]),
        .O(alu_b[6]));
  LUT4 #(
    .INIT(16'h3808)) 
    u_alu_i_27
       (.I0(rs_fwd[5]),
        .I1(x_alu_b_sel[0]),
        .I2(x_alu_b_sel[1]),
        .I3(x_imm_ext[5]),
        .O(alu_b[5]));
  LUT4 #(
    .INIT(16'h3808)) 
    u_alu_i_28
       (.I0(rs_fwd[4]),
        .I1(x_alu_b_sel[0]),
        .I2(x_alu_b_sel[1]),
        .I3(x_imm_ext[4]),
        .O(alu_b[4]));
  LUT4 #(
    .INIT(16'h3808)) 
    u_alu_i_29
       (.I0(rs_fwd[3]),
        .I1(x_alu_b_sel[0]),
        .I2(x_alu_b_sel[1]),
        .I3(x_imm_ext[3]),
        .O(alu_b[3]));
  LUT4 #(
    .INIT(16'h0AC0)) 
    u_alu_i_3
       (.I0(rs_fwd[13]),
        .I1(x_store_data[13]),
        .I2(x_alu_a_sel[0]),
        .I3(x_alu_a_sel[1]),
        .O(alu_a[13]));
  LUT4 #(
    .INIT(16'h3808)) 
    u_alu_i_30
       (.I0(rs_fwd[2]),
        .I1(x_alu_b_sel[0]),
        .I2(x_alu_b_sel[1]),
        .I3(x_imm_ext[2]),
        .O(alu_b[2]));
  LUT4 #(
    .INIT(16'h3808)) 
    u_alu_i_31
       (.I0(rs_fwd[1]),
        .I1(x_alu_b_sel[0]),
        .I2(x_alu_b_sel[1]),
        .I3(x_imm_ext[1]),
        .O(alu_b[1]));
  LUT4 #(
    .INIT(16'h3808)) 
    u_alu_i_32
       (.I0(rs_fwd[0]),
        .I1(x_alu_b_sel[0]),
        .I2(x_alu_b_sel[1]),
        .I3(x_imm_ext[0]),
        .O(alu_b[0]));
  LUT4 #(
    .INIT(16'h0AC0)) 
    u_alu_i_4
       (.I0(rs_fwd[12]),
        .I1(x_store_data[12]),
        .I2(x_alu_a_sel[0]),
        .I3(x_alu_a_sel[1]),
        .O(alu_a[12]));
  LUT4 #(
    .INIT(16'h0AC0)) 
    u_alu_i_5
       (.I0(rs_fwd[11]),
        .I1(x_store_data[11]),
        .I2(x_alu_a_sel[0]),
        .I3(x_alu_a_sel[1]),
        .O(alu_a[11]));
  LUT4 #(
    .INIT(16'h0AC0)) 
    u_alu_i_6
       (.I0(rs_fwd[10]),
        .I1(x_store_data[10]),
        .I2(x_alu_a_sel[0]),
        .I3(x_alu_a_sel[1]),
        .O(alu_a[10]));
  LUT4 #(
    .INIT(16'h0AC0)) 
    u_alu_i_7
       (.I0(rs_fwd[9]),
        .I1(x_store_data[9]),
        .I2(x_alu_a_sel[0]),
        .I3(x_alu_a_sel[1]),
        .O(alu_a[9]));
  LUT4 #(
    .INIT(16'h0AC0)) 
    u_alu_i_8
       (.I0(rs_fwd[8]),
        .I1(x_store_data[8]),
        .I2(x_alu_a_sel[0]),
        .I3(x_alu_a_sel[1]),
        .O(alu_a[8]));
  LUT4 #(
    .INIT(16'h0AC0)) 
    u_alu_i_9
       (.I0(rs_fwd[7]),
        .I1(x_store_data[7]),
        .I2(x_alu_a_sel[0]),
        .I3(x_alu_a_sel[1]),
        .O(alu_a[7]));
  isa_decode u_decode
       (.alu_a_sel(d_alu_a_sel),
        .alu_b_sel(d_alu_b_sel),
        .alu_op(d_alu_op),
        .cv_write(d_cv_write),
        .halt(d_halt),
        .illegal(d_illegal),
        .imm(NLW_u_decode_imm_UNCONNECTED[7:0]),
        .imm_signed(d_imm_signed),
        .inst({im_dout[15:12],1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .jump_abs(d_jump_abs),
        .jump_z(d_jump_z),
        .mem_read(d_mem_read),
        .mem_write(d_mem_write),
        .rd(NLW_u_decode_rd_UNCONNECTED[1:0]),
        .reg_write(d_reg_write),
        .rs(NLW_u_decode_rs_UNCONNECTED[1:0]),
        .use_rd(d_use_rd),
        .use_rs(d_use_rs),
        .wb_sel(NLW_u_decode_wb_sel_UNCONNECTED),
        .z_write(d_z_write));
  imm_ext16 u_ext
       (.imm({im_dout[7],1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .sign_mode(d_imm_signed),
        .value({NLW_u_ext_value_UNCONNECTED[15:12],d_imm_ext,NLW_u_ext_value_UNCONNECTED[10:0]}));
  flags_reg u_flags
       (.C(C),
        .V(V),
        .Z(Z),
        .c_in(w_c),
        .clk(clk),
        .cv_we(cv_we),
        .rst(rst),
        .v_in(w_v),
        .z_in(w_cmp_z),
        .z_we(z_we));
  (* SOFT_HLUTNM = "soft_lutpair63" *) 
  LUT4 #(
    .INIT(16'h0800)) 
    u_flags_i_1
       (.I0(u_rf_i_18_n_0),
        .I1(w_z_write),
        .I2(w_fault),
        .I3(w_valid),
        .O(z_we));
  (* SOFT_HLUTNM = "soft_lutpair58" *) 
  LUT4 #(
    .INIT(16'h0800)) 
    u_flags_i_2
       (.I0(w_cv_write),
        .I1(u_rf_i_18_n_0),
        .I2(w_fault),
        .I3(w_valid),
        .O(cv_we));
  operand_forward u_forward
       (.blocked_rd(blocked_rd),
        .blocked_rs(blocked_rs),
        .m_fault(m_fault),
        .m_mem_read(m_mem_read),
        .m_rd(m_rd),
        .m_reg_write(m_reg_write),
        .m_valid(m_valid),
        .m_value(dm_addr),
        .rd(x_rd),
        .rd_fwd(x_store_data),
        .rd_sel(NLW_u_forward_rd_sel_UNCONNECTED[1:0]),
        .rd_value(x_rd_value),
        .rs(x_rs),
        .rs_fwd(rs_fwd),
        .rs_sel(NLW_u_forward_rs_sel_UNCONNECTED[1:0]),
        .rs_value(x_rs_value),
        .use_rd(x_use_rd),
        .use_rs(x_use_rs),
        .w_fault(w_fault),
        .w_rd(w_rd),
        .w_reg_write(w_reg_write),
        .w_valid(w_valid),
        .w_value(wb_data));
  pc16 u_pc
       (.clk(clk),
        .hold(pc_hold),
        .pc(im_addr),
        .redirect(qualified_redirect),
        .rst(rst),
        .target(branch_target));
  LUT5 #(
    .INIT(32'hFFFFEFEE)) 
    u_pc_i_1
       (.I0(qualified_redirect),
        .I1(im_en_INST_0_i_1_n_0),
        .I2(im_en_INST_0_i_2_n_0),
        .I3(im_en_INST_0_i_3_n_0),
        .I4(im_en_INST_0_i_4_n_0),
        .O(pc_hold));
  (* SOFT_HLUTNM = "soft_lutpair47" *) 
  LUT5 #(
    .INIT(32'hFFBF0000)) 
    u_pc_i_10
       (.I0(m_fault),
        .I1(m_valid),
        .I2(m_z_write),
        .I3(m_cmp_z),
        .I4(x_jump_z),
        .O(u_pc_i_10_n_0));
  LUT6 #(
    .INIT(64'h0000010000000000)) 
    u_pc_i_2
       (.I0(x_halt),
        .I1(u_pc_i_3_n_0),
        .I2(im_en_INST_0_i_4_n_0),
        .I3(x_valid),
        .I4(u_pc_i_4_n_0),
        .I5(u_pc_i_5_n_0),
        .O(qualified_redirect));
  (* SOFT_HLUTNM = "soft_lutpair46" *) 
  LUT5 #(
    .INIT(32'hFFFFFFFE)) 
    u_pc_i_3
       (.I0(blocked_rs),
        .I1(alu_illegal),
        .I2(x_fault),
        .I3(blocked_rd),
        .I4(u_pc_i_6_n_0),
        .O(u_pc_i_3_n_0));
  (* SOFT_HLUTNM = "soft_lutpair48" *) 
  LUT5 #(
    .INIT(32'hE0E0E000)) 
    u_pc_i_4
       (.I0(m_mem_read),
        .I1(m_mem_write),
        .I2(m_valid),
        .I3(u_pc_i_7_n_0),
        .I4(dm_en_INST_0_i_3_n_0),
        .O(u_pc_i_4_n_0));
  LUT6 #(
    .INIT(64'hFEFFFEFAF0F0F0F0)) 
    u_pc_i_5
       (.I0(u_pc_i_8_n_0),
        .I1(Z),
        .I2(x_jump_abs),
        .I3(u_pc_i_9_n_0),
        .I4(w_cmp_z),
        .I5(u_pc_i_10_n_0),
        .O(u_pc_i_5_n_0));
  LUT4 #(
    .INIT(16'hF888)) 
    u_pc_i_6
       (.I0(x_alu_a_sel[0]),
        .I1(x_alu_a_sel[1]),
        .I2(x_alu_b_sel[0]),
        .I3(x_alu_b_sel[1]),
        .O(u_pc_i_6_n_0));
  (* SOFT_HLUTNM = "soft_lutpair50" *) 
  LUT4 #(
    .INIT(16'hFFFE)) 
    u_pc_i_7
       (.I0(dm_addr[9]),
        .I1(dm_addr[8]),
        .I2(dm_addr[11]),
        .I3(dm_addr[15]),
        .O(u_pc_i_7_n_0));
  (* SOFT_HLUTNM = "soft_lutpair47" *) 
  LUT3 #(
    .INIT(8'h40)) 
    u_pc_i_8
       (.I0(m_fault),
        .I1(m_valid),
        .I2(m_z_write),
        .O(u_pc_i_8_n_0));
  (* SOFT_HLUTNM = "soft_lutpair63" *) 
  LUT3 #(
    .INIT(8'hDF)) 
    u_pc_i_9
       (.I0(w_valid),
        .I1(w_fault),
        .I2(w_z_write),
        .O(u_pc_i_9_n_0));
  regfile4x16 u_rf
       (.clk(clk),
        .raddr_a(im_dout[11:10]),
        .raddr_b(im_dout[9:8]),
        .rdata_a(d_rd_value),
        .rdata_b(d_rs_value),
        .rst(rst),
        .waddr(w_rd),
        .wdata(wb_data),
        .we(rf_we));
  (* SOFT_HLUTNM = "soft_lutpair58" *) 
  LUT4 #(
    .INIT(16'h0800)) 
    u_rf_i_1
       (.I0(w_reg_write),
        .I1(u_rf_i_18_n_0),
        .I2(w_fault),
        .I3(w_valid),
        .O(rf_we));
  (* SOFT_HLUTNM = "soft_lutpair68" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    u_rf_i_10
       (.I0(dm_dout[7]),
        .I1(w_exec_value[7]),
        .I2(w_wb_sel),
        .O(wb_data[7]));
  (* SOFT_HLUTNM = "soft_lutpair68" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    u_rf_i_11
       (.I0(dm_dout[6]),
        .I1(w_exec_value[6]),
        .I2(w_wb_sel),
        .O(wb_data[6]));
  (* SOFT_HLUTNM = "soft_lutpair65" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    u_rf_i_12
       (.I0(dm_dout[5]),
        .I1(w_exec_value[5]),
        .I2(w_wb_sel),
        .O(wb_data[5]));
  (* SOFT_HLUTNM = "soft_lutpair65" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    u_rf_i_13
       (.I0(dm_dout[4]),
        .I1(w_exec_value[4]),
        .I2(w_wb_sel),
        .O(wb_data[4]));
  (* SOFT_HLUTNM = "soft_lutpair66" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    u_rf_i_14
       (.I0(dm_dout[3]),
        .I1(w_exec_value[3]),
        .I2(w_wb_sel),
        .O(wb_data[3]));
  (* SOFT_HLUTNM = "soft_lutpair66" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    u_rf_i_15
       (.I0(dm_dout[2]),
        .I1(w_exec_value[2]),
        .I2(w_wb_sel),
        .O(wb_data[2]));
  (* SOFT_HLUTNM = "soft_lutpair64" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    u_rf_i_16
       (.I0(dm_dout[1]),
        .I1(w_exec_value[1]),
        .I2(w_wb_sel),
        .O(wb_data[1]));
  (* SOFT_HLUTNM = "soft_lutpair64" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    u_rf_i_17
       (.I0(dm_dout[0]),
        .I1(w_exec_value[0]),
        .I2(w_wb_sel),
        .O(wb_data[0]));
  (* SOFT_HLUTNM = "soft_lutpair52" *) 
  LUT4 #(
    .INIT(16'h0310)) 
    u_rf_i_18
       (.I0(mode[0]),
        .I1(rst),
        .I2(mode[2]),
        .I3(mode[1]),
        .O(u_rf_i_18_n_0));
  (* SOFT_HLUTNM = "soft_lutpair71" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    u_rf_i_2
       (.I0(dm_dout[15]),
        .I1(w_exec_value[15]),
        .I2(w_wb_sel),
        .O(wb_data[15]));
  (* SOFT_HLUTNM = "soft_lutpair71" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    u_rf_i_3
       (.I0(dm_dout[14]),
        .I1(w_exec_value[14]),
        .I2(w_wb_sel),
        .O(wb_data[14]));
  (* SOFT_HLUTNM = "soft_lutpair70" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    u_rf_i_4
       (.I0(dm_dout[13]),
        .I1(w_exec_value[13]),
        .I2(w_wb_sel),
        .O(wb_data[13]));
  (* SOFT_HLUTNM = "soft_lutpair70" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    u_rf_i_5
       (.I0(dm_dout[12]),
        .I1(w_exec_value[12]),
        .I2(w_wb_sel),
        .O(wb_data[12]));
  (* SOFT_HLUTNM = "soft_lutpair69" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    u_rf_i_6
       (.I0(dm_dout[11]),
        .I1(w_exec_value[11]),
        .I2(w_wb_sel),
        .O(wb_data[11]));
  (* SOFT_HLUTNM = "soft_lutpair69" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    u_rf_i_7
       (.I0(dm_dout[10]),
        .I1(w_exec_value[10]),
        .I2(w_wb_sel),
        .O(wb_data[10]));
  (* SOFT_HLUTNM = "soft_lutpair67" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    u_rf_i_8
       (.I0(dm_dout[9]),
        .I1(w_exec_value[9]),
        .I2(w_wb_sel),
        .O(wb_data[9]));
  (* SOFT_HLUTNM = "soft_lutpair67" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    u_rf_i_9
       (.I0(dm_dout[8]),
        .I1(w_exec_value[8]),
        .I2(w_wb_sel),
        .O(wb_data[8]));
  branch_target16 u_target
       (.branch_pc(x_pc),
        .imm(x_imm_ext),
        .relative(x_jump_z),
        .target(branch_target));
  FDRE w_c_reg
       (.C(clk),
        .CE(1'b1),
        .D(m_c),
        .Q(w_c),
        .R(rst));
  FDRE w_cmp_z_reg
       (.C(clk),
        .CE(1'b1),
        .D(m_cmp_z),
        .Q(w_cmp_z),
        .R(rst));
  (* SOFT_HLUTNM = "soft_lutpair72" *) 
  LUT3 #(
    .INIT(8'h80)) 
    w_cv_write_i_1
       (.I0(m_cv_write),
        .I1(w_fault_i_2_n_0),
        .I2(w_valid_next),
        .O(w_cv_write0));
  FDRE w_cv_write_reg
       (.C(clk),
        .CE(1'b1),
        .D(w_cv_write0),
        .Q(w_cv_write),
        .R(rst));
  FDRE \w_exec_value_reg[0] 
       (.C(clk),
        .CE(1'b1),
        .D(dm_addr[0]),
        .Q(w_exec_value[0]),
        .R(rst));
  FDRE \w_exec_value_reg[10] 
       (.C(clk),
        .CE(1'b1),
        .D(dm_addr[10]),
        .Q(w_exec_value[10]),
        .R(rst));
  FDRE \w_exec_value_reg[11] 
       (.C(clk),
        .CE(1'b1),
        .D(dm_addr[11]),
        .Q(w_exec_value[11]),
        .R(rst));
  FDRE \w_exec_value_reg[12] 
       (.C(clk),
        .CE(1'b1),
        .D(dm_addr[12]),
        .Q(w_exec_value[12]),
        .R(rst));
  FDRE \w_exec_value_reg[13] 
       (.C(clk),
        .CE(1'b1),
        .D(dm_addr[13]),
        .Q(w_exec_value[13]),
        .R(rst));
  FDRE \w_exec_value_reg[14] 
       (.C(clk),
        .CE(1'b1),
        .D(dm_addr[14]),
        .Q(w_exec_value[14]),
        .R(rst));
  FDRE \w_exec_value_reg[15] 
       (.C(clk),
        .CE(1'b1),
        .D(dm_addr[15]),
        .Q(w_exec_value[15]),
        .R(rst));
  FDRE \w_exec_value_reg[1] 
       (.C(clk),
        .CE(1'b1),
        .D(dm_addr[1]),
        .Q(w_exec_value[1]),
        .R(rst));
  FDRE \w_exec_value_reg[2] 
       (.C(clk),
        .CE(1'b1),
        .D(dm_addr[2]),
        .Q(w_exec_value[2]),
        .R(rst));
  FDRE \w_exec_value_reg[3] 
       (.C(clk),
        .CE(1'b1),
        .D(dm_addr[3]),
        .Q(w_exec_value[3]),
        .R(rst));
  FDRE \w_exec_value_reg[4] 
       (.C(clk),
        .CE(1'b1),
        .D(dm_addr[4]),
        .Q(w_exec_value[4]),
        .R(rst));
  FDRE \w_exec_value_reg[5] 
       (.C(clk),
        .CE(1'b1),
        .D(dm_addr[5]),
        .Q(w_exec_value[5]),
        .R(rst));
  FDRE \w_exec_value_reg[6] 
       (.C(clk),
        .CE(1'b1),
        .D(dm_addr[6]),
        .Q(w_exec_value[6]),
        .R(rst));
  FDRE \w_exec_value_reg[7] 
       (.C(clk),
        .CE(1'b1),
        .D(dm_addr[7]),
        .Q(w_exec_value[7]),
        .R(rst));
  FDRE \w_exec_value_reg[8] 
       (.C(clk),
        .CE(1'b1),
        .D(dm_addr[8]),
        .Q(w_exec_value[8]),
        .R(rst));
  FDRE \w_exec_value_reg[9] 
       (.C(clk),
        .CE(1'b1),
        .D(dm_addr[9]),
        .Q(w_exec_value[9]),
        .R(rst));
  LUT5 #(
    .INIT(32'h00000A20)) 
    w_fault_i_1
       (.I0(m_valid),
        .I1(mode[0]),
        .I2(mode[2]),
        .I3(mode[1]),
        .I4(w_fault_i_2_n_0),
        .O(w_fault0));
  LUT5 #(
    .INIT(32'h15151555)) 
    w_fault_i_2
       (.I0(m_fault),
        .I1(dm_en_INST_0_i_1_n_0),
        .I2(m_valid),
        .I3(m_mem_write),
        .I4(m_mem_read),
        .O(w_fault_i_2_n_0));
  FDRE w_fault_reg
       (.C(clk),
        .CE(1'b1),
        .D(w_fault0),
        .Q(w_fault),
        .R(rst));
  (* SOFT_HLUTNM = "soft_lutpair73" *) 
  LUT3 #(
    .INIT(8'h80)) 
    w_halt_i_1
       (.I0(m_halt),
        .I1(w_fault_i_2_n_0),
        .I2(w_valid_next),
        .O(w_halt0));
  FDRE w_halt_reg
       (.C(clk),
        .CE(1'b1),
        .D(w_halt0),
        .Q(w_halt),
        .R(rst));
  FDRE \w_rd_reg[0] 
       (.C(clk),
        .CE(1'b1),
        .D(m_rd[0]),
        .Q(w_rd[0]),
        .R(rst));
  FDRE \w_rd_reg[1] 
       (.C(clk),
        .CE(1'b1),
        .D(m_rd[1]),
        .Q(w_rd[1]),
        .R(rst));
  (* SOFT_HLUTNM = "soft_lutpair72" *) 
  LUT3 #(
    .INIT(8'h80)) 
    w_reg_write_i_1
       (.I0(m_reg_write),
        .I1(w_fault_i_2_n_0),
        .I2(w_valid_next),
        .O(w_reg_write0));
  FDRE w_reg_write_reg
       (.C(clk),
        .CE(1'b1),
        .D(w_reg_write0),
        .Q(w_reg_write),
        .R(rst));
  LUT6 #(
    .INIT(64'h1500150000000000)) 
    w_store_i_1
       (.I0(m_fault),
        .I1(dm_en_INST_0_i_1_n_0),
        .I2(m_valid),
        .I3(m_mem_write),
        .I4(m_mem_read),
        .I5(w_valid_next),
        .O(w_store_reg0));
  (* KEEP = "yes" *) 
  FDRE w_store_reg
       (.C(clk),
        .CE(1'b1),
        .D(w_store_reg0),
        .Q(w_store),
        .R(rst));
  FDRE w_v_reg
       (.C(clk),
        .CE(1'b1),
        .D(m_v),
        .Q(w_v),
        .R(rst));
  FDRE w_valid_reg
       (.C(clk),
        .CE(1'b1),
        .D(w_valid_next),
        .Q(w_valid),
        .R(rst));
  FDRE w_wb_sel_reg
       (.C(clk),
        .CE(1'b1),
        .D(m_wb_sel),
        .Q(w_wb_sel),
        .R(rst));
  (* SOFT_HLUTNM = "soft_lutpair73" *) 
  LUT3 #(
    .INIT(8'h80)) 
    w_z_write_i_1
       (.I0(m_z_write),
        .I1(w_fault_i_2_n_0),
        .I2(w_valid_next),
        .O(w_z_write0));
  FDRE w_z_write_reg
       (.C(clk),
        .CE(1'b1),
        .D(w_z_write0),
        .Q(w_z_write),
        .R(rst));
  FDRE \x_alu_a_sel_reg[0] 
       (.C(clk),
        .CE(1'b1),
        .D(d_alu_a_sel[0]),
        .Q(x_alu_a_sel[0]),
        .R(rst));
  FDRE \x_alu_a_sel_reg[1] 
       (.C(clk),
        .CE(1'b1),
        .D(d_alu_a_sel[1]),
        .Q(x_alu_a_sel[1]),
        .R(rst));
  FDRE \x_alu_b_sel_reg[0] 
       (.C(clk),
        .CE(1'b1),
        .D(d_alu_b_sel[0]),
        .Q(x_alu_b_sel[0]),
        .R(rst));
  FDRE \x_alu_b_sel_reg[1] 
       (.C(clk),
        .CE(1'b1),
        .D(d_alu_b_sel[1]),
        .Q(x_alu_b_sel[1]),
        .R(rst));
  FDRE \x_alu_op_reg[0] 
       (.C(clk),
        .CE(1'b1),
        .D(d_alu_op[0]),
        .Q(x_alu_op[0]),
        .R(rst));
  FDRE \x_alu_op_reg[1] 
       (.C(clk),
        .CE(1'b1),
        .D(d_alu_op[1]),
        .Q(x_alu_op[1]),
        .R(rst));
  FDRE \x_alu_op_reg[2] 
       (.C(clk),
        .CE(1'b1),
        .D(d_alu_op[2]),
        .Q(x_alu_op[2]),
        .R(rst));
  LUT6 #(
    .INIT(64'h0000000000000080)) 
    x_cv_write_i_1
       (.I0(d_cv_write),
        .I1(x_halt_i_2_n_0),
        .I2(d_valid),
        .I3(x_halt_i_3_n_0),
        .I4(x_halt_i_4_n_0),
        .I5(im_en_INST_0_i_4_n_0),
        .O(x_cv_write0));
  FDRE x_cv_write_reg
       (.C(clk),
        .CE(1'b1),
        .D(x_cv_write0),
        .Q(x_cv_write),
        .R(rst));
  LUT6 #(
    .INIT(64'h0000000100000000)) 
    x_fault_i_1
       (.I0(x_halt_i_2_n_0),
        .I1(im_en_INST_0_i_4_n_0),
        .I2(x_halt_i_4_n_0),
        .I3(im_en_INST_0_i_1_n_0),
        .I4(qualified_redirect),
        .I5(d_valid),
        .O(x_fault_i_1_n_0));
  FDRE x_fault_reg
       (.C(clk),
        .CE(1'b1),
        .D(x_fault_i_1_n_0),
        .Q(x_fault),
        .R(rst));
  LUT6 #(
    .INIT(64'h0000000000000080)) 
    x_halt_i_1
       (.I0(d_halt),
        .I1(x_halt_i_2_n_0),
        .I2(d_valid),
        .I3(x_halt_i_3_n_0),
        .I4(x_halt_i_4_n_0),
        .I5(im_en_INST_0_i_4_n_0),
        .O(x_halt0));
  (* SOFT_HLUTNM = "soft_lutpair62" *) 
  LUT2 #(
    .INIT(4'h1)) 
    x_halt_i_2
       (.I0(d_fetch_fault),
        .I1(d_illegal),
        .O(x_halt_i_2_n_0));
  LUT6 #(
    .INIT(64'h00FC00FC00FC00EC)) 
    x_halt_i_3
       (.I0(u_pc_i_5_n_0),
        .I1(u_pc_i_4_n_0),
        .I2(x_valid),
        .I3(im_en_INST_0_i_4_n_0),
        .I4(u_pc_i_3_n_0),
        .I5(x_halt),
        .O(x_halt_i_3_n_0));
  LUT6 #(
    .INIT(64'h0020202000200020)) 
    x_halt_i_4
       (.I0(x_valid),
        .I1(x_fault),
        .I2(x_halt_i_5_n_0),
        .I3(im_en_INST_0_i_6_n_0),
        .I4(x_halt_i_6_n_0),
        .I5(d_use_rd),
        .O(x_halt_i_4_n_0));
  (* SOFT_HLUTNM = "soft_lutpair62" *) 
  LUT4 #(
    .INIT(16'h1000)) 
    x_halt_i_5
       (.I0(d_illegal),
        .I1(d_fetch_fault),
        .I2(d_valid),
        .I3(x_mem_read),
        .O(x_halt_i_5_n_0));
  LUT4 #(
    .INIT(16'h6FF6)) 
    x_halt_i_6
       (.I0(x_rd[0]),
        .I1(im_dout[10]),
        .I2(x_rd[1]),
        .I3(im_dout[11]),
        .O(x_halt_i_6_n_0));
  FDRE x_halt_reg
       (.C(clk),
        .CE(1'b1),
        .D(x_halt0),
        .Q(x_halt),
        .R(rst));
  FDRE \x_imm_ext_reg[0] 
       (.C(clk),
        .CE(1'b1),
        .D(im_dout[0]),
        .Q(x_imm_ext[0]),
        .R(rst));
  FDRE \x_imm_ext_reg[11] 
       (.C(clk),
        .CE(1'b1),
        .D(d_imm_ext),
        .Q(x_imm_ext__0),
        .R(rst));
  FDRE \x_imm_ext_reg[1] 
       (.C(clk),
        .CE(1'b1),
        .D(im_dout[1]),
        .Q(x_imm_ext[1]),
        .R(rst));
  FDRE \x_imm_ext_reg[2] 
       (.C(clk),
        .CE(1'b1),
        .D(im_dout[2]),
        .Q(x_imm_ext[2]),
        .R(rst));
  FDRE \x_imm_ext_reg[3] 
       (.C(clk),
        .CE(1'b1),
        .D(im_dout[3]),
        .Q(x_imm_ext[3]),
        .R(rst));
  FDRE \x_imm_ext_reg[4] 
       (.C(clk),
        .CE(1'b1),
        .D(im_dout[4]),
        .Q(x_imm_ext[4]),
        .R(rst));
  FDRE \x_imm_ext_reg[5] 
       (.C(clk),
        .CE(1'b1),
        .D(im_dout[5]),
        .Q(x_imm_ext[5]),
        .R(rst));
  FDRE \x_imm_ext_reg[6] 
       (.C(clk),
        .CE(1'b1),
        .D(im_dout[6]),
        .Q(x_imm_ext[6]),
        .R(rst));
  FDRE \x_imm_ext_reg[7] 
       (.C(clk),
        .CE(1'b1),
        .D(im_dout[7]),
        .Q(x_imm_ext[7]),
        .R(rst));
  LUT6 #(
    .INIT(64'h0000000000000080)) 
    x_jump_abs_i_1
       (.I0(d_jump_abs),
        .I1(x_halt_i_2_n_0),
        .I2(d_valid),
        .I3(x_halt_i_3_n_0),
        .I4(x_halt_i_4_n_0),
        .I5(im_en_INST_0_i_4_n_0),
        .O(x_jump_abs0));
  FDRE x_jump_abs_reg
       (.C(clk),
        .CE(1'b1),
        .D(x_jump_abs0),
        .Q(x_jump_abs),
        .R(rst));
  LUT6 #(
    .INIT(64'h0000000000000080)) 
    x_jump_z_i_1
       (.I0(d_jump_z),
        .I1(x_halt_i_2_n_0),
        .I2(d_valid),
        .I3(x_halt_i_3_n_0),
        .I4(x_halt_i_4_n_0),
        .I5(im_en_INST_0_i_4_n_0),
        .O(x_jump_z0));
  FDRE x_jump_z_reg
       (.C(clk),
        .CE(1'b1),
        .D(x_jump_z0),
        .Q(x_jump_z),
        .R(rst));
  LUT6 #(
    .INIT(64'h0000000000000080)) 
    x_mem_read_i_1
       (.I0(d_mem_read),
        .I1(x_halt_i_2_n_0),
        .I2(d_valid),
        .I3(x_halt_i_3_n_0),
        .I4(x_halt_i_4_n_0),
        .I5(im_en_INST_0_i_4_n_0),
        .O(x_mem_read0));
  FDRE x_mem_read_reg
       (.C(clk),
        .CE(1'b1),
        .D(x_mem_read0),
        .Q(x_mem_read),
        .R(rst));
  LUT6 #(
    .INIT(64'h0000000000000080)) 
    x_mem_write_i_1
       (.I0(d_mem_write),
        .I1(x_halt_i_2_n_0),
        .I2(d_valid),
        .I3(x_halt_i_3_n_0),
        .I4(x_halt_i_4_n_0),
        .I5(im_en_INST_0_i_4_n_0),
        .O(x_mem_write0));
  FDRE x_mem_write_reg
       (.C(clk),
        .CE(1'b1),
        .D(x_mem_write0),
        .Q(x_mem_write),
        .R(rst));
  FDRE \x_pc_reg[0] 
       (.C(clk),
        .CE(1'b1),
        .D(d_pc[0]),
        .Q(x_pc[0]),
        .R(rst));
  FDRE \x_pc_reg[10] 
       (.C(clk),
        .CE(1'b1),
        .D(d_pc[10]),
        .Q(x_pc[10]),
        .R(rst));
  FDRE \x_pc_reg[11] 
       (.C(clk),
        .CE(1'b1),
        .D(d_pc[11]),
        .Q(x_pc[11]),
        .R(rst));
  FDRE \x_pc_reg[12] 
       (.C(clk),
        .CE(1'b1),
        .D(d_pc[12]),
        .Q(x_pc[12]),
        .R(rst));
  FDRE \x_pc_reg[13] 
       (.C(clk),
        .CE(1'b1),
        .D(d_pc[13]),
        .Q(x_pc[13]),
        .R(rst));
  FDRE \x_pc_reg[14] 
       (.C(clk),
        .CE(1'b1),
        .D(d_pc[14]),
        .Q(x_pc[14]),
        .R(rst));
  FDRE \x_pc_reg[15] 
       (.C(clk),
        .CE(1'b1),
        .D(d_pc[15]),
        .Q(x_pc[15]),
        .R(rst));
  FDRE \x_pc_reg[1] 
       (.C(clk),
        .CE(1'b1),
        .D(d_pc[1]),
        .Q(x_pc[1]),
        .R(rst));
  FDRE \x_pc_reg[2] 
       (.C(clk),
        .CE(1'b1),
        .D(d_pc[2]),
        .Q(x_pc[2]),
        .R(rst));
  FDRE \x_pc_reg[3] 
       (.C(clk),
        .CE(1'b1),
        .D(d_pc[3]),
        .Q(x_pc[3]),
        .R(rst));
  FDRE \x_pc_reg[4] 
       (.C(clk),
        .CE(1'b1),
        .D(d_pc[4]),
        .Q(x_pc[4]),
        .R(rst));
  FDRE \x_pc_reg[5] 
       (.C(clk),
        .CE(1'b1),
        .D(d_pc[5]),
        .Q(x_pc[5]),
        .R(rst));
  FDRE \x_pc_reg[6] 
       (.C(clk),
        .CE(1'b1),
        .D(d_pc[6]),
        .Q(x_pc[6]),
        .R(rst));
  FDRE \x_pc_reg[7] 
       (.C(clk),
        .CE(1'b1),
        .D(d_pc[7]),
        .Q(x_pc[7]),
        .R(rst));
  FDRE \x_pc_reg[8] 
       (.C(clk),
        .CE(1'b1),
        .D(d_pc[8]),
        .Q(x_pc[8]),
        .R(rst));
  FDRE \x_pc_reg[9] 
       (.C(clk),
        .CE(1'b1),
        .D(d_pc[9]),
        .Q(x_pc[9]),
        .R(rst));
  FDRE \x_rd_reg[0] 
       (.C(clk),
        .CE(1'b1),
        .D(im_dout[10]),
        .Q(x_rd[0]),
        .R(rst));
  FDRE \x_rd_reg[1] 
       (.C(clk),
        .CE(1'b1),
        .D(im_dout[11]),
        .Q(x_rd[1]),
        .R(rst));
  FDRE \x_rd_value_reg[0] 
       (.C(clk),
        .CE(1'b1),
        .D(d_rd_value[0]),
        .Q(x_rd_value[0]),
        .R(rst));
  FDRE \x_rd_value_reg[10] 
       (.C(clk),
        .CE(1'b1),
        .D(d_rd_value[10]),
        .Q(x_rd_value[10]),
        .R(rst));
  FDRE \x_rd_value_reg[11] 
       (.C(clk),
        .CE(1'b1),
        .D(d_rd_value[11]),
        .Q(x_rd_value[11]),
        .R(rst));
  FDRE \x_rd_value_reg[12] 
       (.C(clk),
        .CE(1'b1),
        .D(d_rd_value[12]),
        .Q(x_rd_value[12]),
        .R(rst));
  FDRE \x_rd_value_reg[13] 
       (.C(clk),
        .CE(1'b1),
        .D(d_rd_value[13]),
        .Q(x_rd_value[13]),
        .R(rst));
  FDRE \x_rd_value_reg[14] 
       (.C(clk),
        .CE(1'b1),
        .D(d_rd_value[14]),
        .Q(x_rd_value[14]),
        .R(rst));
  FDRE \x_rd_value_reg[15] 
       (.C(clk),
        .CE(1'b1),
        .D(d_rd_value[15]),
        .Q(x_rd_value[15]),
        .R(rst));
  FDRE \x_rd_value_reg[1] 
       (.C(clk),
        .CE(1'b1),
        .D(d_rd_value[1]),
        .Q(x_rd_value[1]),
        .R(rst));
  FDRE \x_rd_value_reg[2] 
       (.C(clk),
        .CE(1'b1),
        .D(d_rd_value[2]),
        .Q(x_rd_value[2]),
        .R(rst));
  FDRE \x_rd_value_reg[3] 
       (.C(clk),
        .CE(1'b1),
        .D(d_rd_value[3]),
        .Q(x_rd_value[3]),
        .R(rst));
  FDRE \x_rd_value_reg[4] 
       (.C(clk),
        .CE(1'b1),
        .D(d_rd_value[4]),
        .Q(x_rd_value[4]),
        .R(rst));
  FDRE \x_rd_value_reg[5] 
       (.C(clk),
        .CE(1'b1),
        .D(d_rd_value[5]),
        .Q(x_rd_value[5]),
        .R(rst));
  FDRE \x_rd_value_reg[6] 
       (.C(clk),
        .CE(1'b1),
        .D(d_rd_value[6]),
        .Q(x_rd_value[6]),
        .R(rst));
  FDRE \x_rd_value_reg[7] 
       (.C(clk),
        .CE(1'b1),
        .D(d_rd_value[7]),
        .Q(x_rd_value[7]),
        .R(rst));
  FDRE \x_rd_value_reg[8] 
       (.C(clk),
        .CE(1'b1),
        .D(d_rd_value[8]),
        .Q(x_rd_value[8]),
        .R(rst));
  FDRE \x_rd_value_reg[9] 
       (.C(clk),
        .CE(1'b1),
        .D(d_rd_value[9]),
        .Q(x_rd_value[9]),
        .R(rst));
  LUT6 #(
    .INIT(64'h0000000000000080)) 
    x_reg_write_i_1
       (.I0(d_reg_write),
        .I1(x_halt_i_2_n_0),
        .I2(d_valid),
        .I3(x_halt_i_3_n_0),
        .I4(x_halt_i_4_n_0),
        .I5(im_en_INST_0_i_4_n_0),
        .O(x_reg_write0));
  FDRE x_reg_write_reg
       (.C(clk),
        .CE(1'b1),
        .D(x_reg_write0),
        .Q(x_reg_write),
        .R(rst));
  FDRE \x_rs_reg[0] 
       (.C(clk),
        .CE(1'b1),
        .D(im_dout[8]),
        .Q(x_rs[0]),
        .R(rst));
  FDRE \x_rs_reg[1] 
       (.C(clk),
        .CE(1'b1),
        .D(im_dout[9]),
        .Q(x_rs[1]),
        .R(rst));
  FDRE \x_rs_value_reg[0] 
       (.C(clk),
        .CE(1'b1),
        .D(d_rs_value[0]),
        .Q(x_rs_value[0]),
        .R(rst));
  FDRE \x_rs_value_reg[10] 
       (.C(clk),
        .CE(1'b1),
        .D(d_rs_value[10]),
        .Q(x_rs_value[10]),
        .R(rst));
  FDRE \x_rs_value_reg[11] 
       (.C(clk),
        .CE(1'b1),
        .D(d_rs_value[11]),
        .Q(x_rs_value[11]),
        .R(rst));
  FDRE \x_rs_value_reg[12] 
       (.C(clk),
        .CE(1'b1),
        .D(d_rs_value[12]),
        .Q(x_rs_value[12]),
        .R(rst));
  FDRE \x_rs_value_reg[13] 
       (.C(clk),
        .CE(1'b1),
        .D(d_rs_value[13]),
        .Q(x_rs_value[13]),
        .R(rst));
  FDRE \x_rs_value_reg[14] 
       (.C(clk),
        .CE(1'b1),
        .D(d_rs_value[14]),
        .Q(x_rs_value[14]),
        .R(rst));
  FDRE \x_rs_value_reg[15] 
       (.C(clk),
        .CE(1'b1),
        .D(d_rs_value[15]),
        .Q(x_rs_value[15]),
        .R(rst));
  FDRE \x_rs_value_reg[1] 
       (.C(clk),
        .CE(1'b1),
        .D(d_rs_value[1]),
        .Q(x_rs_value[1]),
        .R(rst));
  FDRE \x_rs_value_reg[2] 
       (.C(clk),
        .CE(1'b1),
        .D(d_rs_value[2]),
        .Q(x_rs_value[2]),
        .R(rst));
  FDRE \x_rs_value_reg[3] 
       (.C(clk),
        .CE(1'b1),
        .D(d_rs_value[3]),
        .Q(x_rs_value[3]),
        .R(rst));
  FDRE \x_rs_value_reg[4] 
       (.C(clk),
        .CE(1'b1),
        .D(d_rs_value[4]),
        .Q(x_rs_value[4]),
        .R(rst));
  FDRE \x_rs_value_reg[5] 
       (.C(clk),
        .CE(1'b1),
        .D(d_rs_value[5]),
        .Q(x_rs_value[5]),
        .R(rst));
  FDRE \x_rs_value_reg[6] 
       (.C(clk),
        .CE(1'b1),
        .D(d_rs_value[6]),
        .Q(x_rs_value[6]),
        .R(rst));
  FDRE \x_rs_value_reg[7] 
       (.C(clk),
        .CE(1'b1),
        .D(d_rs_value[7]),
        .Q(x_rs_value[7]),
        .R(rst));
  FDRE \x_rs_value_reg[8] 
       (.C(clk),
        .CE(1'b1),
        .D(d_rs_value[8]),
        .Q(x_rs_value[8]),
        .R(rst));
  FDRE \x_rs_value_reg[9] 
       (.C(clk),
        .CE(1'b1),
        .D(d_rs_value[9]),
        .Q(x_rs_value[9]),
        .R(rst));
  LUT6 #(
    .INIT(64'h0000000000000080)) 
    x_use_rd_i_1
       (.I0(d_use_rd),
        .I1(x_halt_i_2_n_0),
        .I2(d_valid),
        .I3(x_halt_i_3_n_0),
        .I4(x_halt_i_4_n_0),
        .I5(im_en_INST_0_i_4_n_0),
        .O(x_use_rd0));
  FDRE x_use_rd_reg
       (.C(clk),
        .CE(1'b1),
        .D(x_use_rd0),
        .Q(x_use_rd),
        .R(rst));
  LUT6 #(
    .INIT(64'h0000000000000080)) 
    x_use_rs_i_1
       (.I0(d_use_rs),
        .I1(x_halt_i_2_n_0),
        .I2(d_valid),
        .I3(x_halt_i_3_n_0),
        .I4(x_halt_i_4_n_0),
        .I5(im_en_INST_0_i_4_n_0),
        .O(x_use_rs0));
  FDRE x_use_rs_reg
       (.C(clk),
        .CE(1'b1),
        .D(x_use_rs0),
        .Q(x_use_rs),
        .R(rst));
  LUT6 #(
    .INIT(64'h0000005100000000)) 
    x_valid_i_1
       (.I0(im_en_INST_0_i_4_n_0),
        .I1(im_en_INST_0_i_3_n_0),
        .I2(im_en_INST_0_i_2_n_0),
        .I3(im_en_INST_0_i_1_n_0),
        .I4(qualified_redirect),
        .I5(d_valid),
        .O(x_valid_next));
  FDRE x_valid_reg
       (.C(clk),
        .CE(1'b1),
        .D(x_valid_next),
        .Q(x_valid),
        .R(rst));
  FDRE x_wb_sel_reg
       (.C(clk),
        .CE(1'b1),
        .D(d_mem_read),
        .Q(x_wb_sel),
        .R(rst));
  LUT6 #(
    .INIT(64'h0000000000000080)) 
    x_z_write_i_1
       (.I0(d_z_write),
        .I1(x_halt_i_2_n_0),
        .I2(d_valid),
        .I3(x_halt_i_3_n_0),
        .I4(x_halt_i_4_n_0),
        .I5(im_en_INST_0_i_4_n_0),
        .O(x_z_write0));
  FDRE x_z_write_reg
       (.C(clk),
        .CE(1'b1),
        .D(x_z_write0),
        .Q(x_z_write),
        .R(rst));
endmodule

module flags_reg
   (clk,
    rst,
    z_we,
    cv_we,
    z_in,
    c_in,
    v_in,
    Z,
    C,
    V);
  input clk;
  input rst;
  input z_we;
  input cv_we;
  input z_in;
  input c_in;
  input v_in;
  output Z;
  output C;
  output V;

  wire C;
  wire C_i_1_n_0;
  wire V;
  wire V_i_1_n_0;
  wire Z;
  wire Z_i_1_n_0;
  wire c_in;
  wire clk;
  wire cv_we;
  wire rst;
  wire v_in;
  wire z_in;
  wire z_we;

  (* SOFT_HLUTNM = "soft_lutpair33" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    C_i_1
       (.I0(c_in),
        .I1(cv_we),
        .I2(C),
        .O(C_i_1_n_0));
  FDRE C_reg
       (.C(clk),
        .CE(1'b1),
        .D(C_i_1_n_0),
        .Q(C),
        .R(rst));
  (* SOFT_HLUTNM = "soft_lutpair33" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    V_i_1
       (.I0(v_in),
        .I1(cv_we),
        .I2(V),
        .O(V_i_1_n_0));
  FDRE V_reg
       (.C(clk),
        .CE(1'b1),
        .D(V_i_1_n_0),
        .Q(V),
        .R(rst));
  LUT3 #(
    .INIT(8'hB8)) 
    Z_i_1
       (.I0(z_in),
        .I1(z_we),
        .I2(Z),
        .O(Z_i_1_n_0));
  FDRE Z_reg
       (.C(clk),
        .CE(1'b1),
        .D(Z_i_1_n_0),
        .Q(Z),
        .R(rst));
endmodule

module imm_ext16
   (imm,
    sign_mode,
    value);
  input [7:0]imm;
  input sign_mode;
  output [15:0]value;

  wire \<const0> ;
  wire [7:0]imm;
  wire sign_mode;
  wire [11:11]\^value ;

  assign value[15] = \<const0> ;
  assign value[14] = \<const0> ;
  assign value[13] = \<const0> ;
  assign value[12] = \<const0> ;
  assign value[11] = \^value [11];
  assign value[10] = \<const0> ;
  assign value[9] = \<const0> ;
  assign value[8] = \<const0> ;
  assign value[7] = \<const0> ;
  assign value[6] = \<const0> ;
  assign value[5] = \<const0> ;
  assign value[4] = \<const0> ;
  assign value[3] = \<const0> ;
  assign value[2] = \<const0> ;
  assign value[1] = \<const0> ;
  assign value[0] = \<const0> ;
  GND GND
       (.G(\<const0> ));
  LUT2 #(
    .INIT(4'h8)) 
    \value[11]_INST_0 
       (.I0(sign_mode),
        .I1(imm[7]),
        .O(\^value ));
endmodule

module isa_decode
   (inst,
    rd,
    rs,
    imm,
    use_rd,
    use_rs,
    alu_a_sel,
    alu_b_sel,
    alu_op,
    imm_signed,
    reg_write,
    mem_read,
    mem_write,
    z_write,
    cv_write,
    wb_sel,
    jump_abs,
    jump_z,
    halt,
    illegal);
  input [15:0]inst;
  output [1:0]rd;
  output [1:0]rs;
  output [7:0]imm;
  output use_rd;
  output use_rs;
  output [1:0]alu_a_sel;
  output [1:0]alu_b_sel;
  output [2:0]alu_op;
  output imm_signed;
  output reg_write;
  output mem_read;
  output mem_write;
  output z_write;
  output cv_write;
  output wb_sel;
  output jump_abs;
  output jump_z;
  output halt;
  output illegal;

  wire \<const0> ;
  wire [1:0]alu_a_sel;
  wire [1:0]alu_b_sel;
  wire [2:0]alu_op;
  wire cv_write;
  wire halt;
  wire illegal;
  wire imm_signed;
  wire [15:0]inst;
  wire jump_abs;
  wire jump_z;
  wire mem_read;
  wire mem_write;
  wire reg_write;
  wire use_rd;
  wire use_rs;
  wire z_write;

  assign imm[7] = \<const0> ;
  assign imm[6] = \<const0> ;
  assign imm[5] = \<const0> ;
  assign imm[4] = \<const0> ;
  assign imm[3] = \<const0> ;
  assign imm[2] = \<const0> ;
  assign imm[1] = \<const0> ;
  assign imm[0] = \<const0> ;
  assign rd[1] = \<const0> ;
  assign rd[0] = \<const0> ;
  assign rs[1] = \<const0> ;
  assign rs[0] = \<const0> ;
  assign wb_sel = \<const0> ;
  GND GND
       (.G(\<const0> ));
  (* SOFT_HLUTNM = "soft_lutpair14" *) 
  LUT4 #(
    .INIT(16'h3370)) 
    \alu_a_sel[0]_INST_0 
       (.I0(inst[12]),
        .I1(inst[15]),
        .I2(inst[13]),
        .I3(inst[14]),
        .O(alu_a_sel[0]));
  (* SOFT_HLUTNM = "soft_lutpair16" *) 
  LUT3 #(
    .INIT(8'h02)) 
    \alu_a_sel[1]_INST_0 
       (.I0(inst[15]),
        .I1(inst[14]),
        .I2(inst[13]),
        .O(alu_a_sel[1]));
  (* SOFT_HLUTNM = "soft_lutpair9" *) 
  LUT4 #(
    .INIT(16'h1171)) 
    \alu_b_sel[0]_INST_0 
       (.I0(inst[12]),
        .I1(inst[15]),
        .I2(inst[13]),
        .I3(inst[14]),
        .O(alu_b_sel[0]));
  (* SOFT_HLUTNM = "soft_lutpair9" *) 
  LUT4 #(
    .INIT(16'h1B10)) 
    \alu_b_sel[1]_INST_0 
       (.I0(inst[14]),
        .I1(inst[13]),
        .I2(inst[15]),
        .I3(inst[12]),
        .O(alu_b_sel[1]));
  (* SOFT_HLUTNM = "soft_lutpair10" *) 
  LUT4 #(
    .INIT(16'h0334)) 
    \alu_op[0]_INST_0 
       (.I0(inst[12]),
        .I1(inst[13]),
        .I2(inst[14]),
        .I3(inst[15]),
        .O(alu_op[0]));
  (* SOFT_HLUTNM = "soft_lutpair10" *) 
  LUT4 #(
    .INIT(16'h4500)) 
    \alu_op[1]_INST_0 
       (.I0(inst[15]),
        .I1(inst[14]),
        .I2(inst[12]),
        .I3(inst[13]),
        .O(alu_op[1]));
  (* SOFT_HLUTNM = "soft_lutpair11" *) 
  LUT4 #(
    .INIT(16'h1000)) 
    \alu_op[2]_INST_0 
       (.I0(inst[15]),
        .I1(inst[14]),
        .I2(inst[12]),
        .I3(inst[13]),
        .O(alu_op[2]));
  LUT2 #(
    .INIT(4'h2)) 
    cv_write_INST_0
       (.I0(inst[14]),
        .I1(inst[15]),
        .O(cv_write));
  (* SOFT_HLUTNM = "soft_lutpair13" *) 
  LUT4 #(
    .INIT(16'h2000)) 
    halt_INST_0
       (.I0(inst[14]),
        .I1(inst[12]),
        .I2(inst[15]),
        .I3(inst[13]),
        .O(halt));
  (* SOFT_HLUTNM = "soft_lutpair16" *) 
  LUT3 #(
    .INIT(8'h80)) 
    illegal_INST_0
       (.I0(inst[13]),
        .I1(inst[12]),
        .I2(inst[15]),
        .O(illegal));
  (* SOFT_HLUTNM = "soft_lutpair11" *) 
  LUT4 #(
    .INIT(16'h4500)) 
    imm_signed_INST_0
       (.I0(inst[13]),
        .I1(inst[12]),
        .I2(inst[14]),
        .I3(inst[15]),
        .O(imm_signed));
  (* SOFT_HLUTNM = "soft_lutpair13" *) 
  LUT4 #(
    .INIT(16'h1000)) 
    jump_abs_INST_0
       (.I0(inst[12]),
        .I1(inst[13]),
        .I2(inst[15]),
        .I3(inst[14]),
        .O(jump_abs));
  (* SOFT_HLUTNM = "soft_lutpair15" *) 
  LUT4 #(
    .INIT(16'h0080)) 
    jump_z_INST_0
       (.I0(inst[12]),
        .I1(inst[15]),
        .I2(inst[14]),
        .I3(inst[13]),
        .O(jump_z));
  (* SOFT_HLUTNM = "soft_lutpair14" *) 
  LUT4 #(
    .INIT(16'h0010)) 
    mem_read_INST_0
       (.I0(inst[12]),
        .I1(inst[14]),
        .I2(inst[15]),
        .I3(inst[13]),
        .O(mem_read));
  (* SOFT_HLUTNM = "soft_lutpair15" *) 
  LUT4 #(
    .INIT(16'h0008)) 
    mem_write_INST_0
       (.I0(inst[12]),
        .I1(inst[15]),
        .I2(inst[13]),
        .I3(inst[14]),
        .O(mem_write));
  (* SOFT_HLUTNM = "soft_lutpair12" *) 
  LUT4 #(
    .INIT(16'h5557)) 
    reg_write_INST_0
       (.I0(inst[15]),
        .I1(inst[14]),
        .I2(inst[12]),
        .I3(inst[13]),
        .O(reg_write));
  (* SOFT_HLUTNM = "soft_lutpair8" *) 
  LUT4 #(
    .INIT(16'h3738)) 
    use_rd_INST_0
       (.I0(inst[12]),
        .I1(inst[15]),
        .I2(inst[14]),
        .I3(inst[13]),
        .O(use_rd));
  (* SOFT_HLUTNM = "soft_lutpair8" *) 
  LUT4 #(
    .INIT(16'h1477)) 
    use_rs_INST_0
       (.I0(inst[14]),
        .I1(inst[15]),
        .I2(inst[13]),
        .I3(inst[12]),
        .O(use_rs));
  (* SOFT_HLUTNM = "soft_lutpair12" *) 
  LUT4 #(
    .INIT(16'h1000)) 
    z_write_INST_0
       (.I0(inst[12]),
        .I1(inst[14]),
        .I2(inst[13]),
        .I3(inst[15]),
        .O(z_write));
endmodule

module operand_forward
   (rd,
    rs,
    use_rd,
    use_rs,
    rd_value,
    rs_value,
    m_valid,
    m_fault,
    m_reg_write,
    m_mem_read,
    m_rd,
    m_value,
    w_valid,
    w_fault,
    w_reg_write,
    w_rd,
    w_value,
    rd_fwd,
    rs_fwd,
    rd_sel,
    rs_sel,
    blocked_rd,
    blocked_rs);
  input [1:0]rd;
  input [1:0]rs;
  input use_rd;
  input use_rs;
  input [15:0]rd_value;
  input [15:0]rs_value;
  input m_valid;
  input m_fault;
  input m_reg_write;
  input m_mem_read;
  input [1:0]m_rd;
  input [15:0]m_value;
  input w_valid;
  input w_fault;
  input w_reg_write;
  input [1:0]w_rd;
  input [15:0]w_value;
  output [15:0]rd_fwd;
  output [15:0]rs_fwd;
  output [1:0]rd_sel;
  output [1:0]rs_sel;
  output blocked_rd;
  output blocked_rs;

  wire \<const0> ;
  wire blocked_rd;
  wire blocked_rd_INST_0_i_1_n_0;
  wire blocked_rs;
  wire blocked_rs_INST_0_i_1_n_0;
  wire m_fault;
  wire m_mem_read;
  wire [1:0]m_rd;
  wire m_reg_write;
  wire m_valid;
  wire [15:0]m_value;
  wire [1:0]rd;
  wire [15:0]rd_fwd;
  wire \rd_fwd[15]_INST_0_i_1_n_0 ;
  wire \rd_fwd[15]_INST_0_i_2_n_0 ;
  wire \rd_fwd[15]_INST_0_i_3_n_0 ;
  wire \rd_fwd[15]_INST_0_i_4_n_0 ;
  wire \rd_fwd[15]_INST_0_i_5_n_0 ;
  wire \rd_fwd[15]_INST_0_i_6_n_0 ;
  wire [15:0]rd_value;
  wire [1:0]rs;
  wire [15:0]rs_fwd;
  wire \rs_fwd[15]_INST_0_i_1_n_0 ;
  wire \rs_fwd[15]_INST_0_i_2_n_0 ;
  wire \rs_fwd[15]_INST_0_i_3_n_0 ;
  wire \rs_fwd[15]_INST_0_i_4_n_0 ;
  wire [15:0]rs_value;
  wire use_rd;
  wire use_rs;
  wire w_fault;
  wire [1:0]w_rd;
  wire w_reg_write;
  wire w_valid;
  wire [15:0]w_value;

  assign rd_sel[1] = \<const0> ;
  assign rd_sel[0] = \<const0> ;
  assign rs_sel[1] = \<const0> ;
  assign rs_sel[0] = \<const0> ;
  GND GND
       (.G(\<const0> ));
  (* SOFT_HLUTNM = "soft_lutpair34" *) 
  LUT2 #(
    .INIT(4'h2)) 
    blocked_rd_INST_0
       (.I0(m_mem_read),
        .I1(blocked_rd_INST_0_i_1_n_0),
        .O(blocked_rd));
  LUT6 #(
    .INIT(64'hFFFF6FF6FFFFFFFF)) 
    blocked_rd_INST_0_i_1
       (.I0(rd[0]),
        .I1(m_rd[0]),
        .I2(rd[1]),
        .I3(m_rd[1]),
        .I4(\rd_fwd[15]_INST_0_i_6_n_0 ),
        .I5(use_rd),
        .O(blocked_rd_INST_0_i_1_n_0));
  (* SOFT_HLUTNM = "soft_lutpair34" *) 
  LUT2 #(
    .INIT(4'h2)) 
    blocked_rs_INST_0
       (.I0(m_mem_read),
        .I1(blocked_rs_INST_0_i_1_n_0),
        .O(blocked_rs));
  LUT6 #(
    .INIT(64'hFFFF6FF6FFFFFFFF)) 
    blocked_rs_INST_0_i_1
       (.I0(rs[0]),
        .I1(m_rd[0]),
        .I2(rs[1]),
        .I3(m_rd[1]),
        .I4(\rd_fwd[15]_INST_0_i_6_n_0 ),
        .I5(use_rs),
        .O(blocked_rs_INST_0_i_1_n_0));
  LUT5 #(
    .INIT(32'hACACFF0C)) 
    \rd_fwd[0]_INST_0 
       (.I0(rd_value[0]),
        .I1(w_value[0]),
        .I2(\rd_fwd[15]_INST_0_i_1_n_0 ),
        .I3(m_value[0]),
        .I4(\rd_fwd[15]_INST_0_i_2_n_0 ),
        .O(rd_fwd[0]));
  LUT5 #(
    .INIT(32'hACACFF0C)) 
    \rd_fwd[10]_INST_0 
       (.I0(rd_value[10]),
        .I1(w_value[10]),
        .I2(\rd_fwd[15]_INST_0_i_1_n_0 ),
        .I3(m_value[10]),
        .I4(\rd_fwd[15]_INST_0_i_2_n_0 ),
        .O(rd_fwd[10]));
  LUT5 #(
    .INIT(32'hACACFF0C)) 
    \rd_fwd[11]_INST_0 
       (.I0(rd_value[11]),
        .I1(w_value[11]),
        .I2(\rd_fwd[15]_INST_0_i_1_n_0 ),
        .I3(m_value[11]),
        .I4(\rd_fwd[15]_INST_0_i_2_n_0 ),
        .O(rd_fwd[11]));
  LUT5 #(
    .INIT(32'hACACFF0C)) 
    \rd_fwd[12]_INST_0 
       (.I0(rd_value[12]),
        .I1(w_value[12]),
        .I2(\rd_fwd[15]_INST_0_i_1_n_0 ),
        .I3(m_value[12]),
        .I4(\rd_fwd[15]_INST_0_i_2_n_0 ),
        .O(rd_fwd[12]));
  LUT5 #(
    .INIT(32'hACACFF0C)) 
    \rd_fwd[13]_INST_0 
       (.I0(rd_value[13]),
        .I1(w_value[13]),
        .I2(\rd_fwd[15]_INST_0_i_1_n_0 ),
        .I3(m_value[13]),
        .I4(\rd_fwd[15]_INST_0_i_2_n_0 ),
        .O(rd_fwd[13]));
  LUT5 #(
    .INIT(32'hACACFF0C)) 
    \rd_fwd[14]_INST_0 
       (.I0(rd_value[14]),
        .I1(w_value[14]),
        .I2(\rd_fwd[15]_INST_0_i_1_n_0 ),
        .I3(m_value[14]),
        .I4(\rd_fwd[15]_INST_0_i_2_n_0 ),
        .O(rd_fwd[14]));
  LUT5 #(
    .INIT(32'hACACFF0C)) 
    \rd_fwd[15]_INST_0 
       (.I0(rd_value[15]),
        .I1(w_value[15]),
        .I2(\rd_fwd[15]_INST_0_i_1_n_0 ),
        .I3(m_value[15]),
        .I4(\rd_fwd[15]_INST_0_i_2_n_0 ),
        .O(rd_fwd[15]));
  LUT5 #(
    .INIT(32'hFDFDFDFF)) 
    \rd_fwd[15]_INST_0_i_1 
       (.I0(use_rd),
        .I1(\rd_fwd[15]_INST_0_i_3_n_0 ),
        .I2(\rd_fwd[15]_INST_0_i_4_n_0 ),
        .I3(\rd_fwd[15]_INST_0_i_5_n_0 ),
        .I4(\rd_fwd[15]_INST_0_i_6_n_0 ),
        .O(\rd_fwd[15]_INST_0_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFFFFBFFFFF)) 
    \rd_fwd[15]_INST_0_i_2 
       (.I0(m_mem_read),
        .I1(use_rd),
        .I2(m_reg_write),
        .I3(m_fault),
        .I4(m_valid),
        .I5(\rd_fwd[15]_INST_0_i_5_n_0 ),
        .O(\rd_fwd[15]_INST_0_i_2_n_0 ));
  LUT3 #(
    .INIT(8'hDF)) 
    \rd_fwd[15]_INST_0_i_3 
       (.I0(w_reg_write),
        .I1(w_fault),
        .I2(w_valid),
        .O(\rd_fwd[15]_INST_0_i_3_n_0 ));
  LUT4 #(
    .INIT(16'h6FF6)) 
    \rd_fwd[15]_INST_0_i_4 
       (.I0(w_rd[1]),
        .I1(rd[1]),
        .I2(w_rd[0]),
        .I3(rd[0]),
        .O(\rd_fwd[15]_INST_0_i_4_n_0 ));
  LUT4 #(
    .INIT(16'h6FF6)) 
    \rd_fwd[15]_INST_0_i_5 
       (.I0(rd[0]),
        .I1(m_rd[0]),
        .I2(rd[1]),
        .I3(m_rd[1]),
        .O(\rd_fwd[15]_INST_0_i_5_n_0 ));
  LUT3 #(
    .INIT(8'hDF)) 
    \rd_fwd[15]_INST_0_i_6 
       (.I0(m_valid),
        .I1(m_fault),
        .I2(m_reg_write),
        .O(\rd_fwd[15]_INST_0_i_6_n_0 ));
  LUT5 #(
    .INIT(32'hACACFF0C)) 
    \rd_fwd[1]_INST_0 
       (.I0(rd_value[1]),
        .I1(w_value[1]),
        .I2(\rd_fwd[15]_INST_0_i_1_n_0 ),
        .I3(m_value[1]),
        .I4(\rd_fwd[15]_INST_0_i_2_n_0 ),
        .O(rd_fwd[1]));
  LUT5 #(
    .INIT(32'hACACFF0C)) 
    \rd_fwd[2]_INST_0 
       (.I0(rd_value[2]),
        .I1(w_value[2]),
        .I2(\rd_fwd[15]_INST_0_i_1_n_0 ),
        .I3(m_value[2]),
        .I4(\rd_fwd[15]_INST_0_i_2_n_0 ),
        .O(rd_fwd[2]));
  LUT5 #(
    .INIT(32'hACACFF0C)) 
    \rd_fwd[3]_INST_0 
       (.I0(rd_value[3]),
        .I1(w_value[3]),
        .I2(\rd_fwd[15]_INST_0_i_1_n_0 ),
        .I3(m_value[3]),
        .I4(\rd_fwd[15]_INST_0_i_2_n_0 ),
        .O(rd_fwd[3]));
  LUT5 #(
    .INIT(32'hACACFF0C)) 
    \rd_fwd[4]_INST_0 
       (.I0(rd_value[4]),
        .I1(w_value[4]),
        .I2(\rd_fwd[15]_INST_0_i_1_n_0 ),
        .I3(m_value[4]),
        .I4(\rd_fwd[15]_INST_0_i_2_n_0 ),
        .O(rd_fwd[4]));
  LUT5 #(
    .INIT(32'hACACFF0C)) 
    \rd_fwd[5]_INST_0 
       (.I0(rd_value[5]),
        .I1(w_value[5]),
        .I2(\rd_fwd[15]_INST_0_i_1_n_0 ),
        .I3(m_value[5]),
        .I4(\rd_fwd[15]_INST_0_i_2_n_0 ),
        .O(rd_fwd[5]));
  LUT5 #(
    .INIT(32'hACACFF0C)) 
    \rd_fwd[6]_INST_0 
       (.I0(rd_value[6]),
        .I1(w_value[6]),
        .I2(\rd_fwd[15]_INST_0_i_1_n_0 ),
        .I3(m_value[6]),
        .I4(\rd_fwd[15]_INST_0_i_2_n_0 ),
        .O(rd_fwd[6]));
  LUT5 #(
    .INIT(32'hACACFF0C)) 
    \rd_fwd[7]_INST_0 
       (.I0(rd_value[7]),
        .I1(w_value[7]),
        .I2(\rd_fwd[15]_INST_0_i_1_n_0 ),
        .I3(m_value[7]),
        .I4(\rd_fwd[15]_INST_0_i_2_n_0 ),
        .O(rd_fwd[7]));
  LUT5 #(
    .INIT(32'hACACFF0C)) 
    \rd_fwd[8]_INST_0 
       (.I0(rd_value[8]),
        .I1(w_value[8]),
        .I2(\rd_fwd[15]_INST_0_i_1_n_0 ),
        .I3(m_value[8]),
        .I4(\rd_fwd[15]_INST_0_i_2_n_0 ),
        .O(rd_fwd[8]));
  LUT5 #(
    .INIT(32'hACACFF0C)) 
    \rd_fwd[9]_INST_0 
       (.I0(rd_value[9]),
        .I1(w_value[9]),
        .I2(\rd_fwd[15]_INST_0_i_1_n_0 ),
        .I3(m_value[9]),
        .I4(\rd_fwd[15]_INST_0_i_2_n_0 ),
        .O(rd_fwd[9]));
  LUT5 #(
    .INIT(32'hACACFF0C)) 
    \rs_fwd[0]_INST_0 
       (.I0(rs_value[0]),
        .I1(w_value[0]),
        .I2(\rs_fwd[15]_INST_0_i_1_n_0 ),
        .I3(m_value[0]),
        .I4(\rs_fwd[15]_INST_0_i_2_n_0 ),
        .O(rs_fwd[0]));
  LUT5 #(
    .INIT(32'hACACFF0C)) 
    \rs_fwd[10]_INST_0 
       (.I0(rs_value[10]),
        .I1(w_value[10]),
        .I2(\rs_fwd[15]_INST_0_i_1_n_0 ),
        .I3(m_value[10]),
        .I4(\rs_fwd[15]_INST_0_i_2_n_0 ),
        .O(rs_fwd[10]));
  LUT5 #(
    .INIT(32'hACACFF0C)) 
    \rs_fwd[11]_INST_0 
       (.I0(rs_value[11]),
        .I1(w_value[11]),
        .I2(\rs_fwd[15]_INST_0_i_1_n_0 ),
        .I3(m_value[11]),
        .I4(\rs_fwd[15]_INST_0_i_2_n_0 ),
        .O(rs_fwd[11]));
  LUT5 #(
    .INIT(32'hACACFF0C)) 
    \rs_fwd[12]_INST_0 
       (.I0(rs_value[12]),
        .I1(w_value[12]),
        .I2(\rs_fwd[15]_INST_0_i_1_n_0 ),
        .I3(m_value[12]),
        .I4(\rs_fwd[15]_INST_0_i_2_n_0 ),
        .O(rs_fwd[12]));
  LUT5 #(
    .INIT(32'hACACFF0C)) 
    \rs_fwd[13]_INST_0 
       (.I0(rs_value[13]),
        .I1(w_value[13]),
        .I2(\rs_fwd[15]_INST_0_i_1_n_0 ),
        .I3(m_value[13]),
        .I4(\rs_fwd[15]_INST_0_i_2_n_0 ),
        .O(rs_fwd[13]));
  LUT5 #(
    .INIT(32'hACACFF0C)) 
    \rs_fwd[14]_INST_0 
       (.I0(rs_value[14]),
        .I1(w_value[14]),
        .I2(\rs_fwd[15]_INST_0_i_1_n_0 ),
        .I3(m_value[14]),
        .I4(\rs_fwd[15]_INST_0_i_2_n_0 ),
        .O(rs_fwd[14]));
  LUT5 #(
    .INIT(32'hACACFF0C)) 
    \rs_fwd[15]_INST_0 
       (.I0(rs_value[15]),
        .I1(w_value[15]),
        .I2(\rs_fwd[15]_INST_0_i_1_n_0 ),
        .I3(m_value[15]),
        .I4(\rs_fwd[15]_INST_0_i_2_n_0 ),
        .O(rs_fwd[15]));
  LUT5 #(
    .INIT(32'hFDFDFDFF)) 
    \rs_fwd[15]_INST_0_i_1 
       (.I0(use_rs),
        .I1(\rd_fwd[15]_INST_0_i_3_n_0 ),
        .I2(\rs_fwd[15]_INST_0_i_3_n_0 ),
        .I3(\rs_fwd[15]_INST_0_i_4_n_0 ),
        .I4(\rd_fwd[15]_INST_0_i_6_n_0 ),
        .O(\rs_fwd[15]_INST_0_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFFFFBFFFFF)) 
    \rs_fwd[15]_INST_0_i_2 
       (.I0(m_mem_read),
        .I1(use_rs),
        .I2(m_reg_write),
        .I3(m_fault),
        .I4(m_valid),
        .I5(\rs_fwd[15]_INST_0_i_4_n_0 ),
        .O(\rs_fwd[15]_INST_0_i_2_n_0 ));
  LUT4 #(
    .INIT(16'h6FF6)) 
    \rs_fwd[15]_INST_0_i_3 
       (.I0(w_rd[1]),
        .I1(rs[1]),
        .I2(w_rd[0]),
        .I3(rs[0]),
        .O(\rs_fwd[15]_INST_0_i_3_n_0 ));
  LUT4 #(
    .INIT(16'h6FF6)) 
    \rs_fwd[15]_INST_0_i_4 
       (.I0(rs[0]),
        .I1(m_rd[0]),
        .I2(rs[1]),
        .I3(m_rd[1]),
        .O(\rs_fwd[15]_INST_0_i_4_n_0 ));
  LUT5 #(
    .INIT(32'hACACFF0C)) 
    \rs_fwd[1]_INST_0 
       (.I0(rs_value[1]),
        .I1(w_value[1]),
        .I2(\rs_fwd[15]_INST_0_i_1_n_0 ),
        .I3(m_value[1]),
        .I4(\rs_fwd[15]_INST_0_i_2_n_0 ),
        .O(rs_fwd[1]));
  LUT5 #(
    .INIT(32'hACACFF0C)) 
    \rs_fwd[2]_INST_0 
       (.I0(rs_value[2]),
        .I1(w_value[2]),
        .I2(\rs_fwd[15]_INST_0_i_1_n_0 ),
        .I3(m_value[2]),
        .I4(\rs_fwd[15]_INST_0_i_2_n_0 ),
        .O(rs_fwd[2]));
  LUT5 #(
    .INIT(32'hACACFF0C)) 
    \rs_fwd[3]_INST_0 
       (.I0(rs_value[3]),
        .I1(w_value[3]),
        .I2(\rs_fwd[15]_INST_0_i_1_n_0 ),
        .I3(m_value[3]),
        .I4(\rs_fwd[15]_INST_0_i_2_n_0 ),
        .O(rs_fwd[3]));
  LUT5 #(
    .INIT(32'hACACFF0C)) 
    \rs_fwd[4]_INST_0 
       (.I0(rs_value[4]),
        .I1(w_value[4]),
        .I2(\rs_fwd[15]_INST_0_i_1_n_0 ),
        .I3(m_value[4]),
        .I4(\rs_fwd[15]_INST_0_i_2_n_0 ),
        .O(rs_fwd[4]));
  LUT5 #(
    .INIT(32'hACACFF0C)) 
    \rs_fwd[5]_INST_0 
       (.I0(rs_value[5]),
        .I1(w_value[5]),
        .I2(\rs_fwd[15]_INST_0_i_1_n_0 ),
        .I3(m_value[5]),
        .I4(\rs_fwd[15]_INST_0_i_2_n_0 ),
        .O(rs_fwd[5]));
  LUT5 #(
    .INIT(32'hACACFF0C)) 
    \rs_fwd[6]_INST_0 
       (.I0(rs_value[6]),
        .I1(w_value[6]),
        .I2(\rs_fwd[15]_INST_0_i_1_n_0 ),
        .I3(m_value[6]),
        .I4(\rs_fwd[15]_INST_0_i_2_n_0 ),
        .O(rs_fwd[6]));
  LUT5 #(
    .INIT(32'hACACFF0C)) 
    \rs_fwd[7]_INST_0 
       (.I0(rs_value[7]),
        .I1(w_value[7]),
        .I2(\rs_fwd[15]_INST_0_i_1_n_0 ),
        .I3(m_value[7]),
        .I4(\rs_fwd[15]_INST_0_i_2_n_0 ),
        .O(rs_fwd[7]));
  LUT5 #(
    .INIT(32'hACACFF0C)) 
    \rs_fwd[8]_INST_0 
       (.I0(rs_value[8]),
        .I1(w_value[8]),
        .I2(\rs_fwd[15]_INST_0_i_1_n_0 ),
        .I3(m_value[8]),
        .I4(\rs_fwd[15]_INST_0_i_2_n_0 ),
        .O(rs_fwd[8]));
  LUT5 #(
    .INIT(32'hACACFF0C)) 
    \rs_fwd[9]_INST_0 
       (.I0(rs_value[9]),
        .I1(w_value[9]),
        .I2(\rs_fwd[15]_INST_0_i_1_n_0 ),
        .I3(m_value[9]),
        .I4(\rs_fwd[15]_INST_0_i_2_n_0 ),
        .O(rs_fwd[9]));
endmodule

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
  wire hold;
  wire [15:0]p_1_in;
  wire [15:0]pc;
  wire [15:1]pc0;
  wire \pc[15]_i_1_n_0 ;
  wire \pc_reg[12]_i_2_n_0 ;
  wire \pc_reg[12]_i_2_n_1 ;
  wire \pc_reg[12]_i_2_n_2 ;
  wire \pc_reg[12]_i_2_n_3 ;
  wire \pc_reg[15]_i_3_n_2 ;
  wire \pc_reg[15]_i_3_n_3 ;
  wire \pc_reg[4]_i_2_n_0 ;
  wire \pc_reg[4]_i_2_n_1 ;
  wire \pc_reg[4]_i_2_n_2 ;
  wire \pc_reg[4]_i_2_n_3 ;
  wire \pc_reg[8]_i_2_n_0 ;
  wire \pc_reg[8]_i_2_n_1 ;
  wire \pc_reg[8]_i_2_n_2 ;
  wire \pc_reg[8]_i_2_n_3 ;
  wire redirect;
  wire rst;
  wire [15:0]target;
  wire [3:2]\NLW_pc_reg[15]_i_3_CO_UNCONNECTED ;
  wire [3:3]\NLW_pc_reg[15]_i_3_O_UNCONNECTED ;

  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT3 #(
    .INIT(8'hA3)) 
    \pc[0]_i_1 
       (.I0(target[0]),
        .I1(pc[0]),
        .I2(redirect),
        .O(p_1_in[0]));
  (* SOFT_HLUTNM = "soft_lutpair6" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \pc[10]_i_1 
       (.I0(target[10]),
        .I1(pc0[10]),
        .I2(redirect),
        .O(p_1_in[10]));
  (* SOFT_HLUTNM = "soft_lutpair6" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \pc[11]_i_1 
       (.I0(target[11]),
        .I1(pc0[11]),
        .I2(redirect),
        .O(p_1_in[11]));
  (* SOFT_HLUTNM = "soft_lutpair7" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \pc[12]_i_1 
       (.I0(target[12]),
        .I1(pc0[12]),
        .I2(redirect),
        .O(p_1_in[12]));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \pc[13]_i_1 
       (.I0(target[13]),
        .I1(pc0[13]),
        .I2(redirect),
        .O(p_1_in[13]));
  (* SOFT_HLUTNM = "soft_lutpair7" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \pc[14]_i_1 
       (.I0(target[14]),
        .I1(pc0[14]),
        .I2(redirect),
        .O(p_1_in[14]));
  LUT2 #(
    .INIT(4'hB)) 
    \pc[15]_i_1 
       (.I0(redirect),
        .I1(hold),
        .O(\pc[15]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \pc[15]_i_2 
       (.I0(target[15]),
        .I1(pc0[15]),
        .I2(redirect),
        .O(p_1_in[15]));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \pc[1]_i_1 
       (.I0(target[1]),
        .I1(pc0[1]),
        .I2(redirect),
        .O(p_1_in[1]));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \pc[2]_i_1 
       (.I0(target[2]),
        .I1(pc0[2]),
        .I2(redirect),
        .O(p_1_in[2]));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \pc[3]_i_1 
       (.I0(target[3]),
        .I1(pc0[3]),
        .I2(redirect),
        .O(p_1_in[3]));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \pc[4]_i_1 
       (.I0(target[4]),
        .I1(pc0[4]),
        .I2(redirect),
        .O(p_1_in[4]));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \pc[5]_i_1 
       (.I0(target[5]),
        .I1(pc0[5]),
        .I2(redirect),
        .O(p_1_in[5]));
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \pc[6]_i_1 
       (.I0(target[6]),
        .I1(pc0[6]),
        .I2(redirect),
        .O(p_1_in[6]));
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \pc[7]_i_1 
       (.I0(target[7]),
        .I1(pc0[7]),
        .I2(redirect),
        .O(p_1_in[7]));
  (* SOFT_HLUTNM = "soft_lutpair5" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \pc[8]_i_1 
       (.I0(target[8]),
        .I1(pc0[8]),
        .I2(redirect),
        .O(p_1_in[8]));
  (* SOFT_HLUTNM = "soft_lutpair5" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \pc[9]_i_1 
       (.I0(target[9]),
        .I1(pc0[9]),
        .I2(redirect),
        .O(p_1_in[9]));
  FDRE \pc_reg[0] 
       (.C(clk),
        .CE(\pc[15]_i_1_n_0 ),
        .D(p_1_in[0]),
        .Q(pc[0]),
        .R(rst));
  FDRE \pc_reg[10] 
       (.C(clk),
        .CE(\pc[15]_i_1_n_0 ),
        .D(p_1_in[10]),
        .Q(pc[10]),
        .R(rst));
  FDRE \pc_reg[11] 
       (.C(clk),
        .CE(\pc[15]_i_1_n_0 ),
        .D(p_1_in[11]),
        .Q(pc[11]),
        .R(rst));
  FDRE \pc_reg[12] 
       (.C(clk),
        .CE(\pc[15]_i_1_n_0 ),
        .D(p_1_in[12]),
        .Q(pc[12]),
        .R(rst));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \pc_reg[12]_i_2 
       (.CI(\pc_reg[8]_i_2_n_0 ),
        .CO({\pc_reg[12]_i_2_n_0 ,\pc_reg[12]_i_2_n_1 ,\pc_reg[12]_i_2_n_2 ,\pc_reg[12]_i_2_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O(pc0[12:9]),
        .S(pc[12:9]));
  FDRE \pc_reg[13] 
       (.C(clk),
        .CE(\pc[15]_i_1_n_0 ),
        .D(p_1_in[13]),
        .Q(pc[13]),
        .R(rst));
  FDRE \pc_reg[14] 
       (.C(clk),
        .CE(\pc[15]_i_1_n_0 ),
        .D(p_1_in[14]),
        .Q(pc[14]),
        .R(rst));
  FDRE \pc_reg[15] 
       (.C(clk),
        .CE(\pc[15]_i_1_n_0 ),
        .D(p_1_in[15]),
        .Q(pc[15]),
        .R(rst));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \pc_reg[15]_i_3 
       (.CI(\pc_reg[12]_i_2_n_0 ),
        .CO({\NLW_pc_reg[15]_i_3_CO_UNCONNECTED [3:2],\pc_reg[15]_i_3_n_2 ,\pc_reg[15]_i_3_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\NLW_pc_reg[15]_i_3_O_UNCONNECTED [3],pc0[15:13]}),
        .S({1'b0,pc[15:13]}));
  FDRE \pc_reg[1] 
       (.C(clk),
        .CE(\pc[15]_i_1_n_0 ),
        .D(p_1_in[1]),
        .Q(pc[1]),
        .R(rst));
  FDRE \pc_reg[2] 
       (.C(clk),
        .CE(\pc[15]_i_1_n_0 ),
        .D(p_1_in[2]),
        .Q(pc[2]),
        .R(rst));
  FDRE \pc_reg[3] 
       (.C(clk),
        .CE(\pc[15]_i_1_n_0 ),
        .D(p_1_in[3]),
        .Q(pc[3]),
        .R(rst));
  FDRE \pc_reg[4] 
       (.C(clk),
        .CE(\pc[15]_i_1_n_0 ),
        .D(p_1_in[4]),
        .Q(pc[4]),
        .R(rst));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \pc_reg[4]_i_2 
       (.CI(1'b0),
        .CO({\pc_reg[4]_i_2_n_0 ,\pc_reg[4]_i_2_n_1 ,\pc_reg[4]_i_2_n_2 ,\pc_reg[4]_i_2_n_3 }),
        .CYINIT(pc[0]),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O(pc0[4:1]),
        .S(pc[4:1]));
  FDRE \pc_reg[5] 
       (.C(clk),
        .CE(\pc[15]_i_1_n_0 ),
        .D(p_1_in[5]),
        .Q(pc[5]),
        .R(rst));
  FDRE \pc_reg[6] 
       (.C(clk),
        .CE(\pc[15]_i_1_n_0 ),
        .D(p_1_in[6]),
        .Q(pc[6]),
        .R(rst));
  FDRE \pc_reg[7] 
       (.C(clk),
        .CE(\pc[15]_i_1_n_0 ),
        .D(p_1_in[7]),
        .Q(pc[7]),
        .R(rst));
  FDRE \pc_reg[8] 
       (.C(clk),
        .CE(\pc[15]_i_1_n_0 ),
        .D(p_1_in[8]),
        .Q(pc[8]),
        .R(rst));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \pc_reg[8]_i_2 
       (.CI(\pc_reg[4]_i_2_n_0 ),
        .CO({\pc_reg[8]_i_2_n_0 ,\pc_reg[8]_i_2_n_1 ,\pc_reg[8]_i_2_n_2 ,\pc_reg[8]_i_2_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O(pc0[8:5]),
        .S(pc[8:5]));
  FDRE \pc_reg[9] 
       (.C(clk),
        .CE(\pc[15]_i_1_n_0 ),
        .D(p_1_in[9]),
        .Q(pc[9]),
        .R(rst));
endmodule

module regfile4x16
   (clk,
    rst,
    we,
    waddr,
    raddr_a,
    raddr_b,
    wdata,
    rdata_a,
    rdata_b);
  input clk;
  input rst;
  input we;
  input [1:0]waddr;
  input [1:0]raddr_a;
  input [1:0]raddr_b;
  input [15:0]wdata;
  output [15:0]rdata_a;
  output [15:0]rdata_b;

  wire clk;
  wire [1:0]raddr_a;
  wire [1:0]raddr_b;
  wire [15:0]rdata_a;
  wire rdata_a1;
  wire [15:0]rdata_b;
  wire rdata_b1;
  wire [0:0]regs;
  wire \regs[1][15]_i_1_n_0 ;
  wire \regs[2][15]_i_1_n_0 ;
  wire \regs[3][15]_i_1_n_0 ;
  wire [15:0]regs__0;
  wire [15:0]regs__0__0;
  wire [15:0]\regs_reg[0] ;
  wire [15:0]\regs_reg[1] ;
  wire [15:0]\regs_reg[2] ;
  wire [15:0]\regs_reg[3] ;
  wire rst;
  wire [1:0]waddr;
  wire [15:0]wdata;
  wire we;

  (* SOFT_HLUTNM = "soft_lutpair17" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \rdata_a[0]_INST_0 
       (.I0(wdata[0]),
        .I1(rdata_a1),
        .I2(regs__0[0]),
        .O(rdata_a[0]));
  LUT6 #(
    .INIT(64'hF0AAFFCCF0AA00CC)) 
    \rdata_a[0]_INST_0_i_1 
       (.I0(\regs_reg[1] [0]),
        .I1(\regs_reg[0] [0]),
        .I2(\regs_reg[3] [0]),
        .I3(raddr_a[1]),
        .I4(raddr_a[0]),
        .I5(\regs_reg[2] [0]),
        .O(regs__0[0]));
  (* SOFT_HLUTNM = "soft_lutpair27" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \rdata_a[10]_INST_0 
       (.I0(wdata[10]),
        .I1(rdata_a1),
        .I2(regs__0[10]),
        .O(rdata_a[10]));
  LUT6 #(
    .INIT(64'hF0AAFFCCF0AA00CC)) 
    \rdata_a[10]_INST_0_i_1 
       (.I0(\regs_reg[1] [10]),
        .I1(\regs_reg[0] [10]),
        .I2(\regs_reg[3] [10]),
        .I3(raddr_a[1]),
        .I4(raddr_a[0]),
        .I5(\regs_reg[2] [10]),
        .O(regs__0[10]));
  (* SOFT_HLUTNM = "soft_lutpair28" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \rdata_a[11]_INST_0 
       (.I0(wdata[11]),
        .I1(rdata_a1),
        .I2(regs__0[11]),
        .O(rdata_a[11]));
  LUT6 #(
    .INIT(64'hF0AAFFCCF0AA00CC)) 
    \rdata_a[11]_INST_0_i_1 
       (.I0(\regs_reg[1] [11]),
        .I1(\regs_reg[0] [11]),
        .I2(\regs_reg[3] [11]),
        .I3(raddr_a[1]),
        .I4(raddr_a[0]),
        .I5(\regs_reg[2] [11]),
        .O(regs__0[11]));
  (* SOFT_HLUTNM = "soft_lutpair29" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \rdata_a[12]_INST_0 
       (.I0(wdata[12]),
        .I1(rdata_a1),
        .I2(regs__0[12]),
        .O(rdata_a[12]));
  LUT6 #(
    .INIT(64'hF0AAFFCCF0AA00CC)) 
    \rdata_a[12]_INST_0_i_1 
       (.I0(\regs_reg[1] [12]),
        .I1(\regs_reg[0] [12]),
        .I2(\regs_reg[3] [12]),
        .I3(raddr_a[1]),
        .I4(raddr_a[0]),
        .I5(\regs_reg[2] [12]),
        .O(regs__0[12]));
  (* SOFT_HLUTNM = "soft_lutpair30" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \rdata_a[13]_INST_0 
       (.I0(wdata[13]),
        .I1(rdata_a1),
        .I2(regs__0[13]),
        .O(rdata_a[13]));
  LUT6 #(
    .INIT(64'hF0AAFFCCF0AA00CC)) 
    \rdata_a[13]_INST_0_i_1 
       (.I0(\regs_reg[1] [13]),
        .I1(\regs_reg[0] [13]),
        .I2(\regs_reg[3] [13]),
        .I3(raddr_a[1]),
        .I4(raddr_a[0]),
        .I5(\regs_reg[2] [13]),
        .O(regs__0[13]));
  (* SOFT_HLUTNM = "soft_lutpair31" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \rdata_a[14]_INST_0 
       (.I0(wdata[14]),
        .I1(rdata_a1),
        .I2(regs__0[14]),
        .O(rdata_a[14]));
  LUT6 #(
    .INIT(64'hF0AAFFCCF0AA00CC)) 
    \rdata_a[14]_INST_0_i_1 
       (.I0(\regs_reg[1] [14]),
        .I1(\regs_reg[0] [14]),
        .I2(\regs_reg[3] [14]),
        .I3(raddr_a[1]),
        .I4(raddr_a[0]),
        .I5(\regs_reg[2] [14]),
        .O(regs__0[14]));
  (* SOFT_HLUTNM = "soft_lutpair32" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \rdata_a[15]_INST_0 
       (.I0(wdata[15]),
        .I1(rdata_a1),
        .I2(regs__0[15]),
        .O(rdata_a[15]));
  LUT6 #(
    .INIT(64'h4004000000004004)) 
    \rdata_a[15]_INST_0_i_1 
       (.I0(rst),
        .I1(we),
        .I2(raddr_a[1]),
        .I3(waddr[1]),
        .I4(raddr_a[0]),
        .I5(waddr[0]),
        .O(rdata_a1));
  LUT6 #(
    .INIT(64'hF0AAFFCCF0AA00CC)) 
    \rdata_a[15]_INST_0_i_2 
       (.I0(\regs_reg[1] [15]),
        .I1(\regs_reg[0] [15]),
        .I2(\regs_reg[3] [15]),
        .I3(raddr_a[1]),
        .I4(raddr_a[0]),
        .I5(\regs_reg[2] [15]),
        .O(regs__0[15]));
  (* SOFT_HLUTNM = "soft_lutpair18" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \rdata_a[1]_INST_0 
       (.I0(wdata[1]),
        .I1(rdata_a1),
        .I2(regs__0[1]),
        .O(rdata_a[1]));
  LUT6 #(
    .INIT(64'hF0AAFFCCF0AA00CC)) 
    \rdata_a[1]_INST_0_i_1 
       (.I0(\regs_reg[1] [1]),
        .I1(\regs_reg[0] [1]),
        .I2(\regs_reg[3] [1]),
        .I3(raddr_a[1]),
        .I4(raddr_a[0]),
        .I5(\regs_reg[2] [1]),
        .O(regs__0[1]));
  (* SOFT_HLUTNM = "soft_lutpair19" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \rdata_a[2]_INST_0 
       (.I0(wdata[2]),
        .I1(rdata_a1),
        .I2(regs__0[2]),
        .O(rdata_a[2]));
  LUT6 #(
    .INIT(64'hF0AAFFCCF0AA00CC)) 
    \rdata_a[2]_INST_0_i_1 
       (.I0(\regs_reg[1] [2]),
        .I1(\regs_reg[0] [2]),
        .I2(\regs_reg[3] [2]),
        .I3(raddr_a[1]),
        .I4(raddr_a[0]),
        .I5(\regs_reg[2] [2]),
        .O(regs__0[2]));
  (* SOFT_HLUTNM = "soft_lutpair20" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \rdata_a[3]_INST_0 
       (.I0(wdata[3]),
        .I1(rdata_a1),
        .I2(regs__0[3]),
        .O(rdata_a[3]));
  LUT6 #(
    .INIT(64'hF0AAFFCCF0AA00CC)) 
    \rdata_a[3]_INST_0_i_1 
       (.I0(\regs_reg[1] [3]),
        .I1(\regs_reg[0] [3]),
        .I2(\regs_reg[3] [3]),
        .I3(raddr_a[1]),
        .I4(raddr_a[0]),
        .I5(\regs_reg[2] [3]),
        .O(regs__0[3]));
  (* SOFT_HLUTNM = "soft_lutpair21" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \rdata_a[4]_INST_0 
       (.I0(wdata[4]),
        .I1(rdata_a1),
        .I2(regs__0[4]),
        .O(rdata_a[4]));
  LUT6 #(
    .INIT(64'hF0AAFFCCF0AA00CC)) 
    \rdata_a[4]_INST_0_i_1 
       (.I0(\regs_reg[1] [4]),
        .I1(\regs_reg[0] [4]),
        .I2(\regs_reg[3] [4]),
        .I3(raddr_a[1]),
        .I4(raddr_a[0]),
        .I5(\regs_reg[2] [4]),
        .O(regs__0[4]));
  (* SOFT_HLUTNM = "soft_lutpair22" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \rdata_a[5]_INST_0 
       (.I0(wdata[5]),
        .I1(rdata_a1),
        .I2(regs__0[5]),
        .O(rdata_a[5]));
  LUT6 #(
    .INIT(64'hF0AAFFCCF0AA00CC)) 
    \rdata_a[5]_INST_0_i_1 
       (.I0(\regs_reg[1] [5]),
        .I1(\regs_reg[0] [5]),
        .I2(\regs_reg[3] [5]),
        .I3(raddr_a[1]),
        .I4(raddr_a[0]),
        .I5(\regs_reg[2] [5]),
        .O(regs__0[5]));
  (* SOFT_HLUTNM = "soft_lutpair23" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \rdata_a[6]_INST_0 
       (.I0(wdata[6]),
        .I1(rdata_a1),
        .I2(regs__0[6]),
        .O(rdata_a[6]));
  LUT6 #(
    .INIT(64'hF0AAFFCCF0AA00CC)) 
    \rdata_a[6]_INST_0_i_1 
       (.I0(\regs_reg[1] [6]),
        .I1(\regs_reg[0] [6]),
        .I2(\regs_reg[3] [6]),
        .I3(raddr_a[1]),
        .I4(raddr_a[0]),
        .I5(\regs_reg[2] [6]),
        .O(regs__0[6]));
  (* SOFT_HLUTNM = "soft_lutpair24" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \rdata_a[7]_INST_0 
       (.I0(wdata[7]),
        .I1(rdata_a1),
        .I2(regs__0[7]),
        .O(rdata_a[7]));
  LUT6 #(
    .INIT(64'hF0AAFFCCF0AA00CC)) 
    \rdata_a[7]_INST_0_i_1 
       (.I0(\regs_reg[1] [7]),
        .I1(\regs_reg[0] [7]),
        .I2(\regs_reg[3] [7]),
        .I3(raddr_a[1]),
        .I4(raddr_a[0]),
        .I5(\regs_reg[2] [7]),
        .O(regs__0[7]));
  (* SOFT_HLUTNM = "soft_lutpair25" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \rdata_a[8]_INST_0 
       (.I0(wdata[8]),
        .I1(rdata_a1),
        .I2(regs__0[8]),
        .O(rdata_a[8]));
  LUT6 #(
    .INIT(64'hF0AAFFCCF0AA00CC)) 
    \rdata_a[8]_INST_0_i_1 
       (.I0(\regs_reg[1] [8]),
        .I1(\regs_reg[0] [8]),
        .I2(\regs_reg[3] [8]),
        .I3(raddr_a[1]),
        .I4(raddr_a[0]),
        .I5(\regs_reg[2] [8]),
        .O(regs__0[8]));
  (* SOFT_HLUTNM = "soft_lutpair26" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \rdata_a[9]_INST_0 
       (.I0(wdata[9]),
        .I1(rdata_a1),
        .I2(regs__0[9]),
        .O(rdata_a[9]));
  LUT6 #(
    .INIT(64'hF0AAFFCCF0AA00CC)) 
    \rdata_a[9]_INST_0_i_1 
       (.I0(\regs_reg[1] [9]),
        .I1(\regs_reg[0] [9]),
        .I2(\regs_reg[3] [9]),
        .I3(raddr_a[1]),
        .I4(raddr_a[0]),
        .I5(\regs_reg[2] [9]),
        .O(regs__0[9]));
  (* SOFT_HLUTNM = "soft_lutpair17" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \rdata_b[0]_INST_0 
       (.I0(wdata[0]),
        .I1(rdata_b1),
        .I2(regs__0__0[0]),
        .O(rdata_b[0]));
  LUT6 #(
    .INIT(64'hF0AAFFCCF0AA00CC)) 
    \rdata_b[0]_INST_0_i_1 
       (.I0(\regs_reg[1] [0]),
        .I1(\regs_reg[0] [0]),
        .I2(\regs_reg[3] [0]),
        .I3(raddr_b[1]),
        .I4(raddr_b[0]),
        .I5(\regs_reg[2] [0]),
        .O(regs__0__0[0]));
  (* SOFT_HLUTNM = "soft_lutpair27" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \rdata_b[10]_INST_0 
       (.I0(wdata[10]),
        .I1(rdata_b1),
        .I2(regs__0__0[10]),
        .O(rdata_b[10]));
  LUT6 #(
    .INIT(64'hF0AAFFCCF0AA00CC)) 
    \rdata_b[10]_INST_0_i_1 
       (.I0(\regs_reg[1] [10]),
        .I1(\regs_reg[0] [10]),
        .I2(\regs_reg[3] [10]),
        .I3(raddr_b[1]),
        .I4(raddr_b[0]),
        .I5(\regs_reg[2] [10]),
        .O(regs__0__0[10]));
  (* SOFT_HLUTNM = "soft_lutpair28" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \rdata_b[11]_INST_0 
       (.I0(wdata[11]),
        .I1(rdata_b1),
        .I2(regs__0__0[11]),
        .O(rdata_b[11]));
  LUT6 #(
    .INIT(64'hF0AAFFCCF0AA00CC)) 
    \rdata_b[11]_INST_0_i_1 
       (.I0(\regs_reg[1] [11]),
        .I1(\regs_reg[0] [11]),
        .I2(\regs_reg[3] [11]),
        .I3(raddr_b[1]),
        .I4(raddr_b[0]),
        .I5(\regs_reg[2] [11]),
        .O(regs__0__0[11]));
  (* SOFT_HLUTNM = "soft_lutpair29" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \rdata_b[12]_INST_0 
       (.I0(wdata[12]),
        .I1(rdata_b1),
        .I2(regs__0__0[12]),
        .O(rdata_b[12]));
  LUT6 #(
    .INIT(64'hF0AAFFCCF0AA00CC)) 
    \rdata_b[12]_INST_0_i_1 
       (.I0(\regs_reg[1] [12]),
        .I1(\regs_reg[0] [12]),
        .I2(\regs_reg[3] [12]),
        .I3(raddr_b[1]),
        .I4(raddr_b[0]),
        .I5(\regs_reg[2] [12]),
        .O(regs__0__0[12]));
  (* SOFT_HLUTNM = "soft_lutpair30" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \rdata_b[13]_INST_0 
       (.I0(wdata[13]),
        .I1(rdata_b1),
        .I2(regs__0__0[13]),
        .O(rdata_b[13]));
  LUT6 #(
    .INIT(64'hF0AAFFCCF0AA00CC)) 
    \rdata_b[13]_INST_0_i_1 
       (.I0(\regs_reg[1] [13]),
        .I1(\regs_reg[0] [13]),
        .I2(\regs_reg[3] [13]),
        .I3(raddr_b[1]),
        .I4(raddr_b[0]),
        .I5(\regs_reg[2] [13]),
        .O(regs__0__0[13]));
  (* SOFT_HLUTNM = "soft_lutpair31" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \rdata_b[14]_INST_0 
       (.I0(wdata[14]),
        .I1(rdata_b1),
        .I2(regs__0__0[14]),
        .O(rdata_b[14]));
  LUT6 #(
    .INIT(64'hF0AAFFCCF0AA00CC)) 
    \rdata_b[14]_INST_0_i_1 
       (.I0(\regs_reg[1] [14]),
        .I1(\regs_reg[0] [14]),
        .I2(\regs_reg[3] [14]),
        .I3(raddr_b[1]),
        .I4(raddr_b[0]),
        .I5(\regs_reg[2] [14]),
        .O(regs__0__0[14]));
  (* SOFT_HLUTNM = "soft_lutpair32" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \rdata_b[15]_INST_0 
       (.I0(wdata[15]),
        .I1(rdata_b1),
        .I2(regs__0__0[15]),
        .O(rdata_b[15]));
  LUT6 #(
    .INIT(64'h4004000000004004)) 
    \rdata_b[15]_INST_0_i_1 
       (.I0(rst),
        .I1(we),
        .I2(raddr_b[1]),
        .I3(waddr[1]),
        .I4(raddr_b[0]),
        .I5(waddr[0]),
        .O(rdata_b1));
  LUT6 #(
    .INIT(64'hF0AAFFCCF0AA00CC)) 
    \rdata_b[15]_INST_0_i_2 
       (.I0(\regs_reg[1] [15]),
        .I1(\regs_reg[0] [15]),
        .I2(\regs_reg[3] [15]),
        .I3(raddr_b[1]),
        .I4(raddr_b[0]),
        .I5(\regs_reg[2] [15]),
        .O(regs__0__0[15]));
  (* SOFT_HLUTNM = "soft_lutpair18" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \rdata_b[1]_INST_0 
       (.I0(wdata[1]),
        .I1(rdata_b1),
        .I2(regs__0__0[1]),
        .O(rdata_b[1]));
  LUT6 #(
    .INIT(64'hF0AAFFCCF0AA00CC)) 
    \rdata_b[1]_INST_0_i_1 
       (.I0(\regs_reg[1] [1]),
        .I1(\regs_reg[0] [1]),
        .I2(\regs_reg[3] [1]),
        .I3(raddr_b[1]),
        .I4(raddr_b[0]),
        .I5(\regs_reg[2] [1]),
        .O(regs__0__0[1]));
  (* SOFT_HLUTNM = "soft_lutpair19" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \rdata_b[2]_INST_0 
       (.I0(wdata[2]),
        .I1(rdata_b1),
        .I2(regs__0__0[2]),
        .O(rdata_b[2]));
  LUT6 #(
    .INIT(64'hF0AAFFCCF0AA00CC)) 
    \rdata_b[2]_INST_0_i_1 
       (.I0(\regs_reg[1] [2]),
        .I1(\regs_reg[0] [2]),
        .I2(\regs_reg[3] [2]),
        .I3(raddr_b[1]),
        .I4(raddr_b[0]),
        .I5(\regs_reg[2] [2]),
        .O(regs__0__0[2]));
  (* SOFT_HLUTNM = "soft_lutpair20" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \rdata_b[3]_INST_0 
       (.I0(wdata[3]),
        .I1(rdata_b1),
        .I2(regs__0__0[3]),
        .O(rdata_b[3]));
  LUT6 #(
    .INIT(64'hF0AAFFCCF0AA00CC)) 
    \rdata_b[3]_INST_0_i_1 
       (.I0(\regs_reg[1] [3]),
        .I1(\regs_reg[0] [3]),
        .I2(\regs_reg[3] [3]),
        .I3(raddr_b[1]),
        .I4(raddr_b[0]),
        .I5(\regs_reg[2] [3]),
        .O(regs__0__0[3]));
  (* SOFT_HLUTNM = "soft_lutpair21" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \rdata_b[4]_INST_0 
       (.I0(wdata[4]),
        .I1(rdata_b1),
        .I2(regs__0__0[4]),
        .O(rdata_b[4]));
  LUT6 #(
    .INIT(64'hF0AAFFCCF0AA00CC)) 
    \rdata_b[4]_INST_0_i_1 
       (.I0(\regs_reg[1] [4]),
        .I1(\regs_reg[0] [4]),
        .I2(\regs_reg[3] [4]),
        .I3(raddr_b[1]),
        .I4(raddr_b[0]),
        .I5(\regs_reg[2] [4]),
        .O(regs__0__0[4]));
  (* SOFT_HLUTNM = "soft_lutpair22" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \rdata_b[5]_INST_0 
       (.I0(wdata[5]),
        .I1(rdata_b1),
        .I2(regs__0__0[5]),
        .O(rdata_b[5]));
  LUT6 #(
    .INIT(64'hF0AAFFCCF0AA00CC)) 
    \rdata_b[5]_INST_0_i_1 
       (.I0(\regs_reg[1] [5]),
        .I1(\regs_reg[0] [5]),
        .I2(\regs_reg[3] [5]),
        .I3(raddr_b[1]),
        .I4(raddr_b[0]),
        .I5(\regs_reg[2] [5]),
        .O(regs__0__0[5]));
  (* SOFT_HLUTNM = "soft_lutpair23" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \rdata_b[6]_INST_0 
       (.I0(wdata[6]),
        .I1(rdata_b1),
        .I2(regs__0__0[6]),
        .O(rdata_b[6]));
  LUT6 #(
    .INIT(64'hF0AAFFCCF0AA00CC)) 
    \rdata_b[6]_INST_0_i_1 
       (.I0(\regs_reg[1] [6]),
        .I1(\regs_reg[0] [6]),
        .I2(\regs_reg[3] [6]),
        .I3(raddr_b[1]),
        .I4(raddr_b[0]),
        .I5(\regs_reg[2] [6]),
        .O(regs__0__0[6]));
  (* SOFT_HLUTNM = "soft_lutpair24" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \rdata_b[7]_INST_0 
       (.I0(wdata[7]),
        .I1(rdata_b1),
        .I2(regs__0__0[7]),
        .O(rdata_b[7]));
  LUT6 #(
    .INIT(64'hF0AAFFCCF0AA00CC)) 
    \rdata_b[7]_INST_0_i_1 
       (.I0(\regs_reg[1] [7]),
        .I1(\regs_reg[0] [7]),
        .I2(\regs_reg[3] [7]),
        .I3(raddr_b[1]),
        .I4(raddr_b[0]),
        .I5(\regs_reg[2] [7]),
        .O(regs__0__0[7]));
  (* SOFT_HLUTNM = "soft_lutpair25" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \rdata_b[8]_INST_0 
       (.I0(wdata[8]),
        .I1(rdata_b1),
        .I2(regs__0__0[8]),
        .O(rdata_b[8]));
  LUT6 #(
    .INIT(64'hF0AAFFCCF0AA00CC)) 
    \rdata_b[8]_INST_0_i_1 
       (.I0(\regs_reg[1] [8]),
        .I1(\regs_reg[0] [8]),
        .I2(\regs_reg[3] [8]),
        .I3(raddr_b[1]),
        .I4(raddr_b[0]),
        .I5(\regs_reg[2] [8]),
        .O(regs__0__0[8]));
  (* SOFT_HLUTNM = "soft_lutpair26" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \rdata_b[9]_INST_0 
       (.I0(wdata[9]),
        .I1(rdata_b1),
        .I2(regs__0__0[9]),
        .O(rdata_b[9]));
  LUT6 #(
    .INIT(64'hF0AAFFCCF0AA00CC)) 
    \rdata_b[9]_INST_0_i_1 
       (.I0(\regs_reg[1] [9]),
        .I1(\regs_reg[0] [9]),
        .I2(\regs_reg[3] [9]),
        .I3(raddr_b[1]),
        .I4(raddr_b[0]),
        .I5(\regs_reg[2] [9]),
        .O(regs__0__0[9]));
  LUT3 #(
    .INIT(8'h02)) 
    \regs[0][15]_i_1 
       (.I0(we),
        .I1(waddr[0]),
        .I2(waddr[1]),
        .O(regs));
  LUT3 #(
    .INIT(8'h20)) 
    \regs[1][15]_i_1 
       (.I0(we),
        .I1(waddr[1]),
        .I2(waddr[0]),
        .O(\regs[1][15]_i_1_n_0 ));
  LUT3 #(
    .INIT(8'h20)) 
    \regs[2][15]_i_1 
       (.I0(we),
        .I1(waddr[0]),
        .I2(waddr[1]),
        .O(\regs[2][15]_i_1_n_0 ));
  LUT3 #(
    .INIT(8'h80)) 
    \regs[3][15]_i_1 
       (.I0(we),
        .I1(waddr[1]),
        .I2(waddr[0]),
        .O(\regs[3][15]_i_1_n_0 ));
  FDRE \regs_reg[0][0] 
       (.C(clk),
        .CE(regs),
        .D(wdata[0]),
        .Q(\regs_reg[0] [0]),
        .R(rst));
  FDRE \regs_reg[0][10] 
       (.C(clk),
        .CE(regs),
        .D(wdata[10]),
        .Q(\regs_reg[0] [10]),
        .R(rst));
  FDRE \regs_reg[0][11] 
       (.C(clk),
        .CE(regs),
        .D(wdata[11]),
        .Q(\regs_reg[0] [11]),
        .R(rst));
  FDRE \regs_reg[0][12] 
       (.C(clk),
        .CE(regs),
        .D(wdata[12]),
        .Q(\regs_reg[0] [12]),
        .R(rst));
  FDRE \regs_reg[0][13] 
       (.C(clk),
        .CE(regs),
        .D(wdata[13]),
        .Q(\regs_reg[0] [13]),
        .R(rst));
  FDRE \regs_reg[0][14] 
       (.C(clk),
        .CE(regs),
        .D(wdata[14]),
        .Q(\regs_reg[0] [14]),
        .R(rst));
  FDRE \regs_reg[0][15] 
       (.C(clk),
        .CE(regs),
        .D(wdata[15]),
        .Q(\regs_reg[0] [15]),
        .R(rst));
  FDRE \regs_reg[0][1] 
       (.C(clk),
        .CE(regs),
        .D(wdata[1]),
        .Q(\regs_reg[0] [1]),
        .R(rst));
  FDRE \regs_reg[0][2] 
       (.C(clk),
        .CE(regs),
        .D(wdata[2]),
        .Q(\regs_reg[0] [2]),
        .R(rst));
  FDRE \regs_reg[0][3] 
       (.C(clk),
        .CE(regs),
        .D(wdata[3]),
        .Q(\regs_reg[0] [3]),
        .R(rst));
  FDRE \regs_reg[0][4] 
       (.C(clk),
        .CE(regs),
        .D(wdata[4]),
        .Q(\regs_reg[0] [4]),
        .R(rst));
  FDRE \regs_reg[0][5] 
       (.C(clk),
        .CE(regs),
        .D(wdata[5]),
        .Q(\regs_reg[0] [5]),
        .R(rst));
  FDRE \regs_reg[0][6] 
       (.C(clk),
        .CE(regs),
        .D(wdata[6]),
        .Q(\regs_reg[0] [6]),
        .R(rst));
  FDRE \regs_reg[0][7] 
       (.C(clk),
        .CE(regs),
        .D(wdata[7]),
        .Q(\regs_reg[0] [7]),
        .R(rst));
  FDRE \regs_reg[0][8] 
       (.C(clk),
        .CE(regs),
        .D(wdata[8]),
        .Q(\regs_reg[0] [8]),
        .R(rst));
  FDRE \regs_reg[0][9] 
       (.C(clk),
        .CE(regs),
        .D(wdata[9]),
        .Q(\regs_reg[0] [9]),
        .R(rst));
  FDRE \regs_reg[1][0] 
       (.C(clk),
        .CE(\regs[1][15]_i_1_n_0 ),
        .D(wdata[0]),
        .Q(\regs_reg[1] [0]),
        .R(rst));
  FDRE \regs_reg[1][10] 
       (.C(clk),
        .CE(\regs[1][15]_i_1_n_0 ),
        .D(wdata[10]),
        .Q(\regs_reg[1] [10]),
        .R(rst));
  FDRE \regs_reg[1][11] 
       (.C(clk),
        .CE(\regs[1][15]_i_1_n_0 ),
        .D(wdata[11]),
        .Q(\regs_reg[1] [11]),
        .R(rst));
  FDRE \regs_reg[1][12] 
       (.C(clk),
        .CE(\regs[1][15]_i_1_n_0 ),
        .D(wdata[12]),
        .Q(\regs_reg[1] [12]),
        .R(rst));
  FDRE \regs_reg[1][13] 
       (.C(clk),
        .CE(\regs[1][15]_i_1_n_0 ),
        .D(wdata[13]),
        .Q(\regs_reg[1] [13]),
        .R(rst));
  FDRE \regs_reg[1][14] 
       (.C(clk),
        .CE(\regs[1][15]_i_1_n_0 ),
        .D(wdata[14]),
        .Q(\regs_reg[1] [14]),
        .R(rst));
  FDRE \regs_reg[1][15] 
       (.C(clk),
        .CE(\regs[1][15]_i_1_n_0 ),
        .D(wdata[15]),
        .Q(\regs_reg[1] [15]),
        .R(rst));
  FDRE \regs_reg[1][1] 
       (.C(clk),
        .CE(\regs[1][15]_i_1_n_0 ),
        .D(wdata[1]),
        .Q(\regs_reg[1] [1]),
        .R(rst));
  FDRE \regs_reg[1][2] 
       (.C(clk),
        .CE(\regs[1][15]_i_1_n_0 ),
        .D(wdata[2]),
        .Q(\regs_reg[1] [2]),
        .R(rst));
  FDRE \regs_reg[1][3] 
       (.C(clk),
        .CE(\regs[1][15]_i_1_n_0 ),
        .D(wdata[3]),
        .Q(\regs_reg[1] [3]),
        .R(rst));
  FDRE \regs_reg[1][4] 
       (.C(clk),
        .CE(\regs[1][15]_i_1_n_0 ),
        .D(wdata[4]),
        .Q(\regs_reg[1] [4]),
        .R(rst));
  FDRE \regs_reg[1][5] 
       (.C(clk),
        .CE(\regs[1][15]_i_1_n_0 ),
        .D(wdata[5]),
        .Q(\regs_reg[1] [5]),
        .R(rst));
  FDRE \regs_reg[1][6] 
       (.C(clk),
        .CE(\regs[1][15]_i_1_n_0 ),
        .D(wdata[6]),
        .Q(\regs_reg[1] [6]),
        .R(rst));
  FDRE \regs_reg[1][7] 
       (.C(clk),
        .CE(\regs[1][15]_i_1_n_0 ),
        .D(wdata[7]),
        .Q(\regs_reg[1] [7]),
        .R(rst));
  FDRE \regs_reg[1][8] 
       (.C(clk),
        .CE(\regs[1][15]_i_1_n_0 ),
        .D(wdata[8]),
        .Q(\regs_reg[1] [8]),
        .R(rst));
  FDRE \regs_reg[1][9] 
       (.C(clk),
        .CE(\regs[1][15]_i_1_n_0 ),
        .D(wdata[9]),
        .Q(\regs_reg[1] [9]),
        .R(rst));
  FDRE \regs_reg[2][0] 
       (.C(clk),
        .CE(\regs[2][15]_i_1_n_0 ),
        .D(wdata[0]),
        .Q(\regs_reg[2] [0]),
        .R(rst));
  FDRE \regs_reg[2][10] 
       (.C(clk),
        .CE(\regs[2][15]_i_1_n_0 ),
        .D(wdata[10]),
        .Q(\regs_reg[2] [10]),
        .R(rst));
  FDRE \regs_reg[2][11] 
       (.C(clk),
        .CE(\regs[2][15]_i_1_n_0 ),
        .D(wdata[11]),
        .Q(\regs_reg[2] [11]),
        .R(rst));
  FDRE \regs_reg[2][12] 
       (.C(clk),
        .CE(\regs[2][15]_i_1_n_0 ),
        .D(wdata[12]),
        .Q(\regs_reg[2] [12]),
        .R(rst));
  FDRE \regs_reg[2][13] 
       (.C(clk),
        .CE(\regs[2][15]_i_1_n_0 ),
        .D(wdata[13]),
        .Q(\regs_reg[2] [13]),
        .R(rst));
  FDRE \regs_reg[2][14] 
       (.C(clk),
        .CE(\regs[2][15]_i_1_n_0 ),
        .D(wdata[14]),
        .Q(\regs_reg[2] [14]),
        .R(rst));
  FDRE \regs_reg[2][15] 
       (.C(clk),
        .CE(\regs[2][15]_i_1_n_0 ),
        .D(wdata[15]),
        .Q(\regs_reg[2] [15]),
        .R(rst));
  FDRE \regs_reg[2][1] 
       (.C(clk),
        .CE(\regs[2][15]_i_1_n_0 ),
        .D(wdata[1]),
        .Q(\regs_reg[2] [1]),
        .R(rst));
  FDRE \regs_reg[2][2] 
       (.C(clk),
        .CE(\regs[2][15]_i_1_n_0 ),
        .D(wdata[2]),
        .Q(\regs_reg[2] [2]),
        .R(rst));
  FDRE \regs_reg[2][3] 
       (.C(clk),
        .CE(\regs[2][15]_i_1_n_0 ),
        .D(wdata[3]),
        .Q(\regs_reg[2] [3]),
        .R(rst));
  FDRE \regs_reg[2][4] 
       (.C(clk),
        .CE(\regs[2][15]_i_1_n_0 ),
        .D(wdata[4]),
        .Q(\regs_reg[2] [4]),
        .R(rst));
  FDRE \regs_reg[2][5] 
       (.C(clk),
        .CE(\regs[2][15]_i_1_n_0 ),
        .D(wdata[5]),
        .Q(\regs_reg[2] [5]),
        .R(rst));
  FDRE \regs_reg[2][6] 
       (.C(clk),
        .CE(\regs[2][15]_i_1_n_0 ),
        .D(wdata[6]),
        .Q(\regs_reg[2] [6]),
        .R(rst));
  FDRE \regs_reg[2][7] 
       (.C(clk),
        .CE(\regs[2][15]_i_1_n_0 ),
        .D(wdata[7]),
        .Q(\regs_reg[2] [7]),
        .R(rst));
  FDRE \regs_reg[2][8] 
       (.C(clk),
        .CE(\regs[2][15]_i_1_n_0 ),
        .D(wdata[8]),
        .Q(\regs_reg[2] [8]),
        .R(rst));
  FDRE \regs_reg[2][9] 
       (.C(clk),
        .CE(\regs[2][15]_i_1_n_0 ),
        .D(wdata[9]),
        .Q(\regs_reg[2] [9]),
        .R(rst));
  FDRE \regs_reg[3][0] 
       (.C(clk),
        .CE(\regs[3][15]_i_1_n_0 ),
        .D(wdata[0]),
        .Q(\regs_reg[3] [0]),
        .R(rst));
  FDRE \regs_reg[3][10] 
       (.C(clk),
        .CE(\regs[3][15]_i_1_n_0 ),
        .D(wdata[10]),
        .Q(\regs_reg[3] [10]),
        .R(rst));
  FDRE \regs_reg[3][11] 
       (.C(clk),
        .CE(\regs[3][15]_i_1_n_0 ),
        .D(wdata[11]),
        .Q(\regs_reg[3] [11]),
        .R(rst));
  FDRE \regs_reg[3][12] 
       (.C(clk),
        .CE(\regs[3][15]_i_1_n_0 ),
        .D(wdata[12]),
        .Q(\regs_reg[3] [12]),
        .R(rst));
  FDRE \regs_reg[3][13] 
       (.C(clk),
        .CE(\regs[3][15]_i_1_n_0 ),
        .D(wdata[13]),
        .Q(\regs_reg[3] [13]),
        .R(rst));
  FDRE \regs_reg[3][14] 
       (.C(clk),
        .CE(\regs[3][15]_i_1_n_0 ),
        .D(wdata[14]),
        .Q(\regs_reg[3] [14]),
        .R(rst));
  FDRE \regs_reg[3][15] 
       (.C(clk),
        .CE(\regs[3][15]_i_1_n_0 ),
        .D(wdata[15]),
        .Q(\regs_reg[3] [15]),
        .R(rst));
  FDRE \regs_reg[3][1] 
       (.C(clk),
        .CE(\regs[3][15]_i_1_n_0 ),
        .D(wdata[1]),
        .Q(\regs_reg[3] [1]),
        .R(rst));
  FDRE \regs_reg[3][2] 
       (.C(clk),
        .CE(\regs[3][15]_i_1_n_0 ),
        .D(wdata[2]),
        .Q(\regs_reg[3] [2]),
        .R(rst));
  FDRE \regs_reg[3][3] 
       (.C(clk),
        .CE(\regs[3][15]_i_1_n_0 ),
        .D(wdata[3]),
        .Q(\regs_reg[3] [3]),
        .R(rst));
  FDRE \regs_reg[3][4] 
       (.C(clk),
        .CE(\regs[3][15]_i_1_n_0 ),
        .D(wdata[4]),
        .Q(\regs_reg[3] [4]),
        .R(rst));
  FDRE \regs_reg[3][5] 
       (.C(clk),
        .CE(\regs[3][15]_i_1_n_0 ),
        .D(wdata[5]),
        .Q(\regs_reg[3] [5]),
        .R(rst));
  FDRE \regs_reg[3][6] 
       (.C(clk),
        .CE(\regs[3][15]_i_1_n_0 ),
        .D(wdata[6]),
        .Q(\regs_reg[3] [6]),
        .R(rst));
  FDRE \regs_reg[3][7] 
       (.C(clk),
        .CE(\regs[3][15]_i_1_n_0 ),
        .D(wdata[7]),
        .Q(\regs_reg[3] [7]),
        .R(rst));
  FDRE \regs_reg[3][8] 
       (.C(clk),
        .CE(\regs[3][15]_i_1_n_0 ),
        .D(wdata[8]),
        .Q(\regs_reg[3] [8]),
        .R(rst));
  FDRE \regs_reg[3][9] 
       (.C(clk),
        .CE(\regs[3][15]_i_1_n_0 ),
        .D(wdata[9]),
        .Q(\regs_reg[3] [9]),
        .R(rst));
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
