// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2025.2 (win64) Build 6299465 Fri Nov 14 19:35:11 GMT 2025
// Date        : Sun Sep 20 21:14:47 2026
// Host        : LAPTOP-BSM79J69 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim synthesis/regfile4x16_netlist.v
// Design      : regfile4x16
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z010clg400-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* NotValidForBitStream *)
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
  wire clk_IBUF;
  wire clk_IBUF_BUFG;
  wire [1:0]raddr_a;
  wire [1:0]raddr_a_IBUF;
  wire [1:0]raddr_b;
  wire [1:0]raddr_b_IBUF;
  wire [15:0]rdata_a;
  wire rdata_a1;
  wire [15:0]rdata_a_OBUF;
  wire [15:0]rdata_b;
  wire rdata_b1;
  wire [15:0]rdata_b_OBUF;
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
  wire rst_IBUF;
  wire [1:0]waddr;
  wire [1:0]waddr_IBUF;
  wire [15:0]wdata;
  wire [15:0]wdata_IBUF;
  wire we;
  wire we_IBUF;

  BUFG clk_IBUF_BUFG_inst
       (.I(clk_IBUF),
        .O(clk_IBUF_BUFG));
  IBUF clk_IBUF_inst
       (.I(clk),
        .O(clk_IBUF));
  IBUF \raddr_a_IBUF[0]_inst 
       (.I(raddr_a[0]),
        .O(raddr_a_IBUF[0]));
  IBUF \raddr_a_IBUF[1]_inst 
       (.I(raddr_a[1]),
        .O(raddr_a_IBUF[1]));
  IBUF \raddr_b_IBUF[0]_inst 
       (.I(raddr_b[0]),
        .O(raddr_b_IBUF[0]));
  IBUF \raddr_b_IBUF[1]_inst 
       (.I(raddr_b[1]),
        .O(raddr_b_IBUF[1]));
  OBUF \rdata_a_OBUF[0]_inst 
       (.I(rdata_a_OBUF[0]),
        .O(rdata_a[0]));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \rdata_a_OBUF[0]_inst_i_1 
       (.I0(wdata_IBUF[0]),
        .I1(rdata_a1),
        .I2(regs__0[0]),
        .O(rdata_a_OBUF[0]));
  LUT6 #(
    .INIT(64'hF0AAFFCCF0AA00CC)) 
    \rdata_a_OBUF[0]_inst_i_2 
       (.I0(\regs_reg[1] [0]),
        .I1(\regs_reg[0] [0]),
        .I2(\regs_reg[3] [0]),
        .I3(raddr_a_IBUF[1]),
        .I4(raddr_a_IBUF[0]),
        .I5(\regs_reg[2] [0]),
        .O(regs__0[0]));
  OBUF \rdata_a_OBUF[10]_inst 
       (.I(rdata_a_OBUF[10]),
        .O(rdata_a[10]));
  (* SOFT_HLUTNM = "soft_lutpair10" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \rdata_a_OBUF[10]_inst_i_1 
       (.I0(wdata_IBUF[10]),
        .I1(rdata_a1),
        .I2(regs__0[10]),
        .O(rdata_a_OBUF[10]));
  LUT6 #(
    .INIT(64'hF0AAFFCCF0AA00CC)) 
    \rdata_a_OBUF[10]_inst_i_2 
       (.I0(\regs_reg[1] [10]),
        .I1(\regs_reg[0] [10]),
        .I2(\regs_reg[3] [10]),
        .I3(raddr_a_IBUF[1]),
        .I4(raddr_a_IBUF[0]),
        .I5(\regs_reg[2] [10]),
        .O(regs__0[10]));
  OBUF \rdata_a_OBUF[11]_inst 
       (.I(rdata_a_OBUF[11]),
        .O(rdata_a[11]));
  (* SOFT_HLUTNM = "soft_lutpair11" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \rdata_a_OBUF[11]_inst_i_1 
       (.I0(wdata_IBUF[11]),
        .I1(rdata_a1),
        .I2(regs__0[11]),
        .O(rdata_a_OBUF[11]));
  LUT6 #(
    .INIT(64'hF0AAFFCCF0AA00CC)) 
    \rdata_a_OBUF[11]_inst_i_2 
       (.I0(\regs_reg[1] [11]),
        .I1(\regs_reg[0] [11]),
        .I2(\regs_reg[3] [11]),
        .I3(raddr_a_IBUF[1]),
        .I4(raddr_a_IBUF[0]),
        .I5(\regs_reg[2] [11]),
        .O(regs__0[11]));
  OBUF \rdata_a_OBUF[12]_inst 
       (.I(rdata_a_OBUF[12]),
        .O(rdata_a[12]));
  (* SOFT_HLUTNM = "soft_lutpair12" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \rdata_a_OBUF[12]_inst_i_1 
       (.I0(wdata_IBUF[12]),
        .I1(rdata_a1),
        .I2(regs__0[12]),
        .O(rdata_a_OBUF[12]));
  LUT6 #(
    .INIT(64'hF0AAFFCCF0AA00CC)) 
    \rdata_a_OBUF[12]_inst_i_2 
       (.I0(\regs_reg[1] [12]),
        .I1(\regs_reg[0] [12]),
        .I2(\regs_reg[3] [12]),
        .I3(raddr_a_IBUF[1]),
        .I4(raddr_a_IBUF[0]),
        .I5(\regs_reg[2] [12]),
        .O(regs__0[12]));
  OBUF \rdata_a_OBUF[13]_inst 
       (.I(rdata_a_OBUF[13]),
        .O(rdata_a[13]));
  (* SOFT_HLUTNM = "soft_lutpair13" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \rdata_a_OBUF[13]_inst_i_1 
       (.I0(wdata_IBUF[13]),
        .I1(rdata_a1),
        .I2(regs__0[13]),
        .O(rdata_a_OBUF[13]));
  LUT6 #(
    .INIT(64'hF0AAFFCCF0AA00CC)) 
    \rdata_a_OBUF[13]_inst_i_2 
       (.I0(\regs_reg[1] [13]),
        .I1(\regs_reg[0] [13]),
        .I2(\regs_reg[3] [13]),
        .I3(raddr_a_IBUF[1]),
        .I4(raddr_a_IBUF[0]),
        .I5(\regs_reg[2] [13]),
        .O(regs__0[13]));
  OBUF \rdata_a_OBUF[14]_inst 
       (.I(rdata_a_OBUF[14]),
        .O(rdata_a[14]));
  (* SOFT_HLUTNM = "soft_lutpair14" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \rdata_a_OBUF[14]_inst_i_1 
       (.I0(wdata_IBUF[14]),
        .I1(rdata_a1),
        .I2(regs__0[14]),
        .O(rdata_a_OBUF[14]));
  LUT6 #(
    .INIT(64'hF0AAFFCCF0AA00CC)) 
    \rdata_a_OBUF[14]_inst_i_2 
       (.I0(\regs_reg[1] [14]),
        .I1(\regs_reg[0] [14]),
        .I2(\regs_reg[3] [14]),
        .I3(raddr_a_IBUF[1]),
        .I4(raddr_a_IBUF[0]),
        .I5(\regs_reg[2] [14]),
        .O(regs__0[14]));
  OBUF \rdata_a_OBUF[15]_inst 
       (.I(rdata_a_OBUF[15]),
        .O(rdata_a[15]));
  (* SOFT_HLUTNM = "soft_lutpair15" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \rdata_a_OBUF[15]_inst_i_1 
       (.I0(wdata_IBUF[15]),
        .I1(rdata_a1),
        .I2(regs__0[15]),
        .O(rdata_a_OBUF[15]));
  LUT6 #(
    .INIT(64'h4004000000004004)) 
    \rdata_a_OBUF[15]_inst_i_2 
       (.I0(rst_IBUF),
        .I1(we_IBUF),
        .I2(raddr_a_IBUF[1]),
        .I3(waddr_IBUF[1]),
        .I4(raddr_a_IBUF[0]),
        .I5(waddr_IBUF[0]),
        .O(rdata_a1));
  LUT6 #(
    .INIT(64'hF0AAFFCCF0AA00CC)) 
    \rdata_a_OBUF[15]_inst_i_3 
       (.I0(\regs_reg[1] [15]),
        .I1(\regs_reg[0] [15]),
        .I2(\regs_reg[3] [15]),
        .I3(raddr_a_IBUF[1]),
        .I4(raddr_a_IBUF[0]),
        .I5(\regs_reg[2] [15]),
        .O(regs__0[15]));
  OBUF \rdata_a_OBUF[1]_inst 
       (.I(rdata_a_OBUF[1]),
        .O(rdata_a[1]));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \rdata_a_OBUF[1]_inst_i_1 
       (.I0(wdata_IBUF[1]),
        .I1(rdata_a1),
        .I2(regs__0[1]),
        .O(rdata_a_OBUF[1]));
  LUT6 #(
    .INIT(64'hF0AAFFCCF0AA00CC)) 
    \rdata_a_OBUF[1]_inst_i_2 
       (.I0(\regs_reg[1] [1]),
        .I1(\regs_reg[0] [1]),
        .I2(\regs_reg[3] [1]),
        .I3(raddr_a_IBUF[1]),
        .I4(raddr_a_IBUF[0]),
        .I5(\regs_reg[2] [1]),
        .O(regs__0[1]));
  OBUF \rdata_a_OBUF[2]_inst 
       (.I(rdata_a_OBUF[2]),
        .O(rdata_a[2]));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \rdata_a_OBUF[2]_inst_i_1 
       (.I0(wdata_IBUF[2]),
        .I1(rdata_a1),
        .I2(regs__0[2]),
        .O(rdata_a_OBUF[2]));
  LUT6 #(
    .INIT(64'hF0AAFFCCF0AA00CC)) 
    \rdata_a_OBUF[2]_inst_i_2 
       (.I0(\regs_reg[1] [2]),
        .I1(\regs_reg[0] [2]),
        .I2(\regs_reg[3] [2]),
        .I3(raddr_a_IBUF[1]),
        .I4(raddr_a_IBUF[0]),
        .I5(\regs_reg[2] [2]),
        .O(regs__0[2]));
  OBUF \rdata_a_OBUF[3]_inst 
       (.I(rdata_a_OBUF[3]),
        .O(rdata_a[3]));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \rdata_a_OBUF[3]_inst_i_1 
       (.I0(wdata_IBUF[3]),
        .I1(rdata_a1),
        .I2(regs__0[3]),
        .O(rdata_a_OBUF[3]));
  LUT6 #(
    .INIT(64'hF0AAFFCCF0AA00CC)) 
    \rdata_a_OBUF[3]_inst_i_2 
       (.I0(\regs_reg[1] [3]),
        .I1(\regs_reg[0] [3]),
        .I2(\regs_reg[3] [3]),
        .I3(raddr_a_IBUF[1]),
        .I4(raddr_a_IBUF[0]),
        .I5(\regs_reg[2] [3]),
        .O(regs__0[3]));
  OBUF \rdata_a_OBUF[4]_inst 
       (.I(rdata_a_OBUF[4]),
        .O(rdata_a[4]));
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \rdata_a_OBUF[4]_inst_i_1 
       (.I0(wdata_IBUF[4]),
        .I1(rdata_a1),
        .I2(regs__0[4]),
        .O(rdata_a_OBUF[4]));
  LUT6 #(
    .INIT(64'hF0AAFFCCF0AA00CC)) 
    \rdata_a_OBUF[4]_inst_i_2 
       (.I0(\regs_reg[1] [4]),
        .I1(\regs_reg[0] [4]),
        .I2(\regs_reg[3] [4]),
        .I3(raddr_a_IBUF[1]),
        .I4(raddr_a_IBUF[0]),
        .I5(\regs_reg[2] [4]),
        .O(regs__0[4]));
  OBUF \rdata_a_OBUF[5]_inst 
       (.I(rdata_a_OBUF[5]),
        .O(rdata_a[5]));
  (* SOFT_HLUTNM = "soft_lutpair5" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \rdata_a_OBUF[5]_inst_i_1 
       (.I0(wdata_IBUF[5]),
        .I1(rdata_a1),
        .I2(regs__0[5]),
        .O(rdata_a_OBUF[5]));
  LUT6 #(
    .INIT(64'hF0AAFFCCF0AA00CC)) 
    \rdata_a_OBUF[5]_inst_i_2 
       (.I0(\regs_reg[1] [5]),
        .I1(\regs_reg[0] [5]),
        .I2(\regs_reg[3] [5]),
        .I3(raddr_a_IBUF[1]),
        .I4(raddr_a_IBUF[0]),
        .I5(\regs_reg[2] [5]),
        .O(regs__0[5]));
  OBUF \rdata_a_OBUF[6]_inst 
       (.I(rdata_a_OBUF[6]),
        .O(rdata_a[6]));
  (* SOFT_HLUTNM = "soft_lutpair6" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \rdata_a_OBUF[6]_inst_i_1 
       (.I0(wdata_IBUF[6]),
        .I1(rdata_a1),
        .I2(regs__0[6]),
        .O(rdata_a_OBUF[6]));
  LUT6 #(
    .INIT(64'hF0AAFFCCF0AA00CC)) 
    \rdata_a_OBUF[6]_inst_i_2 
       (.I0(\regs_reg[1] [6]),
        .I1(\regs_reg[0] [6]),
        .I2(\regs_reg[3] [6]),
        .I3(raddr_a_IBUF[1]),
        .I4(raddr_a_IBUF[0]),
        .I5(\regs_reg[2] [6]),
        .O(regs__0[6]));
  OBUF \rdata_a_OBUF[7]_inst 
       (.I(rdata_a_OBUF[7]),
        .O(rdata_a[7]));
  (* SOFT_HLUTNM = "soft_lutpair7" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \rdata_a_OBUF[7]_inst_i_1 
       (.I0(wdata_IBUF[7]),
        .I1(rdata_a1),
        .I2(regs__0[7]),
        .O(rdata_a_OBUF[7]));
  LUT6 #(
    .INIT(64'hF0AAFFCCF0AA00CC)) 
    \rdata_a_OBUF[7]_inst_i_2 
       (.I0(\regs_reg[1] [7]),
        .I1(\regs_reg[0] [7]),
        .I2(\regs_reg[3] [7]),
        .I3(raddr_a_IBUF[1]),
        .I4(raddr_a_IBUF[0]),
        .I5(\regs_reg[2] [7]),
        .O(regs__0[7]));
  OBUF \rdata_a_OBUF[8]_inst 
       (.I(rdata_a_OBUF[8]),
        .O(rdata_a[8]));
  (* SOFT_HLUTNM = "soft_lutpair8" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \rdata_a_OBUF[8]_inst_i_1 
       (.I0(wdata_IBUF[8]),
        .I1(rdata_a1),
        .I2(regs__0[8]),
        .O(rdata_a_OBUF[8]));
  LUT6 #(
    .INIT(64'hF0AAFFCCF0AA00CC)) 
    \rdata_a_OBUF[8]_inst_i_2 
       (.I0(\regs_reg[1] [8]),
        .I1(\regs_reg[0] [8]),
        .I2(\regs_reg[3] [8]),
        .I3(raddr_a_IBUF[1]),
        .I4(raddr_a_IBUF[0]),
        .I5(\regs_reg[2] [8]),
        .O(regs__0[8]));
  OBUF \rdata_a_OBUF[9]_inst 
       (.I(rdata_a_OBUF[9]),
        .O(rdata_a[9]));
  (* SOFT_HLUTNM = "soft_lutpair9" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \rdata_a_OBUF[9]_inst_i_1 
       (.I0(wdata_IBUF[9]),
        .I1(rdata_a1),
        .I2(regs__0[9]),
        .O(rdata_a_OBUF[9]));
  LUT6 #(
    .INIT(64'hF0AAFFCCF0AA00CC)) 
    \rdata_a_OBUF[9]_inst_i_2 
       (.I0(\regs_reg[1] [9]),
        .I1(\regs_reg[0] [9]),
        .I2(\regs_reg[3] [9]),
        .I3(raddr_a_IBUF[1]),
        .I4(raddr_a_IBUF[0]),
        .I5(\regs_reg[2] [9]),
        .O(regs__0[9]));
  OBUF \rdata_b_OBUF[0]_inst 
       (.I(rdata_b_OBUF[0]),
        .O(rdata_b[0]));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \rdata_b_OBUF[0]_inst_i_1 
       (.I0(wdata_IBUF[0]),
        .I1(rdata_b1),
        .I2(regs__0__0[0]),
        .O(rdata_b_OBUF[0]));
  LUT6 #(
    .INIT(64'hF0AAFFCCF0AA00CC)) 
    \rdata_b_OBUF[0]_inst_i_2 
       (.I0(\regs_reg[1] [0]),
        .I1(\regs_reg[0] [0]),
        .I2(\regs_reg[3] [0]),
        .I3(raddr_b_IBUF[1]),
        .I4(raddr_b_IBUF[0]),
        .I5(\regs_reg[2] [0]),
        .O(regs__0__0[0]));
  OBUF \rdata_b_OBUF[10]_inst 
       (.I(rdata_b_OBUF[10]),
        .O(rdata_b[10]));
  (* SOFT_HLUTNM = "soft_lutpair10" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \rdata_b_OBUF[10]_inst_i_1 
       (.I0(wdata_IBUF[10]),
        .I1(rdata_b1),
        .I2(regs__0__0[10]),
        .O(rdata_b_OBUF[10]));
  LUT6 #(
    .INIT(64'hF0AAFFCCF0AA00CC)) 
    \rdata_b_OBUF[10]_inst_i_2 
       (.I0(\regs_reg[1] [10]),
        .I1(\regs_reg[0] [10]),
        .I2(\regs_reg[3] [10]),
        .I3(raddr_b_IBUF[1]),
        .I4(raddr_b_IBUF[0]),
        .I5(\regs_reg[2] [10]),
        .O(regs__0__0[10]));
  OBUF \rdata_b_OBUF[11]_inst 
       (.I(rdata_b_OBUF[11]),
        .O(rdata_b[11]));
  (* SOFT_HLUTNM = "soft_lutpair11" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \rdata_b_OBUF[11]_inst_i_1 
       (.I0(wdata_IBUF[11]),
        .I1(rdata_b1),
        .I2(regs__0__0[11]),
        .O(rdata_b_OBUF[11]));
  LUT6 #(
    .INIT(64'hF0AAFFCCF0AA00CC)) 
    \rdata_b_OBUF[11]_inst_i_2 
       (.I0(\regs_reg[1] [11]),
        .I1(\regs_reg[0] [11]),
        .I2(\regs_reg[3] [11]),
        .I3(raddr_b_IBUF[1]),
        .I4(raddr_b_IBUF[0]),
        .I5(\regs_reg[2] [11]),
        .O(regs__0__0[11]));
  OBUF \rdata_b_OBUF[12]_inst 
       (.I(rdata_b_OBUF[12]),
        .O(rdata_b[12]));
  (* SOFT_HLUTNM = "soft_lutpair12" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \rdata_b_OBUF[12]_inst_i_1 
       (.I0(wdata_IBUF[12]),
        .I1(rdata_b1),
        .I2(regs__0__0[12]),
        .O(rdata_b_OBUF[12]));
  LUT6 #(
    .INIT(64'hF0AAFFCCF0AA00CC)) 
    \rdata_b_OBUF[12]_inst_i_2 
       (.I0(\regs_reg[1] [12]),
        .I1(\regs_reg[0] [12]),
        .I2(\regs_reg[3] [12]),
        .I3(raddr_b_IBUF[1]),
        .I4(raddr_b_IBUF[0]),
        .I5(\regs_reg[2] [12]),
        .O(regs__0__0[12]));
  OBUF \rdata_b_OBUF[13]_inst 
       (.I(rdata_b_OBUF[13]),
        .O(rdata_b[13]));
  (* SOFT_HLUTNM = "soft_lutpair13" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \rdata_b_OBUF[13]_inst_i_1 
       (.I0(wdata_IBUF[13]),
        .I1(rdata_b1),
        .I2(regs__0__0[13]),
        .O(rdata_b_OBUF[13]));
  LUT6 #(
    .INIT(64'hF0AAFFCCF0AA00CC)) 
    \rdata_b_OBUF[13]_inst_i_2 
       (.I0(\regs_reg[1] [13]),
        .I1(\regs_reg[0] [13]),
        .I2(\regs_reg[3] [13]),
        .I3(raddr_b_IBUF[1]),
        .I4(raddr_b_IBUF[0]),
        .I5(\regs_reg[2] [13]),
        .O(regs__0__0[13]));
  OBUF \rdata_b_OBUF[14]_inst 
       (.I(rdata_b_OBUF[14]),
        .O(rdata_b[14]));
  (* SOFT_HLUTNM = "soft_lutpair14" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \rdata_b_OBUF[14]_inst_i_1 
       (.I0(wdata_IBUF[14]),
        .I1(rdata_b1),
        .I2(regs__0__0[14]),
        .O(rdata_b_OBUF[14]));
  LUT6 #(
    .INIT(64'hF0AAFFCCF0AA00CC)) 
    \rdata_b_OBUF[14]_inst_i_2 
       (.I0(\regs_reg[1] [14]),
        .I1(\regs_reg[0] [14]),
        .I2(\regs_reg[3] [14]),
        .I3(raddr_b_IBUF[1]),
        .I4(raddr_b_IBUF[0]),
        .I5(\regs_reg[2] [14]),
        .O(regs__0__0[14]));
  OBUF \rdata_b_OBUF[15]_inst 
       (.I(rdata_b_OBUF[15]),
        .O(rdata_b[15]));
  (* SOFT_HLUTNM = "soft_lutpair15" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \rdata_b_OBUF[15]_inst_i_1 
       (.I0(wdata_IBUF[15]),
        .I1(rdata_b1),
        .I2(regs__0__0[15]),
        .O(rdata_b_OBUF[15]));
  LUT6 #(
    .INIT(64'h4004000000004004)) 
    \rdata_b_OBUF[15]_inst_i_2 
       (.I0(rst_IBUF),
        .I1(we_IBUF),
        .I2(raddr_b_IBUF[1]),
        .I3(waddr_IBUF[1]),
        .I4(raddr_b_IBUF[0]),
        .I5(waddr_IBUF[0]),
        .O(rdata_b1));
  LUT6 #(
    .INIT(64'hF0AAFFCCF0AA00CC)) 
    \rdata_b_OBUF[15]_inst_i_3 
       (.I0(\regs_reg[1] [15]),
        .I1(\regs_reg[0] [15]),
        .I2(\regs_reg[3] [15]),
        .I3(raddr_b_IBUF[1]),
        .I4(raddr_b_IBUF[0]),
        .I5(\regs_reg[2] [15]),
        .O(regs__0__0[15]));
  OBUF \rdata_b_OBUF[1]_inst 
       (.I(rdata_b_OBUF[1]),
        .O(rdata_b[1]));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \rdata_b_OBUF[1]_inst_i_1 
       (.I0(wdata_IBUF[1]),
        .I1(rdata_b1),
        .I2(regs__0__0[1]),
        .O(rdata_b_OBUF[1]));
  LUT6 #(
    .INIT(64'hF0AAFFCCF0AA00CC)) 
    \rdata_b_OBUF[1]_inst_i_2 
       (.I0(\regs_reg[1] [1]),
        .I1(\regs_reg[0] [1]),
        .I2(\regs_reg[3] [1]),
        .I3(raddr_b_IBUF[1]),
        .I4(raddr_b_IBUF[0]),
        .I5(\regs_reg[2] [1]),
        .O(regs__0__0[1]));
  OBUF \rdata_b_OBUF[2]_inst 
       (.I(rdata_b_OBUF[2]),
        .O(rdata_b[2]));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \rdata_b_OBUF[2]_inst_i_1 
       (.I0(wdata_IBUF[2]),
        .I1(rdata_b1),
        .I2(regs__0__0[2]),
        .O(rdata_b_OBUF[2]));
  LUT6 #(
    .INIT(64'hF0AAFFCCF0AA00CC)) 
    \rdata_b_OBUF[2]_inst_i_2 
       (.I0(\regs_reg[1] [2]),
        .I1(\regs_reg[0] [2]),
        .I2(\regs_reg[3] [2]),
        .I3(raddr_b_IBUF[1]),
        .I4(raddr_b_IBUF[0]),
        .I5(\regs_reg[2] [2]),
        .O(regs__0__0[2]));
  OBUF \rdata_b_OBUF[3]_inst 
       (.I(rdata_b_OBUF[3]),
        .O(rdata_b[3]));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \rdata_b_OBUF[3]_inst_i_1 
       (.I0(wdata_IBUF[3]),
        .I1(rdata_b1),
        .I2(regs__0__0[3]),
        .O(rdata_b_OBUF[3]));
  LUT6 #(
    .INIT(64'hF0AAFFCCF0AA00CC)) 
    \rdata_b_OBUF[3]_inst_i_2 
       (.I0(\regs_reg[1] [3]),
        .I1(\regs_reg[0] [3]),
        .I2(\regs_reg[3] [3]),
        .I3(raddr_b_IBUF[1]),
        .I4(raddr_b_IBUF[0]),
        .I5(\regs_reg[2] [3]),
        .O(regs__0__0[3]));
  OBUF \rdata_b_OBUF[4]_inst 
       (.I(rdata_b_OBUF[4]),
        .O(rdata_b[4]));
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \rdata_b_OBUF[4]_inst_i_1 
       (.I0(wdata_IBUF[4]),
        .I1(rdata_b1),
        .I2(regs__0__0[4]),
        .O(rdata_b_OBUF[4]));
  LUT6 #(
    .INIT(64'hF0AAFFCCF0AA00CC)) 
    \rdata_b_OBUF[4]_inst_i_2 
       (.I0(\regs_reg[1] [4]),
        .I1(\regs_reg[0] [4]),
        .I2(\regs_reg[3] [4]),
        .I3(raddr_b_IBUF[1]),
        .I4(raddr_b_IBUF[0]),
        .I5(\regs_reg[2] [4]),
        .O(regs__0__0[4]));
  OBUF \rdata_b_OBUF[5]_inst 
       (.I(rdata_b_OBUF[5]),
        .O(rdata_b[5]));
  (* SOFT_HLUTNM = "soft_lutpair5" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \rdata_b_OBUF[5]_inst_i_1 
       (.I0(wdata_IBUF[5]),
        .I1(rdata_b1),
        .I2(regs__0__0[5]),
        .O(rdata_b_OBUF[5]));
  LUT6 #(
    .INIT(64'hF0AAFFCCF0AA00CC)) 
    \rdata_b_OBUF[5]_inst_i_2 
       (.I0(\regs_reg[1] [5]),
        .I1(\regs_reg[0] [5]),
        .I2(\regs_reg[3] [5]),
        .I3(raddr_b_IBUF[1]),
        .I4(raddr_b_IBUF[0]),
        .I5(\regs_reg[2] [5]),
        .O(regs__0__0[5]));
  OBUF \rdata_b_OBUF[6]_inst 
       (.I(rdata_b_OBUF[6]),
        .O(rdata_b[6]));
  (* SOFT_HLUTNM = "soft_lutpair6" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \rdata_b_OBUF[6]_inst_i_1 
       (.I0(wdata_IBUF[6]),
        .I1(rdata_b1),
        .I2(regs__0__0[6]),
        .O(rdata_b_OBUF[6]));
  LUT6 #(
    .INIT(64'hF0AAFFCCF0AA00CC)) 
    \rdata_b_OBUF[6]_inst_i_2 
       (.I0(\regs_reg[1] [6]),
        .I1(\regs_reg[0] [6]),
        .I2(\regs_reg[3] [6]),
        .I3(raddr_b_IBUF[1]),
        .I4(raddr_b_IBUF[0]),
        .I5(\regs_reg[2] [6]),
        .O(regs__0__0[6]));
  OBUF \rdata_b_OBUF[7]_inst 
       (.I(rdata_b_OBUF[7]),
        .O(rdata_b[7]));
  (* SOFT_HLUTNM = "soft_lutpair7" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \rdata_b_OBUF[7]_inst_i_1 
       (.I0(wdata_IBUF[7]),
        .I1(rdata_b1),
        .I2(regs__0__0[7]),
        .O(rdata_b_OBUF[7]));
  LUT6 #(
    .INIT(64'hF0AAFFCCF0AA00CC)) 
    \rdata_b_OBUF[7]_inst_i_2 
       (.I0(\regs_reg[1] [7]),
        .I1(\regs_reg[0] [7]),
        .I2(\regs_reg[3] [7]),
        .I3(raddr_b_IBUF[1]),
        .I4(raddr_b_IBUF[0]),
        .I5(\regs_reg[2] [7]),
        .O(regs__0__0[7]));
  OBUF \rdata_b_OBUF[8]_inst 
       (.I(rdata_b_OBUF[8]),
        .O(rdata_b[8]));
  (* SOFT_HLUTNM = "soft_lutpair8" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \rdata_b_OBUF[8]_inst_i_1 
       (.I0(wdata_IBUF[8]),
        .I1(rdata_b1),
        .I2(regs__0__0[8]),
        .O(rdata_b_OBUF[8]));
  LUT6 #(
    .INIT(64'hF0AAFFCCF0AA00CC)) 
    \rdata_b_OBUF[8]_inst_i_2 
       (.I0(\regs_reg[1] [8]),
        .I1(\regs_reg[0] [8]),
        .I2(\regs_reg[3] [8]),
        .I3(raddr_b_IBUF[1]),
        .I4(raddr_b_IBUF[0]),
        .I5(\regs_reg[2] [8]),
        .O(regs__0__0[8]));
  OBUF \rdata_b_OBUF[9]_inst 
       (.I(rdata_b_OBUF[9]),
        .O(rdata_b[9]));
  (* SOFT_HLUTNM = "soft_lutpair9" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \rdata_b_OBUF[9]_inst_i_1 
       (.I0(wdata_IBUF[9]),
        .I1(rdata_b1),
        .I2(regs__0__0[9]),
        .O(rdata_b_OBUF[9]));
  LUT6 #(
    .INIT(64'hF0AAFFCCF0AA00CC)) 
    \rdata_b_OBUF[9]_inst_i_2 
       (.I0(\regs_reg[1] [9]),
        .I1(\regs_reg[0] [9]),
        .I2(\regs_reg[3] [9]),
        .I3(raddr_b_IBUF[1]),
        .I4(raddr_b_IBUF[0]),
        .I5(\regs_reg[2] [9]),
        .O(regs__0__0[9]));
  LUT3 #(
    .INIT(8'h02)) 
    \regs[0][15]_i_1 
       (.I0(we_IBUF),
        .I1(waddr_IBUF[0]),
        .I2(waddr_IBUF[1]),
        .O(regs));
  LUT3 #(
    .INIT(8'h20)) 
    \regs[1][15]_i_1 
       (.I0(we_IBUF),
        .I1(waddr_IBUF[1]),
        .I2(waddr_IBUF[0]),
        .O(\regs[1][15]_i_1_n_0 ));
  LUT3 #(
    .INIT(8'h20)) 
    \regs[2][15]_i_1 
       (.I0(we_IBUF),
        .I1(waddr_IBUF[0]),
        .I2(waddr_IBUF[1]),
        .O(\regs[2][15]_i_1_n_0 ));
  LUT3 #(
    .INIT(8'h80)) 
    \regs[3][15]_i_1 
       (.I0(we_IBUF),
        .I1(waddr_IBUF[1]),
        .I2(waddr_IBUF[0]),
        .O(\regs[3][15]_i_1_n_0 ));
  FDRE \regs_reg[0][0] 
       (.C(clk_IBUF_BUFG),
        .CE(regs),
        .D(wdata_IBUF[0]),
        .Q(\regs_reg[0] [0]),
        .R(rst_IBUF));
  FDRE \regs_reg[0][10] 
       (.C(clk_IBUF_BUFG),
        .CE(regs),
        .D(wdata_IBUF[10]),
        .Q(\regs_reg[0] [10]),
        .R(rst_IBUF));
  FDRE \regs_reg[0][11] 
       (.C(clk_IBUF_BUFG),
        .CE(regs),
        .D(wdata_IBUF[11]),
        .Q(\regs_reg[0] [11]),
        .R(rst_IBUF));
  FDRE \regs_reg[0][12] 
       (.C(clk_IBUF_BUFG),
        .CE(regs),
        .D(wdata_IBUF[12]),
        .Q(\regs_reg[0] [12]),
        .R(rst_IBUF));
  FDRE \regs_reg[0][13] 
       (.C(clk_IBUF_BUFG),
        .CE(regs),
        .D(wdata_IBUF[13]),
        .Q(\regs_reg[0] [13]),
        .R(rst_IBUF));
  FDRE \regs_reg[0][14] 
       (.C(clk_IBUF_BUFG),
        .CE(regs),
        .D(wdata_IBUF[14]),
        .Q(\regs_reg[0] [14]),
        .R(rst_IBUF));
  FDRE \regs_reg[0][15] 
       (.C(clk_IBUF_BUFG),
        .CE(regs),
        .D(wdata_IBUF[15]),
        .Q(\regs_reg[0] [15]),
        .R(rst_IBUF));
  FDRE \regs_reg[0][1] 
       (.C(clk_IBUF_BUFG),
        .CE(regs),
        .D(wdata_IBUF[1]),
        .Q(\regs_reg[0] [1]),
        .R(rst_IBUF));
  FDRE \regs_reg[0][2] 
       (.C(clk_IBUF_BUFG),
        .CE(regs),
        .D(wdata_IBUF[2]),
        .Q(\regs_reg[0] [2]),
        .R(rst_IBUF));
  FDRE \regs_reg[0][3] 
       (.C(clk_IBUF_BUFG),
        .CE(regs),
        .D(wdata_IBUF[3]),
        .Q(\regs_reg[0] [3]),
        .R(rst_IBUF));
  FDRE \regs_reg[0][4] 
       (.C(clk_IBUF_BUFG),
        .CE(regs),
        .D(wdata_IBUF[4]),
        .Q(\regs_reg[0] [4]),
        .R(rst_IBUF));
  FDRE \regs_reg[0][5] 
       (.C(clk_IBUF_BUFG),
        .CE(regs),
        .D(wdata_IBUF[5]),
        .Q(\regs_reg[0] [5]),
        .R(rst_IBUF));
  FDRE \regs_reg[0][6] 
       (.C(clk_IBUF_BUFG),
        .CE(regs),
        .D(wdata_IBUF[6]),
        .Q(\regs_reg[0] [6]),
        .R(rst_IBUF));
  FDRE \regs_reg[0][7] 
       (.C(clk_IBUF_BUFG),
        .CE(regs),
        .D(wdata_IBUF[7]),
        .Q(\regs_reg[0] [7]),
        .R(rst_IBUF));
  FDRE \regs_reg[0][8] 
       (.C(clk_IBUF_BUFG),
        .CE(regs),
        .D(wdata_IBUF[8]),
        .Q(\regs_reg[0] [8]),
        .R(rst_IBUF));
  FDRE \regs_reg[0][9] 
       (.C(clk_IBUF_BUFG),
        .CE(regs),
        .D(wdata_IBUF[9]),
        .Q(\regs_reg[0] [9]),
        .R(rst_IBUF));
  FDRE \regs_reg[1][0] 
       (.C(clk_IBUF_BUFG),
        .CE(\regs[1][15]_i_1_n_0 ),
        .D(wdata_IBUF[0]),
        .Q(\regs_reg[1] [0]),
        .R(rst_IBUF));
  FDRE \regs_reg[1][10] 
       (.C(clk_IBUF_BUFG),
        .CE(\regs[1][15]_i_1_n_0 ),
        .D(wdata_IBUF[10]),
        .Q(\regs_reg[1] [10]),
        .R(rst_IBUF));
  FDRE \regs_reg[1][11] 
       (.C(clk_IBUF_BUFG),
        .CE(\regs[1][15]_i_1_n_0 ),
        .D(wdata_IBUF[11]),
        .Q(\regs_reg[1] [11]),
        .R(rst_IBUF));
  FDRE \regs_reg[1][12] 
       (.C(clk_IBUF_BUFG),
        .CE(\regs[1][15]_i_1_n_0 ),
        .D(wdata_IBUF[12]),
        .Q(\regs_reg[1] [12]),
        .R(rst_IBUF));
  FDRE \regs_reg[1][13] 
       (.C(clk_IBUF_BUFG),
        .CE(\regs[1][15]_i_1_n_0 ),
        .D(wdata_IBUF[13]),
        .Q(\regs_reg[1] [13]),
        .R(rst_IBUF));
  FDRE \regs_reg[1][14] 
       (.C(clk_IBUF_BUFG),
        .CE(\regs[1][15]_i_1_n_0 ),
        .D(wdata_IBUF[14]),
        .Q(\regs_reg[1] [14]),
        .R(rst_IBUF));
  FDRE \regs_reg[1][15] 
       (.C(clk_IBUF_BUFG),
        .CE(\regs[1][15]_i_1_n_0 ),
        .D(wdata_IBUF[15]),
        .Q(\regs_reg[1] [15]),
        .R(rst_IBUF));
  FDRE \regs_reg[1][1] 
       (.C(clk_IBUF_BUFG),
        .CE(\regs[1][15]_i_1_n_0 ),
        .D(wdata_IBUF[1]),
        .Q(\regs_reg[1] [1]),
        .R(rst_IBUF));
  FDRE \regs_reg[1][2] 
       (.C(clk_IBUF_BUFG),
        .CE(\regs[1][15]_i_1_n_0 ),
        .D(wdata_IBUF[2]),
        .Q(\regs_reg[1] [2]),
        .R(rst_IBUF));
  FDRE \regs_reg[1][3] 
       (.C(clk_IBUF_BUFG),
        .CE(\regs[1][15]_i_1_n_0 ),
        .D(wdata_IBUF[3]),
        .Q(\regs_reg[1] [3]),
        .R(rst_IBUF));
  FDRE \regs_reg[1][4] 
       (.C(clk_IBUF_BUFG),
        .CE(\regs[1][15]_i_1_n_0 ),
        .D(wdata_IBUF[4]),
        .Q(\regs_reg[1] [4]),
        .R(rst_IBUF));
  FDRE \regs_reg[1][5] 
       (.C(clk_IBUF_BUFG),
        .CE(\regs[1][15]_i_1_n_0 ),
        .D(wdata_IBUF[5]),
        .Q(\regs_reg[1] [5]),
        .R(rst_IBUF));
  FDRE \regs_reg[1][6] 
       (.C(clk_IBUF_BUFG),
        .CE(\regs[1][15]_i_1_n_0 ),
        .D(wdata_IBUF[6]),
        .Q(\regs_reg[1] [6]),
        .R(rst_IBUF));
  FDRE \regs_reg[1][7] 
       (.C(clk_IBUF_BUFG),
        .CE(\regs[1][15]_i_1_n_0 ),
        .D(wdata_IBUF[7]),
        .Q(\regs_reg[1] [7]),
        .R(rst_IBUF));
  FDRE \regs_reg[1][8] 
       (.C(clk_IBUF_BUFG),
        .CE(\regs[1][15]_i_1_n_0 ),
        .D(wdata_IBUF[8]),
        .Q(\regs_reg[1] [8]),
        .R(rst_IBUF));
  FDRE \regs_reg[1][9] 
       (.C(clk_IBUF_BUFG),
        .CE(\regs[1][15]_i_1_n_0 ),
        .D(wdata_IBUF[9]),
        .Q(\regs_reg[1] [9]),
        .R(rst_IBUF));
  FDRE \regs_reg[2][0] 
       (.C(clk_IBUF_BUFG),
        .CE(\regs[2][15]_i_1_n_0 ),
        .D(wdata_IBUF[0]),
        .Q(\regs_reg[2] [0]),
        .R(rst_IBUF));
  FDRE \regs_reg[2][10] 
       (.C(clk_IBUF_BUFG),
        .CE(\regs[2][15]_i_1_n_0 ),
        .D(wdata_IBUF[10]),
        .Q(\regs_reg[2] [10]),
        .R(rst_IBUF));
  FDRE \regs_reg[2][11] 
       (.C(clk_IBUF_BUFG),
        .CE(\regs[2][15]_i_1_n_0 ),
        .D(wdata_IBUF[11]),
        .Q(\regs_reg[2] [11]),
        .R(rst_IBUF));
  FDRE \regs_reg[2][12] 
       (.C(clk_IBUF_BUFG),
        .CE(\regs[2][15]_i_1_n_0 ),
        .D(wdata_IBUF[12]),
        .Q(\regs_reg[2] [12]),
        .R(rst_IBUF));
  FDRE \regs_reg[2][13] 
       (.C(clk_IBUF_BUFG),
        .CE(\regs[2][15]_i_1_n_0 ),
        .D(wdata_IBUF[13]),
        .Q(\regs_reg[2] [13]),
        .R(rst_IBUF));
  FDRE \regs_reg[2][14] 
       (.C(clk_IBUF_BUFG),
        .CE(\regs[2][15]_i_1_n_0 ),
        .D(wdata_IBUF[14]),
        .Q(\regs_reg[2] [14]),
        .R(rst_IBUF));
  FDRE \regs_reg[2][15] 
       (.C(clk_IBUF_BUFG),
        .CE(\regs[2][15]_i_1_n_0 ),
        .D(wdata_IBUF[15]),
        .Q(\regs_reg[2] [15]),
        .R(rst_IBUF));
  FDRE \regs_reg[2][1] 
       (.C(clk_IBUF_BUFG),
        .CE(\regs[2][15]_i_1_n_0 ),
        .D(wdata_IBUF[1]),
        .Q(\regs_reg[2] [1]),
        .R(rst_IBUF));
  FDRE \regs_reg[2][2] 
       (.C(clk_IBUF_BUFG),
        .CE(\regs[2][15]_i_1_n_0 ),
        .D(wdata_IBUF[2]),
        .Q(\regs_reg[2] [2]),
        .R(rst_IBUF));
  FDRE \regs_reg[2][3] 
       (.C(clk_IBUF_BUFG),
        .CE(\regs[2][15]_i_1_n_0 ),
        .D(wdata_IBUF[3]),
        .Q(\regs_reg[2] [3]),
        .R(rst_IBUF));
  FDRE \regs_reg[2][4] 
       (.C(clk_IBUF_BUFG),
        .CE(\regs[2][15]_i_1_n_0 ),
        .D(wdata_IBUF[4]),
        .Q(\regs_reg[2] [4]),
        .R(rst_IBUF));
  FDRE \regs_reg[2][5] 
       (.C(clk_IBUF_BUFG),
        .CE(\regs[2][15]_i_1_n_0 ),
        .D(wdata_IBUF[5]),
        .Q(\regs_reg[2] [5]),
        .R(rst_IBUF));
  FDRE \regs_reg[2][6] 
       (.C(clk_IBUF_BUFG),
        .CE(\regs[2][15]_i_1_n_0 ),
        .D(wdata_IBUF[6]),
        .Q(\regs_reg[2] [6]),
        .R(rst_IBUF));
  FDRE \regs_reg[2][7] 
       (.C(clk_IBUF_BUFG),
        .CE(\regs[2][15]_i_1_n_0 ),
        .D(wdata_IBUF[7]),
        .Q(\regs_reg[2] [7]),
        .R(rst_IBUF));
  FDRE \regs_reg[2][8] 
       (.C(clk_IBUF_BUFG),
        .CE(\regs[2][15]_i_1_n_0 ),
        .D(wdata_IBUF[8]),
        .Q(\regs_reg[2] [8]),
        .R(rst_IBUF));
  FDRE \regs_reg[2][9] 
       (.C(clk_IBUF_BUFG),
        .CE(\regs[2][15]_i_1_n_0 ),
        .D(wdata_IBUF[9]),
        .Q(\regs_reg[2] [9]),
        .R(rst_IBUF));
  FDRE \regs_reg[3][0] 
       (.C(clk_IBUF_BUFG),
        .CE(\regs[3][15]_i_1_n_0 ),
        .D(wdata_IBUF[0]),
        .Q(\regs_reg[3] [0]),
        .R(rst_IBUF));
  FDRE \regs_reg[3][10] 
       (.C(clk_IBUF_BUFG),
        .CE(\regs[3][15]_i_1_n_0 ),
        .D(wdata_IBUF[10]),
        .Q(\regs_reg[3] [10]),
        .R(rst_IBUF));
  FDRE \regs_reg[3][11] 
       (.C(clk_IBUF_BUFG),
        .CE(\regs[3][15]_i_1_n_0 ),
        .D(wdata_IBUF[11]),
        .Q(\regs_reg[3] [11]),
        .R(rst_IBUF));
  FDRE \regs_reg[3][12] 
       (.C(clk_IBUF_BUFG),
        .CE(\regs[3][15]_i_1_n_0 ),
        .D(wdata_IBUF[12]),
        .Q(\regs_reg[3] [12]),
        .R(rst_IBUF));
  FDRE \regs_reg[3][13] 
       (.C(clk_IBUF_BUFG),
        .CE(\regs[3][15]_i_1_n_0 ),
        .D(wdata_IBUF[13]),
        .Q(\regs_reg[3] [13]),
        .R(rst_IBUF));
  FDRE \regs_reg[3][14] 
       (.C(clk_IBUF_BUFG),
        .CE(\regs[3][15]_i_1_n_0 ),
        .D(wdata_IBUF[14]),
        .Q(\regs_reg[3] [14]),
        .R(rst_IBUF));
  FDRE \regs_reg[3][15] 
       (.C(clk_IBUF_BUFG),
        .CE(\regs[3][15]_i_1_n_0 ),
        .D(wdata_IBUF[15]),
        .Q(\regs_reg[3] [15]),
        .R(rst_IBUF));
  FDRE \regs_reg[3][1] 
       (.C(clk_IBUF_BUFG),
        .CE(\regs[3][15]_i_1_n_0 ),
        .D(wdata_IBUF[1]),
        .Q(\regs_reg[3] [1]),
        .R(rst_IBUF));
  FDRE \regs_reg[3][2] 
       (.C(clk_IBUF_BUFG),
        .CE(\regs[3][15]_i_1_n_0 ),
        .D(wdata_IBUF[2]),
        .Q(\regs_reg[3] [2]),
        .R(rst_IBUF));
  FDRE \regs_reg[3][3] 
       (.C(clk_IBUF_BUFG),
        .CE(\regs[3][15]_i_1_n_0 ),
        .D(wdata_IBUF[3]),
        .Q(\regs_reg[3] [3]),
        .R(rst_IBUF));
  FDRE \regs_reg[3][4] 
       (.C(clk_IBUF_BUFG),
        .CE(\regs[3][15]_i_1_n_0 ),
        .D(wdata_IBUF[4]),
        .Q(\regs_reg[3] [4]),
        .R(rst_IBUF));
  FDRE \regs_reg[3][5] 
       (.C(clk_IBUF_BUFG),
        .CE(\regs[3][15]_i_1_n_0 ),
        .D(wdata_IBUF[5]),
        .Q(\regs_reg[3] [5]),
        .R(rst_IBUF));
  FDRE \regs_reg[3][6] 
       (.C(clk_IBUF_BUFG),
        .CE(\regs[3][15]_i_1_n_0 ),
        .D(wdata_IBUF[6]),
        .Q(\regs_reg[3] [6]),
        .R(rst_IBUF));
  FDRE \regs_reg[3][7] 
       (.C(clk_IBUF_BUFG),
        .CE(\regs[3][15]_i_1_n_0 ),
        .D(wdata_IBUF[7]),
        .Q(\regs_reg[3] [7]),
        .R(rst_IBUF));
  FDRE \regs_reg[3][8] 
       (.C(clk_IBUF_BUFG),
        .CE(\regs[3][15]_i_1_n_0 ),
        .D(wdata_IBUF[8]),
        .Q(\regs_reg[3] [8]),
        .R(rst_IBUF));
  FDRE \regs_reg[3][9] 
       (.C(clk_IBUF_BUFG),
        .CE(\regs[3][15]_i_1_n_0 ),
        .D(wdata_IBUF[9]),
        .Q(\regs_reg[3] [9]),
        .R(rst_IBUF));
  IBUF rst_IBUF_inst
       (.I(rst),
        .O(rst_IBUF));
  IBUF \waddr_IBUF[0]_inst 
       (.I(waddr[0]),
        .O(waddr_IBUF[0]));
  IBUF \waddr_IBUF[1]_inst 
       (.I(waddr[1]),
        .O(waddr_IBUF[1]));
  IBUF \wdata_IBUF[0]_inst 
       (.I(wdata[0]),
        .O(wdata_IBUF[0]));
  IBUF \wdata_IBUF[10]_inst 
       (.I(wdata[10]),
        .O(wdata_IBUF[10]));
  IBUF \wdata_IBUF[11]_inst 
       (.I(wdata[11]),
        .O(wdata_IBUF[11]));
  IBUF \wdata_IBUF[12]_inst 
       (.I(wdata[12]),
        .O(wdata_IBUF[12]));
  IBUF \wdata_IBUF[13]_inst 
       (.I(wdata[13]),
        .O(wdata_IBUF[13]));
  IBUF \wdata_IBUF[14]_inst 
       (.I(wdata[14]),
        .O(wdata_IBUF[14]));
  IBUF \wdata_IBUF[15]_inst 
       (.I(wdata[15]),
        .O(wdata_IBUF[15]));
  IBUF \wdata_IBUF[1]_inst 
       (.I(wdata[1]),
        .O(wdata_IBUF[1]));
  IBUF \wdata_IBUF[2]_inst 
       (.I(wdata[2]),
        .O(wdata_IBUF[2]));
  IBUF \wdata_IBUF[3]_inst 
       (.I(wdata[3]),
        .O(wdata_IBUF[3]));
  IBUF \wdata_IBUF[4]_inst 
       (.I(wdata[4]),
        .O(wdata_IBUF[4]));
  IBUF \wdata_IBUF[5]_inst 
       (.I(wdata[5]),
        .O(wdata_IBUF[5]));
  IBUF \wdata_IBUF[6]_inst 
       (.I(wdata[6]),
        .O(wdata_IBUF[6]));
  IBUF \wdata_IBUF[7]_inst 
       (.I(wdata[7]),
        .O(wdata_IBUF[7]));
  IBUF \wdata_IBUF[8]_inst 
       (.I(wdata[8]),
        .O(wdata_IBUF[8]));
  IBUF \wdata_IBUF[9]_inst 
       (.I(wdata[9]),
        .O(wdata_IBUF[9]));
  IBUF we_IBUF_inst
       (.I(we),
        .O(we_IBUF));
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
