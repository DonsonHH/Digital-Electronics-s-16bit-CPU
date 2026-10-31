// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2025.2 (win64) Build 6299465 Fri Nov 14 19:35:11 GMT 2025
// Date        : Sat Oct 31 22:16:29 2026
// Host        : LAPTOP-BSM79J69 running 64-bit major release  (build 9200)
// Command     : write_verilog -mode funcsim eda/system_netlist.v
// Design      : cpu_system
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
  wire [3:1]NLW_carry_INST_0_CO_UNCONNECTED;
  wire [3:0]NLW_carry_INST_0_O_UNCONNECTED;

  CARRY4 carry_INST_0
       (.CI(\result[12]_INST_0_n_0 ),
        .CO({NLW_carry_INST_0_CO_UNCONNECTED[3:1],carry}),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O(NLW_carry_INST_0_O_UNCONNECTED[3:0]),
        .S({1'b0,1'b0,1'b0,1'b1}));
  LUT4 #(
    .INIT(16'h1824)) 
    overflow_INST_0
       (.I0(sub),
        .I1(result[15]),
        .I2(a[15]),
        .I3(b[15]),
        .O(overflow));
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

  (* SOFT_HLUTNM = "soft_lutpair43" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \target[0]_INST_0 
       (.I0(target0[0]),
        .I1(imm[0]),
        .I2(relative),
        .O(target[0]));
  (* SOFT_HLUTNM = "soft_lutpair44" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \target[10]_INST_0 
       (.I0(relative),
        .I1(target0[10]),
        .O(target[10]));
  (* SOFT_HLUTNM = "soft_lutpair43" *) 
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
  (* SOFT_HLUTNM = "soft_lutpair41" *) 
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
  (* SOFT_HLUTNM = "soft_lutpair40" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \target[14]_INST_0 
       (.I0(relative),
        .I1(target0[14]),
        .O(target[14]));
  (* SOFT_HLUTNM = "soft_lutpair39" *) 
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
  (* SOFT_HLUTNM = "soft_lutpair42" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \target[1]_INST_0 
       (.I0(target0[1]),
        .I1(imm[1]),
        .I2(relative),
        .O(target[1]));
  (* SOFT_HLUTNM = "soft_lutpair41" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \target[2]_INST_0 
       (.I0(target0[2]),
        .I1(imm[2]),
        .I2(relative),
        .O(target[2]));
  (* SOFT_HLUTNM = "soft_lutpair40" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \target[3]_INST_0 
       (.I0(target0[3]),
        .I1(imm[7]),
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
        .I1(imm[7]),
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
  (* SOFT_HLUTNM = "soft_lutpair39" *) 
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
  (* SOFT_HLUTNM = "soft_lutpair38" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \target[6]_INST_0 
       (.I0(target0[6]),
        .I1(imm[7]),
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
        .I1(imm[7]),
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
  (* SOFT_HLUTNM = "soft_lutpair42" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \target[9]_INST_0 
       (.I0(relative),
        .I1(target0[9]),
        .O(target[9]));
endmodule

(* DM_INIT_FILE = "programs/all_ops_dm.mem" *) (* IM_INIT_FILE = "programs/all_ops_im.mem" *) 
(* NotValidForBitStream *)
module cpu_system
   (clk,
    rst,
    halted,
    fault,
    observe_wb_valid,
    observe_wb_fault,
    observe_wb_halt,
    observe_wb_store,
    observe_rf_we,
    observe_z_we,
    observe_cv_we,
    observe_wb_rd,
    observe_wb_pc,
    observe_wb_data,
    observe_wb_flags,
    observe_stall,
    observe_redirect,
    observe_fetch_pc,
    observe_pipeline_valid,
    observe_flags,
    stop_valid,
    stop_pc_valid,
    stop_pc,
    stop_reason,
    last_completed_valid,
    last_completed_pc,
    rf_snapshot,
    observe_mem_en,
    observe_mem_we,
    observe_mem_addr,
    observe_mem_data,
    last_store_valid,
    last_store_addr,
    last_store_data);
  input clk;
  input rst;
  output halted;
  output fault;
  output observe_wb_valid;
  output observe_wb_fault;
  output observe_wb_halt;
  output observe_wb_store;
  output observe_rf_we;
  output observe_z_we;
  output observe_cv_we;
  output [1:0]observe_wb_rd;
  output [15:0]observe_wb_pc;
  output [15:0]observe_wb_data;
  output [2:0]observe_wb_flags;
  output observe_stall;
  output observe_redirect;
  output [15:0]observe_fetch_pc;
  output [3:0]observe_pipeline_valid;
  output [2:0]observe_flags;
  output stop_valid;
  output stop_pc_valid;
  output [15:0]stop_pc;
  output [2:0]stop_reason;
  output last_completed_valid;
  output [15:0]last_completed_pc;
  output [63:0]rf_snapshot;
  output observe_mem_en;
  output observe_mem_we;
  output [15:0]observe_mem_addr;
  output [15:0]observe_mem_data;
  output last_store_valid;
  output [15:0]last_store_addr;
  output [15:0]last_store_data;

  wire clk;
  wire [15:0]dm_dout;
  wire fault;
  wire halted;
  wire [15:0]im_dout;
  wire im_en;
  wire [15:0]last_completed_pc;
  wire last_completed_valid;
  wire [15:0]last_store_addr;
  wire [15:0]last_store_data;
  wire last_store_valid;
  wire observe_cv_we;
  wire [15:0]observe_fetch_pc;
  wire [2:0]observe_flags;
  wire [15:0]observe_mem_addr;
  wire [15:0]observe_mem_data;
  wire observe_mem_en;
  wire observe_mem_we;
  wire [3:0]observe_pipeline_valid;
  wire observe_redirect;
  wire observe_rf_we;
  wire observe_stall;
  wire [15:0]observe_wb_data;
  wire observe_wb_fault;
  wire [2:0]observe_wb_flags;
  wire observe_wb_halt;
  wire [15:0]observe_wb_pc;
  wire [1:0]observe_wb_rd;
  wire observe_wb_store;
  wire observe_wb_valid;
  wire observe_z_we;
  wire [0:0]rf_shadow;
  wire \rf_shadow[1][15]_i_1_n_0 ;
  wire \rf_shadow[2][15]_i_1_n_0 ;
  wire \rf_shadow[3][15]_i_1_n_0 ;
  wire [63:0]rf_snapshot;
  wire rst;
  wire [15:0]stop_pc;
  wire stop_pc_valid;
  wire [2:0]stop_reason;
  wire NLW_core_stop_pc_valid_UNCONNECTED;
  wire [15:0]NLW_core_im_addr_UNCONNECTED;
  wire [6:3]NLW_im_dout_UNCONNECTED;

  assign stop_valid = stop_pc_valid;
  (* DRAIN_FAULT = "3'b010" *) 
  (* DRAIN_HALT = "3'b001" *) 
  (* FAULTED = "3'b100" *) 
  (* HALTED = "3'b011" *) 
  (* RUN = "3'b000" *) 
  datapath_core core
       (.clk(clk),
        .dm_addr(observe_mem_addr),
        .dm_din(observe_mem_data),
        .dm_dout(dm_dout),
        .dm_en(observe_mem_en),
        .dm_we(observe_mem_we),
        .fault(fault),
        .halted(halted),
        .im_addr(NLW_core_im_addr_UNCONNECTED[15:0]),
        .im_dout({im_dout[15:7],1'b0,im_dout[5:4],1'b0,im_dout[2:0]}),
        .im_en(im_en),
        .last_completed_pc(last_completed_pc),
        .last_completed_valid(last_completed_valid),
        .observe_cv_we(observe_cv_we),
        .observe_fetch_pc(observe_fetch_pc),
        .observe_flags(observe_flags),
        .observe_pipeline_valid(observe_pipeline_valid),
        .observe_redirect(observe_redirect),
        .observe_rf_we(observe_rf_we),
        .observe_stall(observe_stall),
        .observe_wb_data(observe_wb_data),
        .observe_wb_fault(observe_wb_fault),
        .observe_wb_flags(observe_wb_flags),
        .observe_wb_halt(observe_wb_halt),
        .observe_wb_pc(observe_wb_pc),
        .observe_wb_rd(observe_wb_rd),
        .observe_wb_store(observe_wb_store),
        .observe_wb_valid(observe_wb_valid),
        .observe_z_we(observe_z_we),
        .rst(rst),
        .stop_pc(stop_pc),
        .stop_pc_valid(NLW_core_stop_pc_valid_UNCONNECTED),
        .stop_reason(stop_reason),
        .stop_valid(stop_pc_valid));
  (* INIT_FILE = "programs/all_ops_dm.mem" *) 
  data_memory dm
       (.addr(observe_mem_addr[7:0]),
        .clk(clk),
        .din(observe_mem_data),
        .dout(dm_dout),
        .en(observe_mem_en),
        .we(observe_mem_we));
  (* INIT_FILE = "programs/all_ops_im.mem" *) 
  instruction_memory im
       (.addr(observe_fetch_pc[7:0]),
        .clk(clk),
        .dout(im_dout),
        .en(im_en));
  FDRE \last_store_addr_reg[0] 
       (.C(clk),
        .CE(observe_mem_we),
        .D(observe_mem_addr[0]),
        .Q(last_store_addr[0]),
        .R(rst));
  FDRE \last_store_addr_reg[10] 
       (.C(clk),
        .CE(observe_mem_we),
        .D(observe_mem_addr[10]),
        .Q(last_store_addr[10]),
        .R(rst));
  FDRE \last_store_addr_reg[11] 
       (.C(clk),
        .CE(observe_mem_we),
        .D(observe_mem_addr[11]),
        .Q(last_store_addr[11]),
        .R(rst));
  FDRE \last_store_addr_reg[12] 
       (.C(clk),
        .CE(observe_mem_we),
        .D(observe_mem_addr[12]),
        .Q(last_store_addr[12]),
        .R(rst));
  FDRE \last_store_addr_reg[13] 
       (.C(clk),
        .CE(observe_mem_we),
        .D(observe_mem_addr[13]),
        .Q(last_store_addr[13]),
        .R(rst));
  FDRE \last_store_addr_reg[14] 
       (.C(clk),
        .CE(observe_mem_we),
        .D(observe_mem_addr[14]),
        .Q(last_store_addr[14]),
        .R(rst));
  FDRE \last_store_addr_reg[15] 
       (.C(clk),
        .CE(observe_mem_we),
        .D(observe_mem_addr[15]),
        .Q(last_store_addr[15]),
        .R(rst));
  FDRE \last_store_addr_reg[1] 
       (.C(clk),
        .CE(observe_mem_we),
        .D(observe_mem_addr[1]),
        .Q(last_store_addr[1]),
        .R(rst));
  FDRE \last_store_addr_reg[2] 
       (.C(clk),
        .CE(observe_mem_we),
        .D(observe_mem_addr[2]),
        .Q(last_store_addr[2]),
        .R(rst));
  FDRE \last_store_addr_reg[3] 
       (.C(clk),
        .CE(observe_mem_we),
        .D(observe_mem_addr[3]),
        .Q(last_store_addr[3]),
        .R(rst));
  FDRE \last_store_addr_reg[4] 
       (.C(clk),
        .CE(observe_mem_we),
        .D(observe_mem_addr[4]),
        .Q(last_store_addr[4]),
        .R(rst));
  FDRE \last_store_addr_reg[5] 
       (.C(clk),
        .CE(observe_mem_we),
        .D(observe_mem_addr[5]),
        .Q(last_store_addr[5]),
        .R(rst));
  FDRE \last_store_addr_reg[6] 
       (.C(clk),
        .CE(observe_mem_we),
        .D(observe_mem_addr[6]),
        .Q(last_store_addr[6]),
        .R(rst));
  FDRE \last_store_addr_reg[7] 
       (.C(clk),
        .CE(observe_mem_we),
        .D(observe_mem_addr[7]),
        .Q(last_store_addr[7]),
        .R(rst));
  FDRE \last_store_addr_reg[8] 
       (.C(clk),
        .CE(observe_mem_we),
        .D(observe_mem_addr[8]),
        .Q(last_store_addr[8]),
        .R(rst));
  FDRE \last_store_addr_reg[9] 
       (.C(clk),
        .CE(observe_mem_we),
        .D(observe_mem_addr[9]),
        .Q(last_store_addr[9]),
        .R(rst));
  FDRE \last_store_data_reg[0] 
       (.C(clk),
        .CE(observe_mem_we),
        .D(observe_mem_data[0]),
        .Q(last_store_data[0]),
        .R(rst));
  FDRE \last_store_data_reg[10] 
       (.C(clk),
        .CE(observe_mem_we),
        .D(observe_mem_data[10]),
        .Q(last_store_data[10]),
        .R(rst));
  FDRE \last_store_data_reg[11] 
       (.C(clk),
        .CE(observe_mem_we),
        .D(observe_mem_data[11]),
        .Q(last_store_data[11]),
        .R(rst));
  FDRE \last_store_data_reg[12] 
       (.C(clk),
        .CE(observe_mem_we),
        .D(observe_mem_data[12]),
        .Q(last_store_data[12]),
        .R(rst));
  FDRE \last_store_data_reg[13] 
       (.C(clk),
        .CE(observe_mem_we),
        .D(observe_mem_data[13]),
        .Q(last_store_data[13]),
        .R(rst));
  FDRE \last_store_data_reg[14] 
       (.C(clk),
        .CE(observe_mem_we),
        .D(observe_mem_data[14]),
        .Q(last_store_data[14]),
        .R(rst));
  FDRE \last_store_data_reg[15] 
       (.C(clk),
        .CE(observe_mem_we),
        .D(observe_mem_data[15]),
        .Q(last_store_data[15]),
        .R(rst));
  FDRE \last_store_data_reg[1] 
       (.C(clk),
        .CE(observe_mem_we),
        .D(observe_mem_data[1]),
        .Q(last_store_data[1]),
        .R(rst));
  FDRE \last_store_data_reg[2] 
       (.C(clk),
        .CE(observe_mem_we),
        .D(observe_mem_data[2]),
        .Q(last_store_data[2]),
        .R(rst));
  FDRE \last_store_data_reg[3] 
       (.C(clk),
        .CE(observe_mem_we),
        .D(observe_mem_data[3]),
        .Q(last_store_data[3]),
        .R(rst));
  FDRE \last_store_data_reg[4] 
       (.C(clk),
        .CE(observe_mem_we),
        .D(observe_mem_data[4]),
        .Q(last_store_data[4]),
        .R(rst));
  FDRE \last_store_data_reg[5] 
       (.C(clk),
        .CE(observe_mem_we),
        .D(observe_mem_data[5]),
        .Q(last_store_data[5]),
        .R(rst));
  FDRE \last_store_data_reg[6] 
       (.C(clk),
        .CE(observe_mem_we),
        .D(observe_mem_data[6]),
        .Q(last_store_data[6]),
        .R(rst));
  FDRE \last_store_data_reg[7] 
       (.C(clk),
        .CE(observe_mem_we),
        .D(observe_mem_data[7]),
        .Q(last_store_data[7]),
        .R(rst));
  FDRE \last_store_data_reg[8] 
       (.C(clk),
        .CE(observe_mem_we),
        .D(observe_mem_data[8]),
        .Q(last_store_data[8]),
        .R(rst));
  FDRE \last_store_data_reg[9] 
       (.C(clk),
        .CE(observe_mem_we),
        .D(observe_mem_data[9]),
        .Q(last_store_data[9]),
        .R(rst));
  FDRE last_store_valid_reg
       (.C(clk),
        .CE(observe_mem_we),
        .D(1'b1),
        .Q(last_store_valid),
        .R(rst));
  LUT3 #(
    .INIT(8'h02)) 
    \rf_shadow[0][15]_i_1 
       (.I0(observe_rf_we),
        .I1(observe_wb_rd[0]),
        .I2(observe_wb_rd[1]),
        .O(rf_shadow));
  LUT3 #(
    .INIT(8'h20)) 
    \rf_shadow[1][15]_i_1 
       (.I0(observe_rf_we),
        .I1(observe_wb_rd[1]),
        .I2(observe_wb_rd[0]),
        .O(\rf_shadow[1][15]_i_1_n_0 ));
  LUT3 #(
    .INIT(8'h20)) 
    \rf_shadow[2][15]_i_1 
       (.I0(observe_rf_we),
        .I1(observe_wb_rd[0]),
        .I2(observe_wb_rd[1]),
        .O(\rf_shadow[2][15]_i_1_n_0 ));
  LUT3 #(
    .INIT(8'h80)) 
    \rf_shadow[3][15]_i_1 
       (.I0(observe_rf_we),
        .I1(observe_wb_rd[0]),
        .I2(observe_wb_rd[1]),
        .O(\rf_shadow[3][15]_i_1_n_0 ));
  FDRE \rf_shadow_reg[0][0] 
       (.C(clk),
        .CE(rf_shadow),
        .D(observe_wb_data[0]),
        .Q(rf_snapshot[0]),
        .R(rst));
  FDRE \rf_shadow_reg[0][10] 
       (.C(clk),
        .CE(rf_shadow),
        .D(observe_wb_data[10]),
        .Q(rf_snapshot[10]),
        .R(rst));
  FDRE \rf_shadow_reg[0][11] 
       (.C(clk),
        .CE(rf_shadow),
        .D(observe_wb_data[11]),
        .Q(rf_snapshot[11]),
        .R(rst));
  FDRE \rf_shadow_reg[0][12] 
       (.C(clk),
        .CE(rf_shadow),
        .D(observe_wb_data[12]),
        .Q(rf_snapshot[12]),
        .R(rst));
  FDRE \rf_shadow_reg[0][13] 
       (.C(clk),
        .CE(rf_shadow),
        .D(observe_wb_data[13]),
        .Q(rf_snapshot[13]),
        .R(rst));
  FDRE \rf_shadow_reg[0][14] 
       (.C(clk),
        .CE(rf_shadow),
        .D(observe_wb_data[14]),
        .Q(rf_snapshot[14]),
        .R(rst));
  FDRE \rf_shadow_reg[0][15] 
       (.C(clk),
        .CE(rf_shadow),
        .D(observe_wb_data[15]),
        .Q(rf_snapshot[15]),
        .R(rst));
  FDRE \rf_shadow_reg[0][1] 
       (.C(clk),
        .CE(rf_shadow),
        .D(observe_wb_data[1]),
        .Q(rf_snapshot[1]),
        .R(rst));
  FDRE \rf_shadow_reg[0][2] 
       (.C(clk),
        .CE(rf_shadow),
        .D(observe_wb_data[2]),
        .Q(rf_snapshot[2]),
        .R(rst));
  FDRE \rf_shadow_reg[0][3] 
       (.C(clk),
        .CE(rf_shadow),
        .D(observe_wb_data[3]),
        .Q(rf_snapshot[3]),
        .R(rst));
  FDRE \rf_shadow_reg[0][4] 
       (.C(clk),
        .CE(rf_shadow),
        .D(observe_wb_data[4]),
        .Q(rf_snapshot[4]),
        .R(rst));
  FDRE \rf_shadow_reg[0][5] 
       (.C(clk),
        .CE(rf_shadow),
        .D(observe_wb_data[5]),
        .Q(rf_snapshot[5]),
        .R(rst));
  FDRE \rf_shadow_reg[0][6] 
       (.C(clk),
        .CE(rf_shadow),
        .D(observe_wb_data[6]),
        .Q(rf_snapshot[6]),
        .R(rst));
  FDRE \rf_shadow_reg[0][7] 
       (.C(clk),
        .CE(rf_shadow),
        .D(observe_wb_data[7]),
        .Q(rf_snapshot[7]),
        .R(rst));
  FDRE \rf_shadow_reg[0][8] 
       (.C(clk),
        .CE(rf_shadow),
        .D(observe_wb_data[8]),
        .Q(rf_snapshot[8]),
        .R(rst));
  FDRE \rf_shadow_reg[0][9] 
       (.C(clk),
        .CE(rf_shadow),
        .D(observe_wb_data[9]),
        .Q(rf_snapshot[9]),
        .R(rst));
  FDRE \rf_shadow_reg[1][0] 
       (.C(clk),
        .CE(\rf_shadow[1][15]_i_1_n_0 ),
        .D(observe_wb_data[0]),
        .Q(rf_snapshot[16]),
        .R(rst));
  FDRE \rf_shadow_reg[1][10] 
       (.C(clk),
        .CE(\rf_shadow[1][15]_i_1_n_0 ),
        .D(observe_wb_data[10]),
        .Q(rf_snapshot[26]),
        .R(rst));
  FDRE \rf_shadow_reg[1][11] 
       (.C(clk),
        .CE(\rf_shadow[1][15]_i_1_n_0 ),
        .D(observe_wb_data[11]),
        .Q(rf_snapshot[27]),
        .R(rst));
  FDRE \rf_shadow_reg[1][12] 
       (.C(clk),
        .CE(\rf_shadow[1][15]_i_1_n_0 ),
        .D(observe_wb_data[12]),
        .Q(rf_snapshot[28]),
        .R(rst));
  FDRE \rf_shadow_reg[1][13] 
       (.C(clk),
        .CE(\rf_shadow[1][15]_i_1_n_0 ),
        .D(observe_wb_data[13]),
        .Q(rf_snapshot[29]),
        .R(rst));
  FDRE \rf_shadow_reg[1][14] 
       (.C(clk),
        .CE(\rf_shadow[1][15]_i_1_n_0 ),
        .D(observe_wb_data[14]),
        .Q(rf_snapshot[30]),
        .R(rst));
  FDRE \rf_shadow_reg[1][15] 
       (.C(clk),
        .CE(\rf_shadow[1][15]_i_1_n_0 ),
        .D(observe_wb_data[15]),
        .Q(rf_snapshot[31]),
        .R(rst));
  FDRE \rf_shadow_reg[1][1] 
       (.C(clk),
        .CE(\rf_shadow[1][15]_i_1_n_0 ),
        .D(observe_wb_data[1]),
        .Q(rf_snapshot[17]),
        .R(rst));
  FDRE \rf_shadow_reg[1][2] 
       (.C(clk),
        .CE(\rf_shadow[1][15]_i_1_n_0 ),
        .D(observe_wb_data[2]),
        .Q(rf_snapshot[18]),
        .R(rst));
  FDRE \rf_shadow_reg[1][3] 
       (.C(clk),
        .CE(\rf_shadow[1][15]_i_1_n_0 ),
        .D(observe_wb_data[3]),
        .Q(rf_snapshot[19]),
        .R(rst));
  FDRE \rf_shadow_reg[1][4] 
       (.C(clk),
        .CE(\rf_shadow[1][15]_i_1_n_0 ),
        .D(observe_wb_data[4]),
        .Q(rf_snapshot[20]),
        .R(rst));
  FDRE \rf_shadow_reg[1][5] 
       (.C(clk),
        .CE(\rf_shadow[1][15]_i_1_n_0 ),
        .D(observe_wb_data[5]),
        .Q(rf_snapshot[21]),
        .R(rst));
  FDRE \rf_shadow_reg[1][6] 
       (.C(clk),
        .CE(\rf_shadow[1][15]_i_1_n_0 ),
        .D(observe_wb_data[6]),
        .Q(rf_snapshot[22]),
        .R(rst));
  FDRE \rf_shadow_reg[1][7] 
       (.C(clk),
        .CE(\rf_shadow[1][15]_i_1_n_0 ),
        .D(observe_wb_data[7]),
        .Q(rf_snapshot[23]),
        .R(rst));
  FDRE \rf_shadow_reg[1][8] 
       (.C(clk),
        .CE(\rf_shadow[1][15]_i_1_n_0 ),
        .D(observe_wb_data[8]),
        .Q(rf_snapshot[24]),
        .R(rst));
  FDRE \rf_shadow_reg[1][9] 
       (.C(clk),
        .CE(\rf_shadow[1][15]_i_1_n_0 ),
        .D(observe_wb_data[9]),
        .Q(rf_snapshot[25]),
        .R(rst));
  FDRE \rf_shadow_reg[2][0] 
       (.C(clk),
        .CE(\rf_shadow[2][15]_i_1_n_0 ),
        .D(observe_wb_data[0]),
        .Q(rf_snapshot[32]),
        .R(rst));
  FDRE \rf_shadow_reg[2][10] 
       (.C(clk),
        .CE(\rf_shadow[2][15]_i_1_n_0 ),
        .D(observe_wb_data[10]),
        .Q(rf_snapshot[42]),
        .R(rst));
  FDRE \rf_shadow_reg[2][11] 
       (.C(clk),
        .CE(\rf_shadow[2][15]_i_1_n_0 ),
        .D(observe_wb_data[11]),
        .Q(rf_snapshot[43]),
        .R(rst));
  FDRE \rf_shadow_reg[2][12] 
       (.C(clk),
        .CE(\rf_shadow[2][15]_i_1_n_0 ),
        .D(observe_wb_data[12]),
        .Q(rf_snapshot[44]),
        .R(rst));
  FDRE \rf_shadow_reg[2][13] 
       (.C(clk),
        .CE(\rf_shadow[2][15]_i_1_n_0 ),
        .D(observe_wb_data[13]),
        .Q(rf_snapshot[45]),
        .R(rst));
  FDRE \rf_shadow_reg[2][14] 
       (.C(clk),
        .CE(\rf_shadow[2][15]_i_1_n_0 ),
        .D(observe_wb_data[14]),
        .Q(rf_snapshot[46]),
        .R(rst));
  FDRE \rf_shadow_reg[2][15] 
       (.C(clk),
        .CE(\rf_shadow[2][15]_i_1_n_0 ),
        .D(observe_wb_data[15]),
        .Q(rf_snapshot[47]),
        .R(rst));
  FDRE \rf_shadow_reg[2][1] 
       (.C(clk),
        .CE(\rf_shadow[2][15]_i_1_n_0 ),
        .D(observe_wb_data[1]),
        .Q(rf_snapshot[33]),
        .R(rst));
  FDRE \rf_shadow_reg[2][2] 
       (.C(clk),
        .CE(\rf_shadow[2][15]_i_1_n_0 ),
        .D(observe_wb_data[2]),
        .Q(rf_snapshot[34]),
        .R(rst));
  FDRE \rf_shadow_reg[2][3] 
       (.C(clk),
        .CE(\rf_shadow[2][15]_i_1_n_0 ),
        .D(observe_wb_data[3]),
        .Q(rf_snapshot[35]),
        .R(rst));
  FDRE \rf_shadow_reg[2][4] 
       (.C(clk),
        .CE(\rf_shadow[2][15]_i_1_n_0 ),
        .D(observe_wb_data[4]),
        .Q(rf_snapshot[36]),
        .R(rst));
  FDRE \rf_shadow_reg[2][5] 
       (.C(clk),
        .CE(\rf_shadow[2][15]_i_1_n_0 ),
        .D(observe_wb_data[5]),
        .Q(rf_snapshot[37]),
        .R(rst));
  FDRE \rf_shadow_reg[2][6] 
       (.C(clk),
        .CE(\rf_shadow[2][15]_i_1_n_0 ),
        .D(observe_wb_data[6]),
        .Q(rf_snapshot[38]),
        .R(rst));
  FDRE \rf_shadow_reg[2][7] 
       (.C(clk),
        .CE(\rf_shadow[2][15]_i_1_n_0 ),
        .D(observe_wb_data[7]),
        .Q(rf_snapshot[39]),
        .R(rst));
  FDRE \rf_shadow_reg[2][8] 
       (.C(clk),
        .CE(\rf_shadow[2][15]_i_1_n_0 ),
        .D(observe_wb_data[8]),
        .Q(rf_snapshot[40]),
        .R(rst));
  FDRE \rf_shadow_reg[2][9] 
       (.C(clk),
        .CE(\rf_shadow[2][15]_i_1_n_0 ),
        .D(observe_wb_data[9]),
        .Q(rf_snapshot[41]),
        .R(rst));
  FDRE \rf_shadow_reg[3][0] 
       (.C(clk),
        .CE(\rf_shadow[3][15]_i_1_n_0 ),
        .D(observe_wb_data[0]),
        .Q(rf_snapshot[48]),
        .R(rst));
  FDRE \rf_shadow_reg[3][10] 
       (.C(clk),
        .CE(\rf_shadow[3][15]_i_1_n_0 ),
        .D(observe_wb_data[10]),
        .Q(rf_snapshot[58]),
        .R(rst));
  FDRE \rf_shadow_reg[3][11] 
       (.C(clk),
        .CE(\rf_shadow[3][15]_i_1_n_0 ),
        .D(observe_wb_data[11]),
        .Q(rf_snapshot[59]),
        .R(rst));
  FDRE \rf_shadow_reg[3][12] 
       (.C(clk),
        .CE(\rf_shadow[3][15]_i_1_n_0 ),
        .D(observe_wb_data[12]),
        .Q(rf_snapshot[60]),
        .R(rst));
  FDRE \rf_shadow_reg[3][13] 
       (.C(clk),
        .CE(\rf_shadow[3][15]_i_1_n_0 ),
        .D(observe_wb_data[13]),
        .Q(rf_snapshot[61]),
        .R(rst));
  FDRE \rf_shadow_reg[3][14] 
       (.C(clk),
        .CE(\rf_shadow[3][15]_i_1_n_0 ),
        .D(observe_wb_data[14]),
        .Q(rf_snapshot[62]),
        .R(rst));
  FDRE \rf_shadow_reg[3][15] 
       (.C(clk),
        .CE(\rf_shadow[3][15]_i_1_n_0 ),
        .D(observe_wb_data[15]),
        .Q(rf_snapshot[63]),
        .R(rst));
  FDRE \rf_shadow_reg[3][1] 
       (.C(clk),
        .CE(\rf_shadow[3][15]_i_1_n_0 ),
        .D(observe_wb_data[1]),
        .Q(rf_snapshot[49]),
        .R(rst));
  FDRE \rf_shadow_reg[3][2] 
       (.C(clk),
        .CE(\rf_shadow[3][15]_i_1_n_0 ),
        .D(observe_wb_data[2]),
        .Q(rf_snapshot[50]),
        .R(rst));
  FDRE \rf_shadow_reg[3][3] 
       (.C(clk),
        .CE(\rf_shadow[3][15]_i_1_n_0 ),
        .D(observe_wb_data[3]),
        .Q(rf_snapshot[51]),
        .R(rst));
  FDRE \rf_shadow_reg[3][4] 
       (.C(clk),
        .CE(\rf_shadow[3][15]_i_1_n_0 ),
        .D(observe_wb_data[4]),
        .Q(rf_snapshot[52]),
        .R(rst));
  FDRE \rf_shadow_reg[3][5] 
       (.C(clk),
        .CE(\rf_shadow[3][15]_i_1_n_0 ),
        .D(observe_wb_data[5]),
        .Q(rf_snapshot[53]),
        .R(rst));
  FDRE \rf_shadow_reg[3][6] 
       (.C(clk),
        .CE(\rf_shadow[3][15]_i_1_n_0 ),
        .D(observe_wb_data[6]),
        .Q(rf_snapshot[54]),
        .R(rst));
  FDRE \rf_shadow_reg[3][7] 
       (.C(clk),
        .CE(\rf_shadow[3][15]_i_1_n_0 ),
        .D(observe_wb_data[7]),
        .Q(rf_snapshot[55]),
        .R(rst));
  FDRE \rf_shadow_reg[3][8] 
       (.C(clk),
        .CE(\rf_shadow[3][15]_i_1_n_0 ),
        .D(observe_wb_data[8]),
        .Q(rf_snapshot[56]),
        .R(rst));
  FDRE \rf_shadow_reg[3][9] 
       (.C(clk),
        .CE(\rf_shadow[3][15]_i_1_n_0 ),
        .D(observe_wb_data[9]),
        .Q(rf_snapshot[57]),
        .R(rst));
endmodule

(* INIT_FILE = "programs/all_ops_dm.mem" *) 
module data_memory
   (clk,
    en,
    we,
    addr,
    din,
    dout);
  input clk;
  input en;
  input we;
  input [7:0]addr;
  input [15:0]din;
  output [15:0]dout;

  wire [7:0]addr;
  wire clk;
  wire [15:0]din;
  wire [15:0]dout;
  wire en;
  wire we;
  wire [15:0]NLW_mem_reg_DOBDO_UNCONNECTED;
  wire [1:0]NLW_mem_reg_DOPADOP_UNCONNECTED;
  wire [1:0]NLW_mem_reg_DOPBDOP_UNCONNECTED;

  (* \MEM.PORTA.DATA_BIT_LAYOUT  = "p0_d16" *) 
  (* METHODOLOGY_DRC_VIOS = "{SYNTH-6 {cell *THIS*}}" *) 
  (* RTL_RAM_BITS = "4096" *) 
  (* RTL_RAM_NAME = "data_memory/mem_reg" *) 
  (* RTL_RAM_STYLE = "block" *) 
  (* RTL_RAM_TYPE = "RAM_SP" *) 
  (* ram_addr_begin = "0" *) 
  (* ram_addr_end = "1023" *) 
  (* ram_offset = "0" *) 
  (* ram_slice_begin = "0" *) 
  (* ram_slice_end = "15" *) 
  RAMB18E1 #(
    .DOA_REG(0),
    .DOB_REG(0),
    .INITP_00(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_01(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_02(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_03(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_04(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_05(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_06(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_07(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_00(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_01(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_02(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_03(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_04(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_05(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_06(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_07(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_08(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_09(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_0A(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_0B(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_0C(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_0D(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_0E(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_0F(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_10(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_11(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_12(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_13(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_14(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_15(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_16(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_17(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_18(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_19(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_1A(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_1B(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_1C(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_1D(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_1E(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_1F(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_20(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_21(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_22(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_23(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_24(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_25(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_26(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_27(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_28(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_29(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_2A(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_2B(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_2C(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_2D(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_2E(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_2F(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_30(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_31(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_32(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_33(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_34(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_35(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_36(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_37(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_38(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_39(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_3A(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_3B(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_3C(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_3D(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_3E(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_3F(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_A(18'h00000),
    .INIT_B(18'h00000),
    .RAM_MODE("TDP"),
    .RDADDR_COLLISION_HWCONFIG("PERFORMANCE"),
    .READ_WIDTH_A(18),
    .READ_WIDTH_B(0),
    .RSTREG_PRIORITY_A("RSTREG"),
    .RSTREG_PRIORITY_B("RSTREG"),
    .SIM_COLLISION_CHECK("ALL"),
    .SIM_DEVICE("7SERIES"),
    .SRVAL_A(18'h00000),
    .SRVAL_B(18'h00000),
    .WRITE_MODE_A("NO_CHANGE"),
    .WRITE_MODE_B("WRITE_FIRST"),
    .WRITE_WIDTH_A(18),
    .WRITE_WIDTH_B(0)) 
    mem_reg
       (.ADDRARDADDR({1'b0,1'b0,addr,1'b0,1'b0,1'b0,1'b0}),
        .ADDRBWRADDR({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .CLKARDCLK(clk),
        .CLKBWRCLK(1'b0),
        .DIADI(din),
        .DIBDI({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .DIPADIP({1'b0,1'b0}),
        .DIPBDIP({1'b1,1'b1}),
        .DOADO(dout),
        .DOBDO(NLW_mem_reg_DOBDO_UNCONNECTED[15:0]),
        .DOPADOP(NLW_mem_reg_DOPADOP_UNCONNECTED[1:0]),
        .DOPBDOP(NLW_mem_reg_DOPBDOP_UNCONNECTED[1:0]),
        .ENARDEN(en),
        .ENBWREN(1'b0),
        .REGCEAREGCE(1'b0),
        .REGCEB(1'b0),
        .RSTRAMARSTRAM(1'b0),
        .RSTRAMB(1'b0),
        .RSTREGARSTREG(1'b0),
        .RSTREGB(1'b0),
        .WEA({we,we}),
        .WEBWE({1'b0,1'b0,1'b0,1'b0}));
endmodule

(* DRAIN_FAULT = "3'b010" *) (* DRAIN_HALT = "3'b001" *) (* FAULTED = "3'b100" *) 
(* HALTED = "3'b011" *) (* RUN = "3'b000" *) 
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
    fault,
    observe_wb_valid,
    observe_wb_fault,
    observe_wb_halt,
    observe_wb_store,
    observe_rf_we,
    observe_z_we,
    observe_cv_we,
    observe_wb_rd,
    observe_wb_pc,
    observe_wb_data,
    observe_wb_flags,
    observe_stall,
    observe_redirect,
    observe_fetch_pc,
    observe_pipeline_valid,
    observe_flags,
    stop_valid,
    stop_pc_valid,
    stop_pc,
    stop_reason,
    last_completed_valid,
    last_completed_pc);
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
  output observe_wb_valid;
  output observe_wb_fault;
  output observe_wb_halt;
  output observe_wb_store;
  output observe_rf_we;
  output observe_z_we;
  output observe_cv_we;
  output [1:0]observe_wb_rd;
  output [15:0]observe_wb_pc;
  output [15:0]observe_wb_data;
  output [2:0]observe_wb_flags;
  output observe_stall;
  output observe_redirect;
  output [15:0]observe_fetch_pc;
  output [3:0]observe_pipeline_valid;
  output [2:0]observe_flags;
  output stop_valid;
  output stop_pc_valid;
  output [15:0]stop_pc;
  output [2:0]stop_reason;
  output last_completed_valid;
  output [15:0]last_completed_pc;

  wire \<const0> ;
  (* RTL_KEEP = "true" *) wire C;
  wire \FSM_sequential_mode[0]_i_1_n_0 ;
  wire \FSM_sequential_mode[0]_i_2_n_0 ;
  wire \FSM_sequential_mode[0]_i_3_n_0 ;
  wire \FSM_sequential_mode[1]_i_1_n_0 ;
  wire \FSM_sequential_mode[1]_i_2_n_0 ;
  wire \FSM_sequential_mode[2]_i_1_n_0 ;
  wire \FSM_sequential_mode[2]_i_2_n_0 ;
  wire \FSM_sequential_mode[2]_i_3_n_0 ;
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
  wire [1:0]d_alu_a_sel;
  wire [1:0]d_alu_b_sel;
  wire [2:0]d_alu_op;
  wire d_cv_write;
  wire d_fetch_fault;
  wire d_fetch_fault_i_1_n_0;
  wire d_halt;
  wire d_illegal;
  wire [11:11]d_imm_ext;
  wire d_imm_signed;
  wire d_jump_abs;
  wire d_jump_z;
  wire d_mem_read;
  wire d_mem_write;
  wire [15:0]d_pc;
  wire \d_pc[15]_i_1_n_0 ;
  wire [15:0]d_rd_value;
  wire d_reg_write;
  wire [15:0]d_rs_value;
  wire d_use_rd;
  wire d_use_rs;
  wire d_valid_next6_out;
  wire d_z_write;
  wire [15:0]dm_addr;
  wire [15:0]dm_din;
  wire [15:0]dm_dout;
  wire dm_en;
  wire dm_en_INST_0_i_1_n_0;
  wire dm_en_INST_0_i_2_n_0;
  wire dm_we;
  wire fault;
  wire halted;
  wire [15:0]im_dout;
  wire im_en;
  wire im_en_INST_0_i_1_n_0;
  wire im_en_INST_0_i_2_n_0;
  wire im_en_INST_0_i_3_n_0;
  wire im_en_INST_0_i_4_n_0;
  wire im_en_INST_0_i_5_n_0;
  wire im_en_INST_0_i_6_n_0;
  wire im_en_INST_0_i_7_n_0;
  wire [15:0]last_completed_pc;
  wire last_completed_valid;
  wire last_completed_valid0;
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
  wire [15:0]m_pc;
  wire [1:0]m_rd;
  wire [2:0]m_reason;
  wire \m_reason[0]_i_1_n_0 ;
  wire \m_reason[1]_i_1_n_0 ;
  wire \m_reason[2]_i_1_n_0 ;
  wire m_reg_write;
  wire m_reg_write0;
  wire m_v;
  wire m_valid_i_2_n_0;
  wire m_valid_next;
  wire m_wb_sel;
  wire m_z_write;
  wire m_z_write0;
  wire m_z_write_i_2_n_0;
  wire [2:0]mode;
  wire observe_cv_we;
  wire [15:0]observe_fetch_pc;
  wire [3:0]observe_pipeline_valid;
  wire observe_redirect;
  wire observe_redirect_INST_0_i_10_n_0;
  wire observe_redirect_INST_0_i_1_n_0;
  wire observe_redirect_INST_0_i_2_n_0;
  wire observe_redirect_INST_0_i_3_n_0;
  wire observe_redirect_INST_0_i_4_n_0;
  wire observe_redirect_INST_0_i_5_n_0;
  wire observe_redirect_INST_0_i_6_n_0;
  wire observe_redirect_INST_0_i_7_n_0;
  wire observe_redirect_INST_0_i_8_n_0;
  wire observe_redirect_INST_0_i_9_n_0;
  wire observe_rf_we;
  wire observe_stall;
  wire [15:0]observe_wb_data;
  wire observe_wb_fault;
  wire [2:0]observe_wb_flags;
  wire observe_wb_halt;
  wire [15:0]observe_wb_pc;
  wire [1:0]observe_wb_rd;
  wire observe_wb_store;
  wire observe_wb_valid;
  wire observe_z_we;
  wire observe_z_we_INST_0_i_1_n_0;
  wire pc_hold;
  wire [15:0]rs_fwd;
  wire rst;
  wire [15:0]stop_pc;
  wire [2:0]stop_reason;
  wire \stop_reason[0]_i_1_n_0 ;
  wire \stop_reason[1]_i_1_n_0 ;
  wire \stop_reason[2]_i_1_n_0 ;
  wire stop_valid;
  wire stop_valid141_out;
  wire stop_valid_i_2_n_0;
  wire stop_valid_i_3_n_0;
  wire stop_valid_i_4_n_0;
  wire stop_valid_i_5_n_0;
  wire w_cv_write;
  wire w_cv_write0;
  wire [15:0]w_exec_value;
  wire w_fault;
  wire w_fault0;
  wire w_halt;
  wire w_halt0;
  wire [2:0]w_reason;
  wire \w_reason[0]_i_1_n_0 ;
  wire \w_reason[1]_i_1_n_0 ;
  wire \w_reason[2]_i_1_n_0 ;
  wire w_reg_write;
  wire w_reg_write0;
  (* RTL_KEEP = "true" *) wire w_store;
  wire w_store_reg0;
  wire w_valid_next;
  wire w_wb_sel;
  wire w_z_write;
  wire w_z_write0;
  wire [1:0]x_alu_a_sel;
  wire [1:0]x_alu_b_sel;
  wire [2:0]x_alu_op;
  wire x_cv_write;
  wire x_cv_write0;
  wire x_fault;
  wire x_halt;
  wire x_halt0;
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
  wire [0:0]x_reason;
  wire x_reason2;
  wire \x_reason[0]_i_1_n_0 ;
  wire x_reg_write;
  wire x_reg_write0;
  wire [1:0]x_rs;
  wire [15:0]x_rs_value;
  wire [15:0]x_store_data;
  wire x_use_rd;
  wire x_use_rd0;
  wire x_use_rs;
  wire x_use_rs0;
  wire x_valid_next;
  wire x_wb_sel;
  wire x_z_write;
  wire x_z_write0;
  wire NLW_u_decode_wb_sel_UNCONNECTED;
  wire [7:0]NLW_u_decode_imm_UNCONNECTED;
  wire [1:0]NLW_u_decode_rd_UNCONNECTED;
  wire [1:0]NLW_u_decode_rs_UNCONNECTED;
  wire [15:0]NLW_u_ext_value_UNCONNECTED;
  wire [1:0]NLW_u_forward_rd_sel_UNCONNECTED;
  wire [1:0]NLW_u_forward_rs_sel_UNCONNECTED;

  assign im_addr[15] = \<const0> ;
  assign im_addr[14] = \<const0> ;
  assign im_addr[13] = \<const0> ;
  assign im_addr[12] = \<const0> ;
  assign im_addr[11] = \<const0> ;
  assign im_addr[10] = \<const0> ;
  assign im_addr[9] = \<const0> ;
  assign im_addr[8] = \<const0> ;
  assign im_addr[7] = \<const0> ;
  assign im_addr[6] = \<const0> ;
  assign im_addr[5] = \<const0> ;
  assign im_addr[4] = \<const0> ;
  assign im_addr[3] = \<const0> ;
  assign im_addr[2] = \<const0> ;
  assign im_addr[1] = \<const0> ;
  assign im_addr[0] = \<const0> ;
  assign observe_flags[2] = Z;
  assign observe_flags[1] = C;
  assign observe_flags[0] = V;
  assign stop_pc_valid = \<const0> ;
  (* SOFT_HLUTNM = "soft_lutpair47" *) 
  LUT5 #(
    .INIT(32'h11FF0200)) 
    \FSM_sequential_mode[0]_i_1 
       (.I0(\FSM_sequential_mode[0]_i_2_n_0 ),
        .I1(\FSM_sequential_mode[0]_i_3_n_0 ),
        .I2(mode[1]),
        .I3(mode[2]),
        .I4(mode[0]),
        .O(\FSM_sequential_mode[0]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair49" *) 
  LUT5 #(
    .INIT(32'h02000000)) 
    \FSM_sequential_mode[0]_i_2 
       (.I0(observe_pipeline_valid[2]),
        .I1(x_fault),
        .I2(m_z_write_i_2_n_0),
        .I3(x_halt),
        .I4(observe_redirect_INST_0_i_3_n_0),
        .O(\FSM_sequential_mode[0]_i_2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair48" *) 
  LUT5 #(
    .INIT(32'hFD550000)) 
    \FSM_sequential_mode[0]_i_3 
       (.I0(observe_redirect_INST_0_i_4_n_0),
        .I1(m_z_write_i_2_n_0),
        .I2(x_fault),
        .I3(observe_pipeline_valid[2]),
        .I4(observe_redirect_INST_0_i_3_n_0),
        .O(\FSM_sequential_mode[0]_i_3_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair46" *) 
  LUT5 #(
    .INIT(32'h34340030)) 
    \FSM_sequential_mode[1]_i_1 
       (.I0(mode[0]),
        .I1(\FSM_sequential_mode[1]_i_2_n_0 ),
        .I2(mode[1]),
        .I3(stop_valid_i_2_n_0),
        .I4(mode[2]),
        .O(\FSM_sequential_mode[1]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hCCCCCCC444444444)) 
    \FSM_sequential_mode[1]_i_2 
       (.I0(observe_redirect_INST_0_i_4_n_0),
        .I1(observe_redirect_INST_0_i_3_n_0),
        .I2(x_halt),
        .I3(m_z_write_i_2_n_0),
        .I4(x_fault),
        .I5(observe_pipeline_valid[2]),
        .O(\FSM_sequential_mode[1]_i_2_n_0 ));
  LUT4 #(
    .INIT(16'h3700)) 
    \FSM_sequential_mode[2]_i_1 
       (.I0(\FSM_sequential_mode[2]_i_2_n_0 ),
        .I1(observe_redirect_INST_0_i_3_n_0),
        .I2(\FSM_sequential_mode[2]_i_3_n_0 ),
        .I3(mode[2]),
        .O(\FSM_sequential_mode[2]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair49" *) 
  LUT4 #(
    .INIT(16'h0200)) 
    \FSM_sequential_mode[2]_i_2 
       (.I0(x_halt),
        .I1(m_z_write_i_2_n_0),
        .I2(x_fault),
        .I3(observe_pipeline_valid[2]),
        .O(\FSM_sequential_mode[2]_i_2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair48" *) 
  LUT4 #(
    .INIT(16'hA8FF)) 
    \FSM_sequential_mode[2]_i_3 
       (.I0(observe_pipeline_valid[2]),
        .I1(x_fault),
        .I2(m_z_write_i_2_n_0),
        .I3(observe_redirect_INST_0_i_4_n_0),
        .O(\FSM_sequential_mode[2]_i_3_n_0 ));
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
  GND GND
       (.G(\<const0> ));
  (* SOFT_HLUTNM = "soft_lutpair58" *) 
  LUT4 #(
    .INIT(16'h00D1)) 
    d_fetch_fault_i_1
       (.I0(im_en_INST_0_i_3_n_0),
        .I1(im_en_INST_0_i_2_n_0),
        .I2(d_fetch_fault),
        .I3(im_en_INST_0_i_1_n_0),
        .O(d_fetch_fault_i_1_n_0));
  FDRE d_fetch_fault_reg
       (.C(clk),
        .CE(1'b1),
        .D(d_fetch_fault_i_1_n_0),
        .Q(d_fetch_fault),
        .R(1'b0));
  LUT2 #(
    .INIT(4'h1)) 
    \d_pc[15]_i_1 
       (.I0(im_en_INST_0_i_2_n_0),
        .I1(im_en_INST_0_i_1_n_0),
        .O(\d_pc[15]_i_1_n_0 ));
  FDRE \d_pc_reg[0] 
       (.C(clk),
        .CE(\d_pc[15]_i_1_n_0 ),
        .D(observe_fetch_pc[0]),
        .Q(d_pc[0]),
        .R(rst));
  FDRE \d_pc_reg[10] 
       (.C(clk),
        .CE(\d_pc[15]_i_1_n_0 ),
        .D(observe_fetch_pc[10]),
        .Q(d_pc[10]),
        .R(rst));
  FDRE \d_pc_reg[11] 
       (.C(clk),
        .CE(\d_pc[15]_i_1_n_0 ),
        .D(observe_fetch_pc[11]),
        .Q(d_pc[11]),
        .R(rst));
  FDRE \d_pc_reg[12] 
       (.C(clk),
        .CE(\d_pc[15]_i_1_n_0 ),
        .D(observe_fetch_pc[12]),
        .Q(d_pc[12]),
        .R(rst));
  FDRE \d_pc_reg[13] 
       (.C(clk),
        .CE(\d_pc[15]_i_1_n_0 ),
        .D(observe_fetch_pc[13]),
        .Q(d_pc[13]),
        .R(rst));
  FDRE \d_pc_reg[14] 
       (.C(clk),
        .CE(\d_pc[15]_i_1_n_0 ),
        .D(observe_fetch_pc[14]),
        .Q(d_pc[14]),
        .R(rst));
  FDRE \d_pc_reg[15] 
       (.C(clk),
        .CE(\d_pc[15]_i_1_n_0 ),
        .D(observe_fetch_pc[15]),
        .Q(d_pc[15]),
        .R(rst));
  FDRE \d_pc_reg[1] 
       (.C(clk),
        .CE(\d_pc[15]_i_1_n_0 ),
        .D(observe_fetch_pc[1]),
        .Q(d_pc[1]),
        .R(rst));
  FDRE \d_pc_reg[2] 
       (.C(clk),
        .CE(\d_pc[15]_i_1_n_0 ),
        .D(observe_fetch_pc[2]),
        .Q(d_pc[2]),
        .R(rst));
  FDRE \d_pc_reg[3] 
       (.C(clk),
        .CE(\d_pc[15]_i_1_n_0 ),
        .D(observe_fetch_pc[3]),
        .Q(d_pc[3]),
        .R(rst));
  FDRE \d_pc_reg[4] 
       (.C(clk),
        .CE(\d_pc[15]_i_1_n_0 ),
        .D(observe_fetch_pc[4]),
        .Q(d_pc[4]),
        .R(rst));
  FDRE \d_pc_reg[5] 
       (.C(clk),
        .CE(\d_pc[15]_i_1_n_0 ),
        .D(observe_fetch_pc[5]),
        .Q(d_pc[5]),
        .R(rst));
  FDRE \d_pc_reg[6] 
       (.C(clk),
        .CE(\d_pc[15]_i_1_n_0 ),
        .D(observe_fetch_pc[6]),
        .Q(d_pc[6]),
        .R(rst));
  FDRE \d_pc_reg[7] 
       (.C(clk),
        .CE(\d_pc[15]_i_1_n_0 ),
        .D(observe_fetch_pc[7]),
        .Q(d_pc[7]),
        .R(rst));
  FDRE \d_pc_reg[8] 
       (.C(clk),
        .CE(\d_pc[15]_i_1_n_0 ),
        .D(observe_fetch_pc[8]),
        .Q(d_pc[8]),
        .R(rst));
  FDRE \d_pc_reg[9] 
       (.C(clk),
        .CE(\d_pc[15]_i_1_n_0 ),
        .D(observe_fetch_pc[9]),
        .Q(d_pc[9]),
        .R(rst));
  LUT1 #(
    .INIT(2'h1)) 
    d_valid_i_1
       (.I0(im_en_INST_0_i_1_n_0),
        .O(d_valid_next6_out));
  FDRE d_valid_reg
       (.C(clk),
        .CE(1'b1),
        .D(d_valid_next6_out),
        .Q(observe_pipeline_valid[3]),
        .R(rst));
  LUT3 #(
    .INIT(8'h0E)) 
    dm_en_INST_0
       (.I0(m_mem_write),
        .I1(m_mem_read),
        .I2(dm_en_INST_0_i_1_n_0),
        .O(dm_en));
  LUT6 #(
    .INIT(64'hFFFFFEAFFFFFFFFF)) 
    dm_en_INST_0_i_1
       (.I0(dm_en_INST_0_i_2_n_0),
        .I1(mode[0]),
        .I2(mode[1]),
        .I3(mode[2]),
        .I4(rst),
        .I5(observe_pipeline_valid[1]),
        .O(dm_en_INST_0_i_1_n_0));
  (* SOFT_HLUTNM = "soft_lutpair59" *) 
  LUT4 #(
    .INIT(16'hFFFE)) 
    dm_en_INST_0_i_2
       (.I0(dm_addr[13]),
        .I1(dm_addr[12]),
        .I2(dm_addr[11]),
        .I3(observe_redirect_INST_0_i_10_n_0),
        .O(dm_en_INST_0_i_2_n_0));
  LUT2 #(
    .INIT(4'h2)) 
    dm_we_INST_0
       (.I0(m_mem_write),
        .I1(dm_en_INST_0_i_1_n_0),
        .O(dm_we));
  (* SOFT_HLUTNM = "soft_lutpair47" *) 
  LUT3 #(
    .INIT(8'h01)) 
    fault_INST_0
       (.I0(mode[2]),
        .I1(mode[0]),
        .I2(mode[1]),
        .O(fault));
  (* SOFT_HLUTNM = "soft_lutpair46" *) 
  LUT3 #(
    .INIT(8'h04)) 
    halted_INST_0
       (.I0(mode[2]),
        .I1(mode[0]),
        .I2(mode[1]),
        .O(halted));
  LUT3 #(
    .INIT(8'h10)) 
    im_en_INST_0
       (.I0(im_en_INST_0_i_1_n_0),
        .I1(im_en_INST_0_i_2_n_0),
        .I2(im_en_INST_0_i_3_n_0),
        .O(im_en));
  LUT6 #(
    .INIT(64'hBFFFBFFFBFFFBFBF)) 
    im_en_INST_0_i_1
       (.I0(observe_redirect_INST_0_i_5_n_0),
        .I1(observe_redirect_INST_0_i_4_n_0),
        .I2(observe_redirect_INST_0_i_3_n_0),
        .I3(observe_redirect_INST_0_i_2_n_0),
        .I4(x_halt),
        .I5(observe_redirect_INST_0_i_1_n_0),
        .O(im_en_INST_0_i_1_n_0));
  LUT6 #(
    .INIT(64'h0000000004000000)) 
    im_en_INST_0_i_2
       (.I0(im_en_INST_0_i_4_n_0),
        .I1(observe_pipeline_valid[2]),
        .I2(x_fault),
        .I3(x_mem_read),
        .I4(observe_pipeline_valid[3]),
        .I5(im_en_INST_0_i_5_n_0),
        .O(im_en_INST_0_i_2_n_0));
  LUT5 #(
    .INIT(32'h00000001)) 
    im_en_INST_0_i_3
       (.I0(observe_fetch_pc[11]),
        .I1(observe_fetch_pc[9]),
        .I2(observe_fetch_pc[12]),
        .I3(observe_fetch_pc[15]),
        .I4(im_en_INST_0_i_6_n_0),
        .O(im_en_INST_0_i_3_n_0));
  LUT6 #(
    .INIT(64'h000000006FFFFF6F)) 
    im_en_INST_0_i_4
       (.I0(im_dout[8]),
        .I1(x_rd[0]),
        .I2(d_use_rs),
        .I3(x_rd[1]),
        .I4(im_dout[9]),
        .I5(im_en_INST_0_i_7_n_0),
        .O(im_en_INST_0_i_4_n_0));
  LUT2 #(
    .INIT(4'hE)) 
    im_en_INST_0_i_5
       (.I0(d_fetch_fault),
        .I1(d_illegal),
        .O(im_en_INST_0_i_5_n_0));
  LUT4 #(
    .INIT(16'hFFFE)) 
    im_en_INST_0_i_6
       (.I0(observe_fetch_pc[8]),
        .I1(observe_fetch_pc[10]),
        .I2(observe_fetch_pc[14]),
        .I3(observe_fetch_pc[13]),
        .O(im_en_INST_0_i_6_n_0));
  LUT5 #(
    .INIT(32'h82000082)) 
    im_en_INST_0_i_7
       (.I0(d_use_rd),
        .I1(im_dout[10]),
        .I2(x_rd[0]),
        .I3(im_dout[11]),
        .I4(x_rd[1]),
        .O(im_en_INST_0_i_7_n_0));
  FDRE \last_completed_pc_reg[0] 
       (.C(clk),
        .CE(last_completed_valid0),
        .D(observe_wb_pc[0]),
        .Q(last_completed_pc[0]),
        .R(rst));
  FDRE \last_completed_pc_reg[10] 
       (.C(clk),
        .CE(last_completed_valid0),
        .D(observe_wb_pc[10]),
        .Q(last_completed_pc[10]),
        .R(rst));
  FDRE \last_completed_pc_reg[11] 
       (.C(clk),
        .CE(last_completed_valid0),
        .D(observe_wb_pc[11]),
        .Q(last_completed_pc[11]),
        .R(rst));
  FDRE \last_completed_pc_reg[12] 
       (.C(clk),
        .CE(last_completed_valid0),
        .D(observe_wb_pc[12]),
        .Q(last_completed_pc[12]),
        .R(rst));
  FDRE \last_completed_pc_reg[13] 
       (.C(clk),
        .CE(last_completed_valid0),
        .D(observe_wb_pc[13]),
        .Q(last_completed_pc[13]),
        .R(rst));
  FDRE \last_completed_pc_reg[14] 
       (.C(clk),
        .CE(last_completed_valid0),
        .D(observe_wb_pc[14]),
        .Q(last_completed_pc[14]),
        .R(rst));
  FDRE \last_completed_pc_reg[15] 
       (.C(clk),
        .CE(last_completed_valid0),
        .D(observe_wb_pc[15]),
        .Q(last_completed_pc[15]),
        .R(rst));
  FDRE \last_completed_pc_reg[1] 
       (.C(clk),
        .CE(last_completed_valid0),
        .D(observe_wb_pc[1]),
        .Q(last_completed_pc[1]),
        .R(rst));
  FDRE \last_completed_pc_reg[2] 
       (.C(clk),
        .CE(last_completed_valid0),
        .D(observe_wb_pc[2]),
        .Q(last_completed_pc[2]),
        .R(rst));
  FDRE \last_completed_pc_reg[3] 
       (.C(clk),
        .CE(last_completed_valid0),
        .D(observe_wb_pc[3]),
        .Q(last_completed_pc[3]),
        .R(rst));
  FDRE \last_completed_pc_reg[4] 
       (.C(clk),
        .CE(last_completed_valid0),
        .D(observe_wb_pc[4]),
        .Q(last_completed_pc[4]),
        .R(rst));
  FDRE \last_completed_pc_reg[5] 
       (.C(clk),
        .CE(last_completed_valid0),
        .D(observe_wb_pc[5]),
        .Q(last_completed_pc[5]),
        .R(rst));
  FDRE \last_completed_pc_reg[6] 
       (.C(clk),
        .CE(last_completed_valid0),
        .D(observe_wb_pc[6]),
        .Q(last_completed_pc[6]),
        .R(rst));
  FDRE \last_completed_pc_reg[7] 
       (.C(clk),
        .CE(last_completed_valid0),
        .D(observe_wb_pc[7]),
        .Q(last_completed_pc[7]),
        .R(rst));
  FDRE \last_completed_pc_reg[8] 
       (.C(clk),
        .CE(last_completed_valid0),
        .D(observe_wb_pc[8]),
        .Q(last_completed_pc[8]),
        .R(rst));
  FDRE \last_completed_pc_reg[9] 
       (.C(clk),
        .CE(last_completed_valid0),
        .D(observe_wb_pc[9]),
        .Q(last_completed_pc[9]),
        .R(rst));
  FDRE last_completed_valid_reg
       (.C(clk),
        .CE(last_completed_valid0),
        .D(1'b1),
        .Q(last_completed_valid),
        .R(rst));
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
  (* SOFT_HLUTNM = "soft_lutpair60" *) 
  LUT4 #(
    .INIT(16'h0002)) 
    m_cv_write_i_1
       (.I0(x_cv_write),
        .I1(m_valid_i_2_n_0),
        .I2(x_fault),
        .I3(m_z_write_i_2_n_0),
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
  (* SOFT_HLUTNM = "soft_lutpair60" *) 
  LUT3 #(
    .INIT(8'h0E)) 
    m_fault_i_1
       (.I0(m_z_write_i_2_n_0),
        .I1(x_fault),
        .I2(m_valid_i_2_n_0),
        .O(m_fault0));
  FDRE m_fault_reg
       (.C(clk),
        .CE(1'b1),
        .D(m_fault0),
        .Q(m_fault),
        .R(rst));
  (* SOFT_HLUTNM = "soft_lutpair61" *) 
  LUT4 #(
    .INIT(16'h0002)) 
    m_halt_i_1
       (.I0(x_halt),
        .I1(m_valid_i_2_n_0),
        .I2(x_fault),
        .I3(m_z_write_i_2_n_0),
        .O(m_halt0));
  FDRE m_halt_reg
       (.C(clk),
        .CE(1'b1),
        .D(m_halt0),
        .Q(m_halt),
        .R(rst));
  (* SOFT_HLUTNM = "soft_lutpair62" *) 
  LUT4 #(
    .INIT(16'h0002)) 
    m_mem_read_i_1
       (.I0(x_mem_read),
        .I1(m_valid_i_2_n_0),
        .I2(x_fault),
        .I3(m_z_write_i_2_n_0),
        .O(m_mem_read0));
  FDRE m_mem_read_reg
       (.C(clk),
        .CE(1'b1),
        .D(m_mem_read0),
        .Q(m_mem_read),
        .R(rst));
  (* SOFT_HLUTNM = "soft_lutpair62" *) 
  LUT4 #(
    .INIT(16'h0002)) 
    m_mem_write_i_1
       (.I0(x_mem_write),
        .I1(m_valid_i_2_n_0),
        .I2(x_fault),
        .I3(m_z_write_i_2_n_0),
        .O(m_mem_write0));
  FDRE m_mem_write_reg
       (.C(clk),
        .CE(1'b1),
        .D(m_mem_write0),
        .Q(m_mem_write),
        .R(rst));
  FDRE \m_pc_reg[0] 
       (.C(clk),
        .CE(1'b1),
        .D(x_pc[0]),
        .Q(m_pc[0]),
        .R(rst));
  FDRE \m_pc_reg[10] 
       (.C(clk),
        .CE(1'b1),
        .D(x_pc[10]),
        .Q(m_pc[10]),
        .R(rst));
  FDRE \m_pc_reg[11] 
       (.C(clk),
        .CE(1'b1),
        .D(x_pc[11]),
        .Q(m_pc[11]),
        .R(rst));
  FDRE \m_pc_reg[12] 
       (.C(clk),
        .CE(1'b1),
        .D(x_pc[12]),
        .Q(m_pc[12]),
        .R(rst));
  FDRE \m_pc_reg[13] 
       (.C(clk),
        .CE(1'b1),
        .D(x_pc[13]),
        .Q(m_pc[13]),
        .R(rst));
  FDRE \m_pc_reg[14] 
       (.C(clk),
        .CE(1'b1),
        .D(x_pc[14]),
        .Q(m_pc[14]),
        .R(rst));
  FDRE \m_pc_reg[15] 
       (.C(clk),
        .CE(1'b1),
        .D(x_pc[15]),
        .Q(m_pc[15]),
        .R(rst));
  FDRE \m_pc_reg[1] 
       (.C(clk),
        .CE(1'b1),
        .D(x_pc[1]),
        .Q(m_pc[1]),
        .R(rst));
  FDRE \m_pc_reg[2] 
       (.C(clk),
        .CE(1'b1),
        .D(x_pc[2]),
        .Q(m_pc[2]),
        .R(rst));
  FDRE \m_pc_reg[3] 
       (.C(clk),
        .CE(1'b1),
        .D(x_pc[3]),
        .Q(m_pc[3]),
        .R(rst));
  FDRE \m_pc_reg[4] 
       (.C(clk),
        .CE(1'b1),
        .D(x_pc[4]),
        .Q(m_pc[4]),
        .R(rst));
  FDRE \m_pc_reg[5] 
       (.C(clk),
        .CE(1'b1),
        .D(x_pc[5]),
        .Q(m_pc[5]),
        .R(rst));
  FDRE \m_pc_reg[6] 
       (.C(clk),
        .CE(1'b1),
        .D(x_pc[6]),
        .Q(m_pc[6]),
        .R(rst));
  FDRE \m_pc_reg[7] 
       (.C(clk),
        .CE(1'b1),
        .D(x_pc[7]),
        .Q(m_pc[7]),
        .R(rst));
  FDRE \m_pc_reg[8] 
       (.C(clk),
        .CE(1'b1),
        .D(x_pc[8]),
        .Q(m_pc[8]),
        .R(rst));
  FDRE \m_pc_reg[9] 
       (.C(clk),
        .CE(1'b1),
        .D(x_pc[9]),
        .Q(m_pc[9]),
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
  (* SOFT_HLUTNM = "soft_lutpair50" *) 
  LUT5 #(
    .INIT(32'h0000FE0E)) 
    \m_reason[0]_i_1 
       (.I0(m_z_write_i_2_n_0),
        .I1(x_halt),
        .I2(x_fault),
        .I3(x_reason),
        .I4(m_valid_i_2_n_0),
        .O(\m_reason[0]_i_1_n_0 ));
  LUT2 #(
    .INIT(4'h2)) 
    \m_reason[1]_i_1 
       (.I0(x_fault),
        .I1(m_valid_i_2_n_0),
        .O(\m_reason[1]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair50" *) 
  LUT3 #(
    .INIT(8'h04)) 
    \m_reason[2]_i_1 
       (.I0(x_fault),
        .I1(m_z_write_i_2_n_0),
        .I2(m_valid_i_2_n_0),
        .O(\m_reason[2]_i_1_n_0 ));
  FDRE \m_reason_reg[0] 
       (.C(clk),
        .CE(1'b1),
        .D(\m_reason[0]_i_1_n_0 ),
        .Q(m_reason[0]),
        .R(1'b0));
  FDRE \m_reason_reg[1] 
       (.C(clk),
        .CE(1'b1),
        .D(\m_reason[1]_i_1_n_0 ),
        .Q(m_reason[1]),
        .R(1'b0));
  FDRE \m_reason_reg[2] 
       (.C(clk),
        .CE(1'b1),
        .D(\m_reason[2]_i_1_n_0 ),
        .Q(m_reason[2]),
        .R(1'b0));
  (* SOFT_HLUTNM = "soft_lutpair61" *) 
  LUT4 #(
    .INIT(16'h0002)) 
    m_reg_write_i_1
       (.I0(x_reg_write),
        .I1(m_valid_i_2_n_0),
        .I2(x_fault),
        .I3(m_z_write_i_2_n_0),
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
  (* SOFT_HLUTNM = "soft_lutpair63" *) 
  LUT1 #(
    .INIT(2'h1)) 
    m_valid_i_1
       (.I0(m_valid_i_2_n_0),
        .O(m_valid_next));
  LUT6 #(
    .INIT(64'hFFFFFD5FFFFFFF5F)) 
    m_valid_i_2
       (.I0(observe_pipeline_valid[2]),
        .I1(mode[0]),
        .I2(mode[1]),
        .I3(mode[2]),
        .I4(rst),
        .I5(observe_redirect_INST_0_i_4_n_0),
        .O(m_valid_i_2_n_0));
  FDRE m_valid_reg
       (.C(clk),
        .CE(1'b1),
        .D(m_valid_next),
        .Q(observe_pipeline_valid[1]),
        .R(rst));
  FDRE m_wb_sel_reg
       (.C(clk),
        .CE(1'b1),
        .D(x_wb_sel),
        .Q(m_wb_sel),
        .R(rst));
  (* SOFT_HLUTNM = "soft_lutpair63" *) 
  LUT4 #(
    .INIT(16'h0002)) 
    m_z_write_i_1
       (.I0(x_z_write),
        .I1(m_valid_i_2_n_0),
        .I2(x_fault),
        .I3(m_z_write_i_2_n_0),
        .O(m_z_write0));
  LUT4 #(
    .INIT(16'hFFFE)) 
    m_z_write_i_2
       (.I0(observe_redirect_INST_0_i_8_n_0),
        .I1(blocked_rs),
        .I2(alu_illegal),
        .I3(blocked_rd),
        .O(m_z_write_i_2_n_0));
  FDRE m_z_write_reg
       (.C(clk),
        .CE(1'b1),
        .D(m_z_write0),
        .Q(m_z_write),
        .R(rst));
  (* SOFT_HLUTNM = "soft_lutpair76" *) 
  LUT2 #(
    .INIT(4'h8)) 
    observe_cv_we_INST_0
       (.I0(w_cv_write),
        .I1(last_completed_valid0),
        .O(observe_cv_we));
  LUT6 #(
    .INIT(64'h0000000002000000)) 
    observe_redirect_INST_0
       (.I0(observe_redirect_INST_0_i_1_n_0),
        .I1(x_halt),
        .I2(observe_redirect_INST_0_i_2_n_0),
        .I3(observe_redirect_INST_0_i_3_n_0),
        .I4(observe_redirect_INST_0_i_4_n_0),
        .I5(observe_redirect_INST_0_i_5_n_0),
        .O(observe_redirect));
  LUT5 #(
    .INIT(32'hEFEAAAAA)) 
    observe_redirect_INST_0_i_1
       (.I0(x_jump_abs),
        .I1(m_cmp_z),
        .I2(observe_redirect_INST_0_i_6_n_0),
        .I3(observe_redirect_INST_0_i_7_n_0),
        .I4(x_jump_z),
        .O(observe_redirect_INST_0_i_1_n_0));
  LUT6 #(
    .INIT(64'hFFFFFFFFFFFFFFFE)) 
    observe_redirect_INST_0_i_10
       (.I0(dm_addr[15]),
        .I1(dm_addr[9]),
        .I2(m_fault),
        .I3(dm_addr[14]),
        .I4(dm_addr[10]),
        .I5(dm_addr[8]),
        .O(observe_redirect_INST_0_i_10_n_0));
  LUT6 #(
    .INIT(64'hFFFFFFFFFFFFFFFD)) 
    observe_redirect_INST_0_i_2
       (.I0(observe_pipeline_valid[2]),
        .I1(x_fault),
        .I2(blocked_rd),
        .I3(alu_illegal),
        .I4(blocked_rs),
        .I5(observe_redirect_INST_0_i_8_n_0),
        .O(observe_redirect_INST_0_i_2_n_0));
  (* SOFT_HLUTNM = "soft_lutpair51" *) 
  LUT4 #(
    .INIT(16'h0004)) 
    observe_redirect_INST_0_i_3
       (.I0(rst),
        .I1(mode[2]),
        .I2(mode[1]),
        .I3(mode[0]),
        .O(observe_redirect_INST_0_i_3_n_0));
  LUT6 #(
    .INIT(64'hDDDDDDDDDDDDDDDF)) 
    observe_redirect_INST_0_i_4
       (.I0(observe_pipeline_valid[1]),
        .I1(observe_redirect_INST_0_i_9_n_0),
        .I2(observe_redirect_INST_0_i_10_n_0),
        .I3(dm_addr[11]),
        .I4(dm_addr[12]),
        .I5(dm_addr[13]),
        .O(observe_redirect_INST_0_i_4_n_0));
  LUT6 #(
    .INIT(64'hFFFFFFFE00000000)) 
    observe_redirect_INST_0_i_5
       (.I0(observe_redirect_INST_0_i_8_n_0),
        .I1(blocked_rs),
        .I2(alu_illegal),
        .I3(blocked_rd),
        .I4(x_fault),
        .I5(observe_pipeline_valid[2]),
        .O(observe_redirect_INST_0_i_5_n_0));
  LUT3 #(
    .INIT(8'h08)) 
    observe_redirect_INST_0_i_6
       (.I0(m_z_write),
        .I1(observe_pipeline_valid[1]),
        .I2(m_fault),
        .O(observe_redirect_INST_0_i_6_n_0));
  LUT5 #(
    .INIT(32'hAEAAA2AA)) 
    observe_redirect_INST_0_i_7
       (.I0(Z),
        .I1(w_z_write),
        .I2(w_fault),
        .I3(observe_pipeline_valid[0]),
        .I4(observe_wb_flags[2]),
        .O(observe_redirect_INST_0_i_7_n_0));
  LUT4 #(
    .INIT(16'hF888)) 
    observe_redirect_INST_0_i_8
       (.I0(x_alu_b_sel[0]),
        .I1(x_alu_b_sel[1]),
        .I2(x_alu_a_sel[0]),
        .I3(x_alu_a_sel[1]),
        .O(observe_redirect_INST_0_i_8_n_0));
  LUT2 #(
    .INIT(4'h1)) 
    observe_redirect_INST_0_i_9
       (.I0(m_mem_read),
        .I1(m_mem_write),
        .O(observe_redirect_INST_0_i_9_n_0));
  (* SOFT_HLUTNM = "soft_lutpair76" *) 
  LUT2 #(
    .INIT(4'h8)) 
    observe_rf_we_INST_0
       (.I0(w_reg_write),
        .I1(last_completed_valid0),
        .O(observe_rf_we));
  LUT6 #(
    .INIT(64'h0004000000040400)) 
    observe_rf_we_INST_0_i_1
       (.I0(w_fault),
        .I1(observe_pipeline_valid[0]),
        .I2(rst),
        .I3(mode[2]),
        .I4(mode[1]),
        .I5(mode[0]),
        .O(last_completed_valid0));
  (* SOFT_HLUTNM = "soft_lutpair75" *) 
  LUT2 #(
    .INIT(4'h2)) 
    observe_stall_INST_0
       (.I0(im_en_INST_0_i_2_n_0),
        .I1(im_en_INST_0_i_1_n_0),
        .O(observe_stall));
  (* SOFT_HLUTNM = "soft_lutpair67" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \observe_wb_data[0]_INST_0 
       (.I0(dm_dout[0]),
        .I1(w_exec_value[0]),
        .I2(w_wb_sel),
        .O(observe_wb_data[0]));
  (* SOFT_HLUTNM = "soft_lutpair72" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \observe_wb_data[10]_INST_0 
       (.I0(dm_dout[10]),
        .I1(w_exec_value[10]),
        .I2(w_wb_sel),
        .O(observe_wb_data[10]));
  (* SOFT_HLUTNM = "soft_lutpair72" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \observe_wb_data[11]_INST_0 
       (.I0(dm_dout[11]),
        .I1(w_exec_value[11]),
        .I2(w_wb_sel),
        .O(observe_wb_data[11]));
  (* SOFT_HLUTNM = "soft_lutpair73" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \observe_wb_data[12]_INST_0 
       (.I0(dm_dout[12]),
        .I1(w_exec_value[12]),
        .I2(w_wb_sel),
        .O(observe_wb_data[12]));
  (* SOFT_HLUTNM = "soft_lutpair73" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \observe_wb_data[13]_INST_0 
       (.I0(dm_dout[13]),
        .I1(w_exec_value[13]),
        .I2(w_wb_sel),
        .O(observe_wb_data[13]));
  (* SOFT_HLUTNM = "soft_lutpair74" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \observe_wb_data[14]_INST_0 
       (.I0(dm_dout[14]),
        .I1(w_exec_value[14]),
        .I2(w_wb_sel),
        .O(observe_wb_data[14]));
  (* SOFT_HLUTNM = "soft_lutpair74" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \observe_wb_data[15]_INST_0 
       (.I0(dm_dout[15]),
        .I1(w_exec_value[15]),
        .I2(w_wb_sel),
        .O(observe_wb_data[15]));
  (* SOFT_HLUTNM = "soft_lutpair67" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \observe_wb_data[1]_INST_0 
       (.I0(dm_dout[1]),
        .I1(w_exec_value[1]),
        .I2(w_wb_sel),
        .O(observe_wb_data[1]));
  (* SOFT_HLUTNM = "soft_lutpair69" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \observe_wb_data[2]_INST_0 
       (.I0(dm_dout[2]),
        .I1(w_exec_value[2]),
        .I2(w_wb_sel),
        .O(observe_wb_data[2]));
  (* SOFT_HLUTNM = "soft_lutpair69" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \observe_wb_data[3]_INST_0 
       (.I0(dm_dout[3]),
        .I1(w_exec_value[3]),
        .I2(w_wb_sel),
        .O(observe_wb_data[3]));
  (* SOFT_HLUTNM = "soft_lutpair68" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \observe_wb_data[4]_INST_0 
       (.I0(dm_dout[4]),
        .I1(w_exec_value[4]),
        .I2(w_wb_sel),
        .O(observe_wb_data[4]));
  (* SOFT_HLUTNM = "soft_lutpair68" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \observe_wb_data[5]_INST_0 
       (.I0(dm_dout[5]),
        .I1(w_exec_value[5]),
        .I2(w_wb_sel),
        .O(observe_wb_data[5]));
  (* SOFT_HLUTNM = "soft_lutpair71" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \observe_wb_data[6]_INST_0 
       (.I0(dm_dout[6]),
        .I1(w_exec_value[6]),
        .I2(w_wb_sel),
        .O(observe_wb_data[6]));
  (* SOFT_HLUTNM = "soft_lutpair71" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \observe_wb_data[7]_INST_0 
       (.I0(dm_dout[7]),
        .I1(w_exec_value[7]),
        .I2(w_wb_sel),
        .O(observe_wb_data[7]));
  (* SOFT_HLUTNM = "soft_lutpair70" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \observe_wb_data[8]_INST_0 
       (.I0(dm_dout[8]),
        .I1(w_exec_value[8]),
        .I2(w_wb_sel),
        .O(observe_wb_data[8]));
  (* SOFT_HLUTNM = "soft_lutpair70" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \observe_wb_data[9]_INST_0 
       (.I0(dm_dout[9]),
        .I1(w_exec_value[9]),
        .I2(w_wb_sel),
        .O(observe_wb_data[9]));
  LUT6 #(
    .INIT(64'h000002A000000000)) 
    observe_wb_fault_INST_0
       (.I0(w_fault),
        .I1(mode[0]),
        .I2(mode[1]),
        .I3(mode[2]),
        .I4(rst),
        .I5(observe_pipeline_valid[0]),
        .O(observe_wb_fault));
  LUT6 #(
    .INIT(64'h000002A000000000)) 
    observe_wb_halt_INST_0
       (.I0(w_halt),
        .I1(mode[0]),
        .I2(mode[1]),
        .I3(mode[2]),
        .I4(rst),
        .I5(observe_pipeline_valid[0]),
        .O(observe_wb_halt));
  LUT6 #(
    .INIT(64'h000002A000000000)) 
    observe_wb_store_INST_0
       (.I0(w_store),
        .I1(mode[0]),
        .I2(mode[1]),
        .I3(mode[2]),
        .I4(rst),
        .I5(observe_pipeline_valid[0]),
        .O(observe_wb_store));
  (* SOFT_HLUTNM = "soft_lutpair52" *) 
  LUT5 #(
    .INIT(32'h02000220)) 
    observe_wb_valid_INST_0
       (.I0(observe_pipeline_valid[0]),
        .I1(rst),
        .I2(mode[2]),
        .I3(mode[1]),
        .I4(mode[0]),
        .O(observe_wb_valid));
  LUT4 #(
    .INIT(16'h0020)) 
    observe_z_we_INST_0
       (.I0(observe_pipeline_valid[0]),
        .I1(w_fault),
        .I2(w_z_write),
        .I3(observe_z_we_INST_0_i_1_n_0),
        .O(observe_z_we));
  (* SOFT_HLUTNM = "soft_lutpair52" *) 
  LUT4 #(
    .INIT(16'hFFE3)) 
    observe_z_we_INST_0_i_1
       (.I0(mode[0]),
        .I1(mode[1]),
        .I2(mode[2]),
        .I3(rst),
        .O(observe_z_we_INST_0_i_1_n_0));
  FDRE \stop_pc_reg[0] 
       (.C(clk),
        .CE(stop_valid141_out),
        .D(observe_wb_pc[0]),
        .Q(stop_pc[0]),
        .R(rst));
  FDRE \stop_pc_reg[10] 
       (.C(clk),
        .CE(stop_valid141_out),
        .D(observe_wb_pc[10]),
        .Q(stop_pc[10]),
        .R(rst));
  FDRE \stop_pc_reg[11] 
       (.C(clk),
        .CE(stop_valid141_out),
        .D(observe_wb_pc[11]),
        .Q(stop_pc[11]),
        .R(rst));
  FDRE \stop_pc_reg[12] 
       (.C(clk),
        .CE(stop_valid141_out),
        .D(observe_wb_pc[12]),
        .Q(stop_pc[12]),
        .R(rst));
  FDRE \stop_pc_reg[13] 
       (.C(clk),
        .CE(stop_valid141_out),
        .D(observe_wb_pc[13]),
        .Q(stop_pc[13]),
        .R(rst));
  FDRE \stop_pc_reg[14] 
       (.C(clk),
        .CE(stop_valid141_out),
        .D(observe_wb_pc[14]),
        .Q(stop_pc[14]),
        .R(rst));
  FDRE \stop_pc_reg[15] 
       (.C(clk),
        .CE(stop_valid141_out),
        .D(observe_wb_pc[15]),
        .Q(stop_pc[15]),
        .R(rst));
  FDRE \stop_pc_reg[1] 
       (.C(clk),
        .CE(stop_valid141_out),
        .D(observe_wb_pc[1]),
        .Q(stop_pc[1]),
        .R(rst));
  FDRE \stop_pc_reg[2] 
       (.C(clk),
        .CE(stop_valid141_out),
        .D(observe_wb_pc[2]),
        .Q(stop_pc[2]),
        .R(rst));
  FDRE \stop_pc_reg[3] 
       (.C(clk),
        .CE(stop_valid141_out),
        .D(observe_wb_pc[3]),
        .Q(stop_pc[3]),
        .R(rst));
  FDRE \stop_pc_reg[4] 
       (.C(clk),
        .CE(stop_valid141_out),
        .D(observe_wb_pc[4]),
        .Q(stop_pc[4]),
        .R(rst));
  FDRE \stop_pc_reg[5] 
       (.C(clk),
        .CE(stop_valid141_out),
        .D(observe_wb_pc[5]),
        .Q(stop_pc[5]),
        .R(rst));
  FDRE \stop_pc_reg[6] 
       (.C(clk),
        .CE(stop_valid141_out),
        .D(observe_wb_pc[6]),
        .Q(stop_pc[6]),
        .R(rst));
  FDRE \stop_pc_reg[7] 
       (.C(clk),
        .CE(stop_valid141_out),
        .D(observe_wb_pc[7]),
        .Q(stop_pc[7]),
        .R(rst));
  FDRE \stop_pc_reg[8] 
       (.C(clk),
        .CE(stop_valid141_out),
        .D(observe_wb_pc[8]),
        .Q(stop_pc[8]),
        .R(rst));
  FDRE \stop_pc_reg[9] 
       (.C(clk),
        .CE(stop_valid141_out),
        .D(observe_wb_pc[9]),
        .Q(stop_pc[9]),
        .R(rst));
  LUT6 #(
    .INIT(64'h0F0D0F0F000D0000)) 
    \stop_reason[0]_i_1 
       (.I0(w_fault),
        .I1(w_reason[0]),
        .I2(rst),
        .I3(stop_valid),
        .I4(stop_valid_i_2_n_0),
        .I5(stop_reason[0]),
        .O(\stop_reason[0]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0F080F0F00080000)) 
    \stop_reason[1]_i_1 
       (.I0(w_fault),
        .I1(w_reason[1]),
        .I2(rst),
        .I3(stop_valid),
        .I4(stop_valid_i_2_n_0),
        .I5(stop_reason[1]),
        .O(\stop_reason[1]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0F080F0F00080000)) 
    \stop_reason[2]_i_1 
       (.I0(w_fault),
        .I1(w_reason[2]),
        .I2(rst),
        .I3(stop_valid),
        .I4(stop_valid_i_2_n_0),
        .I5(stop_reason[2]),
        .O(\stop_reason[2]_i_1_n_0 ));
  FDRE \stop_reason_reg[0] 
       (.C(clk),
        .CE(1'b1),
        .D(\stop_reason[0]_i_1_n_0 ),
        .Q(stop_reason[0]),
        .R(1'b0));
  FDRE \stop_reason_reg[1] 
       (.C(clk),
        .CE(1'b1),
        .D(\stop_reason[1]_i_1_n_0 ),
        .Q(stop_reason[1]),
        .R(1'b0));
  FDRE \stop_reason_reg[2] 
       (.C(clk),
        .CE(1'b1),
        .D(\stop_reason[2]_i_1_n_0 ),
        .Q(stop_reason[2]),
        .R(1'b0));
  LUT2 #(
    .INIT(4'h2)) 
    stop_valid_i_1
       (.I0(stop_valid_i_2_n_0),
        .I1(stop_valid),
        .O(stop_valid141_out));
  LUT6 #(
    .INIT(64'h000000000000A800)) 
    stop_valid_i_2
       (.I0(stop_valid_i_3_n_0),
        .I1(w_halt),
        .I2(w_fault),
        .I3(observe_pipeline_valid[0]),
        .I4(observe_pipeline_valid[1]),
        .I5(stop_valid_i_4_n_0),
        .O(stop_valid_i_2_n_0));
  LUT6 #(
    .INIT(64'h22200000FFFFFFFF)) 
    stop_valid_i_3
       (.I0(observe_pipeline_valid[1]),
        .I1(observe_redirect_INST_0_i_9_n_0),
        .I2(observe_redirect_INST_0_i_10_n_0),
        .I3(stop_valid_i_5_n_0),
        .I4(observe_redirect_INST_0_i_3_n_0),
        .I5(observe_pipeline_valid[2]),
        .O(stop_valid_i_3_n_0));
  LUT3 #(
    .INIT(8'hFB)) 
    stop_valid_i_4
       (.I0(rst),
        .I1(mode[1]),
        .I2(mode[2]),
        .O(stop_valid_i_4_n_0));
  (* SOFT_HLUTNM = "soft_lutpair59" *) 
  LUT3 #(
    .INIT(8'hFE)) 
    stop_valid_i_5
       (.I0(dm_addr[11]),
        .I1(dm_addr[12]),
        .I2(dm_addr[13]),
        .O(stop_valid_i_5_n_0));
  FDRE stop_valid_reg
       (.C(clk),
        .CE(stop_valid141_out),
        .D(1'b1),
        .Q(stop_valid),
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
    .INIT(16'h3808)) 
    u_alu_i_1
       (.I0(x_store_data[15]),
        .I1(x_alu_a_sel[0]),
        .I2(x_alu_a_sel[1]),
        .I3(rs_fwd[15]),
        .O(alu_a[15]));
  LUT4 #(
    .INIT(16'h3808)) 
    u_alu_i_10
       (.I0(x_store_data[6]),
        .I1(x_alu_a_sel[0]),
        .I2(x_alu_a_sel[1]),
        .I3(rs_fwd[6]),
        .O(alu_a[6]));
  LUT4 #(
    .INIT(16'h3808)) 
    u_alu_i_11
       (.I0(x_store_data[5]),
        .I1(x_alu_a_sel[0]),
        .I2(x_alu_a_sel[1]),
        .I3(rs_fwd[5]),
        .O(alu_a[5]));
  LUT4 #(
    .INIT(16'h3808)) 
    u_alu_i_12
       (.I0(x_store_data[4]),
        .I1(x_alu_a_sel[0]),
        .I2(x_alu_a_sel[1]),
        .I3(rs_fwd[4]),
        .O(alu_a[4]));
  LUT4 #(
    .INIT(16'h3808)) 
    u_alu_i_13
       (.I0(x_store_data[3]),
        .I1(x_alu_a_sel[0]),
        .I2(x_alu_a_sel[1]),
        .I3(rs_fwd[3]),
        .O(alu_a[3]));
  LUT4 #(
    .INIT(16'h3808)) 
    u_alu_i_14
       (.I0(x_store_data[2]),
        .I1(x_alu_a_sel[0]),
        .I2(x_alu_a_sel[1]),
        .I3(rs_fwd[2]),
        .O(alu_a[2]));
  LUT4 #(
    .INIT(16'h3808)) 
    u_alu_i_15
       (.I0(x_store_data[1]),
        .I1(x_alu_a_sel[0]),
        .I2(x_alu_a_sel[1]),
        .I3(rs_fwd[1]),
        .O(alu_a[1]));
  LUT4 #(
    .INIT(16'h3808)) 
    u_alu_i_16
       (.I0(x_store_data[0]),
        .I1(x_alu_a_sel[0]),
        .I2(x_alu_a_sel[1]),
        .I3(rs_fwd[0]),
        .O(alu_a[0]));
  (* SOFT_HLUTNM = "soft_lutpair57" *) 
  LUT4 #(
    .INIT(16'h3808)) 
    u_alu_i_17
       (.I0(x_imm_ext__0),
        .I1(x_alu_b_sel[1]),
        .I2(x_alu_b_sel[0]),
        .I3(rs_fwd[15]),
        .O(alu_b[15]));
  (* SOFT_HLUTNM = "soft_lutpair57" *) 
  LUT4 #(
    .INIT(16'h3808)) 
    u_alu_i_18
       (.I0(x_imm_ext__0),
        .I1(x_alu_b_sel[1]),
        .I2(x_alu_b_sel[0]),
        .I3(rs_fwd[14]),
        .O(alu_b[14]));
  (* SOFT_HLUTNM = "soft_lutpair56" *) 
  LUT4 #(
    .INIT(16'h3808)) 
    u_alu_i_19
       (.I0(x_imm_ext__0),
        .I1(x_alu_b_sel[1]),
        .I2(x_alu_b_sel[0]),
        .I3(rs_fwd[13]),
        .O(alu_b[13]));
  LUT4 #(
    .INIT(16'h3808)) 
    u_alu_i_2
       (.I0(x_store_data[14]),
        .I1(x_alu_a_sel[0]),
        .I2(x_alu_a_sel[1]),
        .I3(rs_fwd[14]),
        .O(alu_a[14]));
  (* SOFT_HLUTNM = "soft_lutpair56" *) 
  LUT4 #(
    .INIT(16'h3808)) 
    u_alu_i_20
       (.I0(x_imm_ext__0),
        .I1(x_alu_b_sel[1]),
        .I2(x_alu_b_sel[0]),
        .I3(rs_fwd[12]),
        .O(alu_b[12]));
  (* SOFT_HLUTNM = "soft_lutpair55" *) 
  LUT4 #(
    .INIT(16'h3808)) 
    u_alu_i_21
       (.I0(x_imm_ext__0),
        .I1(x_alu_b_sel[1]),
        .I2(x_alu_b_sel[0]),
        .I3(rs_fwd[11]),
        .O(alu_b[11]));
  (* SOFT_HLUTNM = "soft_lutpair55" *) 
  LUT4 #(
    .INIT(16'h3808)) 
    u_alu_i_22
       (.I0(x_imm_ext__0),
        .I1(x_alu_b_sel[1]),
        .I2(x_alu_b_sel[0]),
        .I3(rs_fwd[10]),
        .O(alu_b[10]));
  (* SOFT_HLUTNM = "soft_lutpair54" *) 
  LUT4 #(
    .INIT(16'h3808)) 
    u_alu_i_23
       (.I0(x_imm_ext__0),
        .I1(x_alu_b_sel[1]),
        .I2(x_alu_b_sel[0]),
        .I3(rs_fwd[9]),
        .O(alu_b[9]));
  (* SOFT_HLUTNM = "soft_lutpair54" *) 
  LUT4 #(
    .INIT(16'h3808)) 
    u_alu_i_24
       (.I0(x_imm_ext__0),
        .I1(x_alu_b_sel[1]),
        .I2(x_alu_b_sel[0]),
        .I3(rs_fwd[8]),
        .O(alu_b[8]));
  (* SOFT_HLUTNM = "soft_lutpair53" *) 
  LUT4 #(
    .INIT(16'h3808)) 
    u_alu_i_25
       (.I0(x_imm_ext[7]),
        .I1(x_alu_b_sel[1]),
        .I2(x_alu_b_sel[0]),
        .I3(rs_fwd[7]),
        .O(alu_b[7]));
  LUT4 #(
    .INIT(16'h3808)) 
    u_alu_i_26
       (.I0(x_imm_ext[7]),
        .I1(x_alu_b_sel[1]),
        .I2(x_alu_b_sel[0]),
        .I3(rs_fwd[6]),
        .O(alu_b[6]));
  LUT4 #(
    .INIT(16'h3808)) 
    u_alu_i_27
       (.I0(x_imm_ext[5]),
        .I1(x_alu_b_sel[1]),
        .I2(x_alu_b_sel[0]),
        .I3(rs_fwd[5]),
        .O(alu_b[5]));
  LUT4 #(
    .INIT(16'h3808)) 
    u_alu_i_28
       (.I0(x_imm_ext[4]),
        .I1(x_alu_b_sel[1]),
        .I2(x_alu_b_sel[0]),
        .I3(rs_fwd[4]),
        .O(alu_b[4]));
  (* SOFT_HLUTNM = "soft_lutpair53" *) 
  LUT4 #(
    .INIT(16'h3808)) 
    u_alu_i_29
       (.I0(x_imm_ext[7]),
        .I1(x_alu_b_sel[1]),
        .I2(x_alu_b_sel[0]),
        .I3(rs_fwd[3]),
        .O(alu_b[3]));
  LUT4 #(
    .INIT(16'h3808)) 
    u_alu_i_3
       (.I0(x_store_data[13]),
        .I1(x_alu_a_sel[0]),
        .I2(x_alu_a_sel[1]),
        .I3(rs_fwd[13]),
        .O(alu_a[13]));
  LUT4 #(
    .INIT(16'h3808)) 
    u_alu_i_30
       (.I0(x_imm_ext[2]),
        .I1(x_alu_b_sel[1]),
        .I2(x_alu_b_sel[0]),
        .I3(rs_fwd[2]),
        .O(alu_b[2]));
  LUT4 #(
    .INIT(16'h3808)) 
    u_alu_i_31
       (.I0(x_imm_ext[1]),
        .I1(x_alu_b_sel[1]),
        .I2(x_alu_b_sel[0]),
        .I3(rs_fwd[1]),
        .O(alu_b[1]));
  LUT4 #(
    .INIT(16'h3808)) 
    u_alu_i_32
       (.I0(x_imm_ext[0]),
        .I1(x_alu_b_sel[1]),
        .I2(x_alu_b_sel[0]),
        .I3(rs_fwd[0]),
        .O(alu_b[0]));
  LUT4 #(
    .INIT(16'h3808)) 
    u_alu_i_4
       (.I0(x_store_data[12]),
        .I1(x_alu_a_sel[0]),
        .I2(x_alu_a_sel[1]),
        .I3(rs_fwd[12]),
        .O(alu_a[12]));
  LUT4 #(
    .INIT(16'h3808)) 
    u_alu_i_5
       (.I0(x_store_data[11]),
        .I1(x_alu_a_sel[0]),
        .I2(x_alu_a_sel[1]),
        .I3(rs_fwd[11]),
        .O(alu_a[11]));
  LUT4 #(
    .INIT(16'h3808)) 
    u_alu_i_6
       (.I0(x_store_data[10]),
        .I1(x_alu_a_sel[0]),
        .I2(x_alu_a_sel[1]),
        .I3(rs_fwd[10]),
        .O(alu_a[10]));
  LUT4 #(
    .INIT(16'h3808)) 
    u_alu_i_7
       (.I0(x_store_data[9]),
        .I1(x_alu_a_sel[0]),
        .I2(x_alu_a_sel[1]),
        .I3(rs_fwd[9]),
        .O(alu_a[9]));
  LUT4 #(
    .INIT(16'h3808)) 
    u_alu_i_8
       (.I0(x_store_data[8]),
        .I1(x_alu_a_sel[0]),
        .I2(x_alu_a_sel[1]),
        .I3(rs_fwd[8]),
        .O(alu_a[8]));
  LUT4 #(
    .INIT(16'h3808)) 
    u_alu_i_9
       (.I0(x_store_data[7]),
        .I1(x_alu_a_sel[0]),
        .I2(x_alu_a_sel[1]),
        .I3(rs_fwd[7]),
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
        .c_in(observe_wb_flags[1]),
        .clk(clk),
        .cv_we(observe_cv_we),
        .rst(rst),
        .v_in(observe_wb_flags[0]),
        .z_in(observe_wb_flags[2]),
        .z_we(observe_z_we));
  operand_forward u_forward
       (.blocked_rd(blocked_rd),
        .blocked_rs(blocked_rs),
        .m_fault(m_fault),
        .m_mem_read(m_mem_read),
        .m_rd(m_rd),
        .m_reg_write(m_reg_write),
        .m_valid(observe_pipeline_valid[1]),
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
        .w_rd(observe_wb_rd),
        .w_reg_write(w_reg_write),
        .w_valid(observe_pipeline_valid[0]),
        .w_value(observe_wb_data));
  pc16 u_pc
       (.clk(clk),
        .hold(pc_hold),
        .pc(observe_fetch_pc),
        .redirect(observe_redirect),
        .rst(rst),
        .target(branch_target));
  (* SOFT_HLUTNM = "soft_lutpair58" *) 
  LUT2 #(
    .INIT(4'hE)) 
    u_pc_i_1
       (.I0(im_en_INST_0_i_1_n_0),
        .I1(im_en_INST_0_i_2_n_0),
        .O(pc_hold));
  regfile4x16 u_rf
       (.clk(clk),
        .raddr_a(im_dout[11:10]),
        .raddr_b(im_dout[9:8]),
        .rdata_a(d_rd_value),
        .rdata_b(d_rs_value),
        .rst(rst),
        .waddr(observe_wb_rd),
        .wdata(observe_wb_data),
        .we(observe_rf_we));
  branch_target16 u_target
       (.branch_pc(x_pc),
        .imm({x_imm_ext[7],1'b0,x_imm_ext[5:4],1'b0,x_imm_ext[2:0]}),
        .relative(x_jump_z),
        .target(branch_target));
  FDRE w_c_reg
       (.C(clk),
        .CE(1'b1),
        .D(m_c),
        .Q(observe_wb_flags[1]),
        .R(rst));
  FDRE w_cmp_z_reg
       (.C(clk),
        .CE(1'b1),
        .D(m_cmp_z),
        .Q(observe_wb_flags[2]),
        .R(rst));
  LUT4 #(
    .INIT(16'h2000)) 
    w_cv_write_i_1
       (.I0(w_valid_next),
        .I1(m_fault),
        .I2(observe_redirect_INST_0_i_4_n_0),
        .I3(m_cv_write),
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
  LUT6 #(
    .INIT(64'h000DDD0000000000)) 
    w_fault_i_1
       (.I0(observe_redirect_INST_0_i_4_n_0),
        .I1(m_fault),
        .I2(mode[0]),
        .I3(mode[1]),
        .I4(mode[2]),
        .I5(observe_pipeline_valid[1]),
        .O(w_fault0));
  FDRE w_fault_reg
       (.C(clk),
        .CE(1'b1),
        .D(w_fault0),
        .Q(w_fault),
        .R(rst));
  (* SOFT_HLUTNM = "soft_lutpair65" *) 
  LUT4 #(
    .INIT(16'h2000)) 
    w_halt_i_1
       (.I0(w_valid_next),
        .I1(m_fault),
        .I2(observe_redirect_INST_0_i_4_n_0),
        .I3(m_halt),
        .O(w_halt0));
  FDRE w_halt_reg
       (.C(clk),
        .CE(1'b1),
        .D(w_halt0),
        .Q(w_halt),
        .R(rst));
  FDRE \w_pc_reg[0] 
       (.C(clk),
        .CE(1'b1),
        .D(m_pc[0]),
        .Q(observe_wb_pc[0]),
        .R(rst));
  FDRE \w_pc_reg[10] 
       (.C(clk),
        .CE(1'b1),
        .D(m_pc[10]),
        .Q(observe_wb_pc[10]),
        .R(rst));
  FDRE \w_pc_reg[11] 
       (.C(clk),
        .CE(1'b1),
        .D(m_pc[11]),
        .Q(observe_wb_pc[11]),
        .R(rst));
  FDRE \w_pc_reg[12] 
       (.C(clk),
        .CE(1'b1),
        .D(m_pc[12]),
        .Q(observe_wb_pc[12]),
        .R(rst));
  FDRE \w_pc_reg[13] 
       (.C(clk),
        .CE(1'b1),
        .D(m_pc[13]),
        .Q(observe_wb_pc[13]),
        .R(rst));
  FDRE \w_pc_reg[14] 
       (.C(clk),
        .CE(1'b1),
        .D(m_pc[14]),
        .Q(observe_wb_pc[14]),
        .R(rst));
  FDRE \w_pc_reg[15] 
       (.C(clk),
        .CE(1'b1),
        .D(m_pc[15]),
        .Q(observe_wb_pc[15]),
        .R(rst));
  FDRE \w_pc_reg[1] 
       (.C(clk),
        .CE(1'b1),
        .D(m_pc[1]),
        .Q(observe_wb_pc[1]),
        .R(rst));
  FDRE \w_pc_reg[2] 
       (.C(clk),
        .CE(1'b1),
        .D(m_pc[2]),
        .Q(observe_wb_pc[2]),
        .R(rst));
  FDRE \w_pc_reg[3] 
       (.C(clk),
        .CE(1'b1),
        .D(m_pc[3]),
        .Q(observe_wb_pc[3]),
        .R(rst));
  FDRE \w_pc_reg[4] 
       (.C(clk),
        .CE(1'b1),
        .D(m_pc[4]),
        .Q(observe_wb_pc[4]),
        .R(rst));
  FDRE \w_pc_reg[5] 
       (.C(clk),
        .CE(1'b1),
        .D(m_pc[5]),
        .Q(observe_wb_pc[5]),
        .R(rst));
  FDRE \w_pc_reg[6] 
       (.C(clk),
        .CE(1'b1),
        .D(m_pc[6]),
        .Q(observe_wb_pc[6]),
        .R(rst));
  FDRE \w_pc_reg[7] 
       (.C(clk),
        .CE(1'b1),
        .D(m_pc[7]),
        .Q(observe_wb_pc[7]),
        .R(rst));
  FDRE \w_pc_reg[8] 
       (.C(clk),
        .CE(1'b1),
        .D(m_pc[8]),
        .Q(observe_wb_pc[8]),
        .R(rst));
  FDRE \w_pc_reg[9] 
       (.C(clk),
        .CE(1'b1),
        .D(m_pc[9]),
        .Q(observe_wb_pc[9]),
        .R(rst));
  FDRE \w_rd_reg[0] 
       (.C(clk),
        .CE(1'b1),
        .D(m_rd[0]),
        .Q(observe_wb_rd[0]),
        .R(rst));
  FDRE \w_rd_reg[1] 
       (.C(clk),
        .CE(1'b1),
        .D(m_rd[1]),
        .Q(observe_wb_rd[1]),
        .R(rst));
  LUT5 #(
    .INIT(32'hA8882000)) 
    \w_reason[0]_i_1 
       (.I0(w_valid_next),
        .I1(m_fault),
        .I2(observe_redirect_INST_0_i_4_n_0),
        .I3(m_halt),
        .I4(m_reason[0]),
        .O(\w_reason[0]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair64" *) 
  LUT3 #(
    .INIT(8'h80)) 
    \w_reason[1]_i_1 
       (.I0(m_reason[1]),
        .I1(w_valid_next),
        .I2(m_fault),
        .O(\w_reason[1]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair64" *) 
  LUT4 #(
    .INIT(16'hC044)) 
    \w_reason[2]_i_1 
       (.I0(observe_redirect_INST_0_i_4_n_0),
        .I1(w_valid_next),
        .I2(m_reason[2]),
        .I3(m_fault),
        .O(\w_reason[2]_i_1_n_0 ));
  FDRE \w_reason_reg[0] 
       (.C(clk),
        .CE(1'b1),
        .D(\w_reason[0]_i_1_n_0 ),
        .Q(w_reason[0]),
        .R(1'b0));
  FDRE \w_reason_reg[1] 
       (.C(clk),
        .CE(1'b1),
        .D(\w_reason[1]_i_1_n_0 ),
        .Q(w_reason[1]),
        .R(1'b0));
  FDRE \w_reason_reg[2] 
       (.C(clk),
        .CE(1'b1),
        .D(\w_reason[2]_i_1_n_0 ),
        .Q(w_reason[2]),
        .R(1'b0));
  (* SOFT_HLUTNM = "soft_lutpair66" *) 
  LUT4 #(
    .INIT(16'h2000)) 
    w_reg_write_i_1
       (.I0(w_valid_next),
        .I1(m_fault),
        .I2(observe_redirect_INST_0_i_4_n_0),
        .I3(m_reg_write),
        .O(w_reg_write0));
  FDRE w_reg_write_reg
       (.C(clk),
        .CE(1'b1),
        .D(w_reg_write0),
        .Q(w_reg_write),
        .R(rst));
  (* SOFT_HLUTNM = "soft_lutpair66" *) 
  LUT4 #(
    .INIT(16'h2000)) 
    w_store_i_1
       (.I0(w_valid_next),
        .I1(m_fault),
        .I2(observe_redirect_INST_0_i_4_n_0),
        .I3(m_mem_write),
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
        .Q(observe_wb_flags[0]),
        .R(rst));
  (* SOFT_HLUTNM = "soft_lutpair51" *) 
  LUT5 #(
    .INIT(32'h02000220)) 
    w_valid_i_1
       (.I0(observe_pipeline_valid[1]),
        .I1(rst),
        .I2(mode[2]),
        .I3(mode[1]),
        .I4(mode[0]),
        .O(w_valid_next));
  FDRE w_valid_reg
       (.C(clk),
        .CE(1'b1),
        .D(w_valid_next),
        .Q(observe_pipeline_valid[0]),
        .R(rst));
  FDRE w_wb_sel_reg
       (.C(clk),
        .CE(1'b1),
        .D(m_wb_sel),
        .Q(w_wb_sel),
        .R(rst));
  (* SOFT_HLUTNM = "soft_lutpair65" *) 
  LUT4 #(
    .INIT(16'h2000)) 
    w_z_write_i_1
       (.I0(w_valid_next),
        .I1(m_fault),
        .I2(observe_redirect_INST_0_i_4_n_0),
        .I3(m_z_write),
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
    .INIT(64'h0000000000000008)) 
    x_cv_write_i_1
       (.I0(d_cv_write),
        .I1(observe_pipeline_valid[3]),
        .I2(im_en_INST_0_i_1_n_0),
        .I3(im_en_INST_0_i_2_n_0),
        .I4(d_fetch_fault),
        .I5(d_illegal),
        .O(x_cv_write0));
  FDRE x_cv_write_reg
       (.C(clk),
        .CE(1'b1),
        .D(x_cv_write0),
        .Q(x_cv_write),
        .R(rst));
  (* SOFT_HLUTNM = "soft_lutpair45" *) 
  LUT5 #(
    .INIT(32'h000E0000)) 
    x_fault_i_1
       (.I0(d_illegal),
        .I1(d_fetch_fault),
        .I2(im_en_INST_0_i_2_n_0),
        .I3(im_en_INST_0_i_1_n_0),
        .I4(observe_pipeline_valid[3]),
        .O(x_reason2));
  FDRE x_fault_reg
       (.C(clk),
        .CE(1'b1),
        .D(x_reason2),
        .Q(x_fault),
        .R(rst));
  LUT6 #(
    .INIT(64'h0000000000000008)) 
    x_halt_i_1
       (.I0(d_halt),
        .I1(observe_pipeline_valid[3]),
        .I2(im_en_INST_0_i_1_n_0),
        .I3(im_en_INST_0_i_2_n_0),
        .I4(d_fetch_fault),
        .I5(d_illegal),
        .O(x_halt0));
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
  FDRE \x_imm_ext_reg[7] 
       (.C(clk),
        .CE(1'b1),
        .D(im_dout[7]),
        .Q(x_imm_ext[7]),
        .R(rst));
  LUT6 #(
    .INIT(64'h0000000000000008)) 
    x_jump_abs_i_1
       (.I0(d_jump_abs),
        .I1(observe_pipeline_valid[3]),
        .I2(im_en_INST_0_i_1_n_0),
        .I3(im_en_INST_0_i_2_n_0),
        .I4(d_fetch_fault),
        .I5(d_illegal),
        .O(x_jump_abs0));
  FDRE x_jump_abs_reg
       (.C(clk),
        .CE(1'b1),
        .D(x_jump_abs0),
        .Q(x_jump_abs),
        .R(rst));
  LUT6 #(
    .INIT(64'h0000000000000008)) 
    x_jump_z_i_1
       (.I0(d_jump_z),
        .I1(observe_pipeline_valid[3]),
        .I2(im_en_INST_0_i_1_n_0),
        .I3(im_en_INST_0_i_2_n_0),
        .I4(d_fetch_fault),
        .I5(d_illegal),
        .O(x_jump_z0));
  FDRE x_jump_z_reg
       (.C(clk),
        .CE(1'b1),
        .D(x_jump_z0),
        .Q(x_jump_z),
        .R(rst));
  LUT6 #(
    .INIT(64'h0000000000000008)) 
    x_mem_read_i_1
       (.I0(d_mem_read),
        .I1(observe_pipeline_valid[3]),
        .I2(im_en_INST_0_i_1_n_0),
        .I3(im_en_INST_0_i_2_n_0),
        .I4(d_fetch_fault),
        .I5(d_illegal),
        .O(x_mem_read0));
  FDRE x_mem_read_reg
       (.C(clk),
        .CE(1'b1),
        .D(x_mem_read0),
        .Q(x_mem_read),
        .R(rst));
  LUT6 #(
    .INIT(64'h0000000000000008)) 
    x_mem_write_i_1
       (.I0(d_mem_write),
        .I1(observe_pipeline_valid[3]),
        .I2(im_en_INST_0_i_1_n_0),
        .I3(im_en_INST_0_i_2_n_0),
        .I4(d_fetch_fault),
        .I5(d_illegal),
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
  (* SOFT_HLUTNM = "soft_lutpair45" *) 
  LUT4 #(
    .INIT(16'h0200)) 
    \x_reason[0]_i_1 
       (.I0(d_fetch_fault),
        .I1(im_en_INST_0_i_2_n_0),
        .I2(im_en_INST_0_i_1_n_0),
        .I3(observe_pipeline_valid[3]),
        .O(\x_reason[0]_i_1_n_0 ));
  FDRE \x_reason_reg[0] 
       (.C(clk),
        .CE(1'b1),
        .D(\x_reason[0]_i_1_n_0 ),
        .Q(x_reason),
        .R(rst));
  LUT6 #(
    .INIT(64'h0000000000000008)) 
    x_reg_write_i_1
       (.I0(d_reg_write),
        .I1(observe_pipeline_valid[3]),
        .I2(im_en_INST_0_i_1_n_0),
        .I3(im_en_INST_0_i_2_n_0),
        .I4(d_fetch_fault),
        .I5(d_illegal),
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
    .INIT(64'h0000000000000008)) 
    x_use_rd_i_1
       (.I0(d_use_rd),
        .I1(observe_pipeline_valid[3]),
        .I2(im_en_INST_0_i_1_n_0),
        .I3(im_en_INST_0_i_2_n_0),
        .I4(d_fetch_fault),
        .I5(d_illegal),
        .O(x_use_rd0));
  FDRE x_use_rd_reg
       (.C(clk),
        .CE(1'b1),
        .D(x_use_rd0),
        .Q(x_use_rd),
        .R(rst));
  LUT6 #(
    .INIT(64'h0000000000000008)) 
    x_use_rs_i_1
       (.I0(d_use_rs),
        .I1(observe_pipeline_valid[3]),
        .I2(im_en_INST_0_i_1_n_0),
        .I3(im_en_INST_0_i_2_n_0),
        .I4(d_fetch_fault),
        .I5(d_illegal),
        .O(x_use_rs0));
  FDRE x_use_rs_reg
       (.C(clk),
        .CE(1'b1),
        .D(x_use_rs0),
        .Q(x_use_rs),
        .R(rst));
  (* SOFT_HLUTNM = "soft_lutpair75" *) 
  LUT3 #(
    .INIT(8'h10)) 
    x_valid_i_1
       (.I0(im_en_INST_0_i_2_n_0),
        .I1(im_en_INST_0_i_1_n_0),
        .I2(observe_pipeline_valid[3]),
        .O(x_valid_next));
  FDRE x_valid_reg
       (.C(clk),
        .CE(1'b1),
        .D(x_valid_next),
        .Q(observe_pipeline_valid[2]),
        .R(rst));
  FDRE x_wb_sel_reg
       (.C(clk),
        .CE(1'b1),
        .D(d_mem_read),
        .Q(x_wb_sel),
        .R(rst));
  LUT6 #(
    .INIT(64'h0000000000000008)) 
    x_z_write_i_1
       (.I0(d_z_write),
        .I1(observe_pipeline_valid[3]),
        .I2(im_en_INST_0_i_1_n_0),
        .I3(im_en_INST_0_i_2_n_0),
        .I4(d_fetch_fault),
        .I5(d_illegal),
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

(* INIT_FILE = "programs/all_ops_im.mem" *) 
module instruction_memory
   (clk,
    en,
    addr,
    dout);
  input clk;
  input en;
  input [7:0]addr;
  output [15:0]dout;

  wire \<const0> ;
  wire [7:0]addr;
  wire clk;
  wire [15:0]\^dout ;
  wire en;
  wire [15:14]NLW_dout_reg_DOADO_UNCONNECTED;
  wire [15:0]NLW_dout_reg_DOBDO_UNCONNECTED;
  wire [1:0]NLW_dout_reg_DOPADOP_UNCONNECTED;
  wire [1:0]NLW_dout_reg_DOPBDOP_UNCONNECTED;

  assign dout[15:7] = \^dout [15:7];
  assign dout[6] = \<const0> ;
  assign dout[5:4] = \^dout [5:4];
  assign dout[3] = \<const0> ;
  assign dout[2:0] = \^dout [2:0];
  GND GND
       (.G(\<const0> ));
  (* \MEM.PORTA.DATA_BIT_LAYOUT  = "p0_d14" *) 
  (* METHODOLOGY_DRC_VIOS = "{SYNTH-6 {cell *THIS*}}" *) 
  (* RTL_RAM_BITS = "3584" *) 
  (* RTL_RAM_NAME = "instruction_memory/dout_reg" *) 
  (* RTL_RAM_STYLE = "NONE" *) 
  (* RTL_RAM_TYPE = "RAM_SP" *) 
  (* ram_addr_begin = "0" *) 
  (* ram_addr_end = "1023" *) 
  (* ram_offset = "0" *) 
  (* ram_slice_begin = "0" *) 
  (* ram_slice_end = "13" *) 
  RAMB18E1 #(
    .DOA_REG(0),
    .DOB_REG(0),
    .INITP_00(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_01(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_02(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_03(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_04(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_05(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_06(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_07(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_00(256'h300A26C13401284021C024C007100C8008401E01184016011040020005030405),
    .INIT_01(256'h2C002C002C002C002C002C002C002C002C002C002C002C002C0038002C00063F),
    .INIT_02(256'h2C002C002C002C002C002C002C002C002C002C002C002C002C002C002C002C00),
    .INIT_03(256'h2C002C002C002C002C002C002C002C002C002C002C002C002C002C002C002C00),
    .INIT_04(256'h2C002C002C002C002C002C002C002C002C002C002C002C002C002C002C002C00),
    .INIT_05(256'h2C002C002C002C002C002C002C002C002C002C002C002C002C002C002C002C00),
    .INIT_06(256'h2C002C002C002C002C002C002C002C002C002C002C002C002C002C002C002C00),
    .INIT_07(256'h2C002C002C002C002C002C002C002C002C002C002C002C002C002C002C002C00),
    .INIT_08(256'h2C002C002C002C002C002C002C002C002C002C002C002C002C002C002C002C00),
    .INIT_09(256'h2C002C002C002C002C002C002C002C002C002C002C002C002C002C002C002C00),
    .INIT_0A(256'h2C002C002C002C002C002C002C002C002C002C002C002C002C002C002C002C00),
    .INIT_0B(256'h2C002C002C002C002C002C002C002C002C002C002C002C002C002C002C002C00),
    .INIT_0C(256'h2C002C002C002C002C002C002C002C002C002C002C002C002C002C002C002C00),
    .INIT_0D(256'h2C002C002C002C002C002C002C002C002C002C002C002C002C002C002C002C00),
    .INIT_0E(256'h2C002C002C002C002C002C002C002C002C002C002C002C002C002C002C002C00),
    .INIT_0F(256'h2C002C002C002C002C002C002C002C002C002C002C002C002C002C002C002C00),
    .INIT_10(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_11(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_12(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_13(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_14(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_15(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_16(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_17(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_18(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_19(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_1A(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_1B(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_1C(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_1D(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_1E(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_1F(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_20(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_21(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_22(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_23(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_24(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_25(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_26(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_27(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_28(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_29(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_2A(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_2B(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_2C(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_2D(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_2E(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_2F(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_30(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_31(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_32(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_33(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_34(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_35(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_36(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_37(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_38(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_39(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_3A(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_3B(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_3C(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_3D(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_3E(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_3F(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_A(18'h00000),
    .INIT_B(18'h00000),
    .RAM_MODE("TDP"),
    .RDADDR_COLLISION_HWCONFIG("PERFORMANCE"),
    .READ_WIDTH_A(18),
    .READ_WIDTH_B(0),
    .RSTREG_PRIORITY_A("RSTREG"),
    .RSTREG_PRIORITY_B("RSTREG"),
    .SIM_COLLISION_CHECK("ALL"),
    .SIM_DEVICE("7SERIES"),
    .SRVAL_A(18'h00000),
    .SRVAL_B(18'h00000),
    .WRITE_MODE_A("WRITE_FIRST"),
    .WRITE_MODE_B("WRITE_FIRST"),
    .WRITE_WIDTH_A(18),
    .WRITE_WIDTH_B(0)) 
    dout_reg
       (.ADDRARDADDR({1'b0,1'b0,addr,1'b0,1'b0,1'b0,1'b0}),
        .ADDRBWRADDR({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .CLKARDCLK(clk),
        .CLKBWRCLK(1'b0),
        .DIADI({1'b0,1'b0,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .DIBDI({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .DIPADIP({1'b0,1'b0}),
        .DIPBDIP({1'b1,1'b1}),
        .DOADO({NLW_dout_reg_DOADO_UNCONNECTED[15:14],\^dout [15:7],\^dout [5:4],\^dout [2:0]}),
        .DOBDO(NLW_dout_reg_DOBDO_UNCONNECTED[15:0]),
        .DOPADOP(NLW_dout_reg_DOPADOP_UNCONNECTED[1:0]),
        .DOPBDOP(NLW_dout_reg_DOPBDOP_UNCONNECTED[1:0]),
        .ENARDEN(en),
        .ENBWREN(1'b0),
        .REGCEAREGCE(1'b0),
        .REGCEB(1'b0),
        .RSTRAMARSTRAM(1'b0),
        .RSTRAMB(1'b0),
        .RSTREGARSTREG(1'b0),
        .RSTREGB(1'b0),
        .WEA({1'b0,1'b0}),
        .WEBWE({1'b0,1'b0,1'b0,1'b0}));
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
  (* SOFT_HLUTNM = "soft_lutpair15" *) 
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
  (* SOFT_HLUTNM = "soft_lutpair13" *) 
  LUT4 #(
    .INIT(16'h1171)) 
    \alu_b_sel[0]_INST_0 
       (.I0(inst[12]),
        .I1(inst[15]),
        .I2(inst[13]),
        .I3(inst[14]),
        .O(alu_b_sel[0]));
  (* SOFT_HLUTNM = "soft_lutpair13" *) 
  LUT4 #(
    .INIT(16'h1B10)) 
    \alu_b_sel[1]_INST_0 
       (.I0(inst[14]),
        .I1(inst[13]),
        .I2(inst[15]),
        .I3(inst[12]),
        .O(alu_b_sel[1]));
  (* SOFT_HLUTNM = "soft_lutpair14" *) 
  LUT4 #(
    .INIT(16'h0334)) 
    \alu_op[0]_INST_0 
       (.I0(inst[12]),
        .I1(inst[13]),
        .I2(inst[14]),
        .I3(inst[15]),
        .O(alu_op[0]));
  (* SOFT_HLUTNM = "soft_lutpair14" *) 
  LUT4 #(
    .INIT(16'h4500)) 
    \alu_op[1]_INST_0 
       (.I0(inst[15]),
        .I1(inst[14]),
        .I2(inst[12]),
        .I3(inst[13]),
        .O(alu_op[1]));
  (* SOFT_HLUTNM = "soft_lutpair15" *) 
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
  (* SOFT_HLUTNM = "soft_lutpair10" *) 
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
  (* SOFT_HLUTNM = "soft_lutpair9" *) 
  LUT4 #(
    .INIT(16'h4500)) 
    imm_signed_INST_0
       (.I0(inst[13]),
        .I1(inst[12]),
        .I2(inst[14]),
        .I3(inst[15]),
        .O(imm_signed));
  (* SOFT_HLUTNM = "soft_lutpair11" *) 
  LUT4 #(
    .INIT(16'h1000)) 
    jump_abs_INST_0
       (.I0(inst[12]),
        .I1(inst[13]),
        .I2(inst[15]),
        .I3(inst[14]),
        .O(jump_abs));
  (* SOFT_HLUTNM = "soft_lutpair12" *) 
  LUT4 #(
    .INIT(16'h0080)) 
    jump_z_INST_0
       (.I0(inst[12]),
        .I1(inst[15]),
        .I2(inst[14]),
        .I3(inst[13]),
        .O(jump_z));
  (* SOFT_HLUTNM = "soft_lutpair11" *) 
  LUT4 #(
    .INIT(16'h0010)) 
    mem_read_INST_0
       (.I0(inst[12]),
        .I1(inst[14]),
        .I2(inst[15]),
        .I3(inst[13]),
        .O(mem_read));
  (* SOFT_HLUTNM = "soft_lutpair12" *) 
  LUT4 #(
    .INIT(16'h0008)) 
    mem_write_INST_0
       (.I0(inst[12]),
        .I1(inst[15]),
        .I2(inst[13]),
        .I3(inst[14]),
        .O(mem_write));
  (* SOFT_HLUTNM = "soft_lutpair9" *) 
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
  (* SOFT_HLUTNM = "soft_lutpair10" *) 
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

  (* SOFT_HLUTNM = "soft_lutpair6" *) 
  LUT3 #(
    .INIT(8'hA3)) 
    \pc[0]_i_1 
       (.I0(target[0]),
        .I1(pc[0]),
        .I2(redirect),
        .O(p_1_in[0]));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \pc[10]_i_1 
       (.I0(target[10]),
        .I1(pc0[10]),
        .I2(redirect),
        .O(p_1_in[10]));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \pc[11]_i_1 
       (.I0(target[11]),
        .I1(pc0[11]),
        .I2(redirect),
        .O(p_1_in[11]));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
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
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
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
  (* SOFT_HLUTNM = "soft_lutpair6" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \pc[1]_i_1 
       (.I0(target[1]),
        .I1(pc0[1]),
        .I2(redirect),
        .O(p_1_in[1]));
  (* SOFT_HLUTNM = "soft_lutpair7" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \pc[2]_i_1 
       (.I0(target[2]),
        .I1(pc0[2]),
        .I2(redirect),
        .O(p_1_in[2]));
  (* SOFT_HLUTNM = "soft_lutpair7" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \pc[3]_i_1 
       (.I0(target[3]),
        .I1(pc0[3]),
        .I2(redirect),
        .O(p_1_in[3]));
  (* SOFT_HLUTNM = "soft_lutpair5" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \pc[4]_i_1 
       (.I0(target[4]),
        .I1(pc0[4]),
        .I2(redirect),
        .O(p_1_in[4]));
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \pc[5]_i_1 
       (.I0(target[5]),
        .I1(pc0[5]),
        .I2(redirect),
        .O(p_1_in[5]));
  (* SOFT_HLUTNM = "soft_lutpair5" *) 
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
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \pc[8]_i_1 
       (.I0(target[8]),
        .I1(pc0[8]),
        .I2(redirect),
        .O(p_1_in[8]));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
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
