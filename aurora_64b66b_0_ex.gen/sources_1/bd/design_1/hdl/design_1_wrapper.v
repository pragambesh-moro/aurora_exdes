//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2022.2 (win64) Build 3671981 Fri Oct 14 05:00:03 MDT 2022
//Date        : Tue Mar 17 01:11:34 2026
//Host        : LAPTOP-CH0R4GF2 running 64-bit major release  (build 9200)
//Command     : generate_target design_1_wrapper.bd
//Design      : design_1_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module design_1_wrapper
   (ps_gpio_tx_data0_tri_o,
    ps_gpio_tx_data1_tri_o,
    ps_gpio_tx_data2_tri_o,
    ps_gpio_tx_data3_tri_o,
    ps_gpio_tx_data4_tri_o,
    ps_gpio_tx_data5_tri_o,
    ps_gpio_tx_data6_tri_o,
    ps_gpio_tx_data7_tri_o,
    ps_gpio_tx_tstatus_tri_i,
    ps_gpio_tx_tvalid_tri_o);
  output [31:0]ps_gpio_tx_data0_tri_o;
  output [31:0]ps_gpio_tx_data1_tri_o;
  output [31:0]ps_gpio_tx_data2_tri_o;
  output [31:0]ps_gpio_tx_data3_tri_o;
  output [31:0]ps_gpio_tx_data4_tri_o;
  output [31:0]ps_gpio_tx_data5_tri_o;
  output [31:0]ps_gpio_tx_data6_tri_o;
  output [31:0]ps_gpio_tx_data7_tri_o;
  input [1:0]ps_gpio_tx_tstatus_tri_i;
  output [0:0]ps_gpio_tx_tvalid_tri_o;

  wire [31:0]ps_gpio_tx_data0_tri_o;
  wire [31:0]ps_gpio_tx_data1_tri_o;
  wire [31:0]ps_gpio_tx_data2_tri_o;
  wire [31:0]ps_gpio_tx_data3_tri_o;
  wire [31:0]ps_gpio_tx_data4_tri_o;
  wire [31:0]ps_gpio_tx_data5_tri_o;
  wire [31:0]ps_gpio_tx_data6_tri_o;
  wire [31:0]ps_gpio_tx_data7_tri_o;
  wire [1:0]ps_gpio_tx_tstatus_tri_i;
  wire [0:0]ps_gpio_tx_tvalid_tri_o;

  design_1 design_1_i
       (.ps_gpio_tx_data0_tri_o(ps_gpio_tx_data0_tri_o),
        .ps_gpio_tx_data1_tri_o(ps_gpio_tx_data1_tri_o),
        .ps_gpio_tx_data2_tri_o(ps_gpio_tx_data2_tri_o),
        .ps_gpio_tx_data3_tri_o(ps_gpio_tx_data3_tri_o),
        .ps_gpio_tx_data4_tri_o(ps_gpio_tx_data4_tri_o),
        .ps_gpio_tx_data5_tri_o(ps_gpio_tx_data5_tri_o),
        .ps_gpio_tx_data6_tri_o(ps_gpio_tx_data6_tri_o),
        .ps_gpio_tx_data7_tri_o(ps_gpio_tx_data7_tri_o),
        .ps_gpio_tx_tstatus_tri_i(ps_gpio_tx_tstatus_tri_i),
        .ps_gpio_tx_tvalid_tri_o(ps_gpio_tx_tvalid_tri_o));
endmodule
