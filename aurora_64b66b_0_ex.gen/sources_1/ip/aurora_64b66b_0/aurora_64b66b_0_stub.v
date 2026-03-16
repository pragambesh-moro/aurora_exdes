// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2022.2 (win64) Build 3671981 Fri Oct 14 05:00:03 MDT 2022
// Date        : Fri Mar 13 03:48:37 2026
// Host        : LAPTOP-CH0R4GF2 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               c:/Research/aurora_64b66b_0_ex/aurora_64b66b_0_ex.gen/sources_1/ip/aurora_64b66b_0/aurora_64b66b_0_stub.v
// Design      : aurora_64b66b_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xczu48dr-ffvg1517-2-e
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "aurora_64b66b_v12_0_10, Coregen v14.3_ip3, Number of lanes = 4, Line rate is double10.3125Gbps, Reference Clock is double156.25MHz, Interface is Framing, Flow Control is None and is operating in DUPLEX configuration" *)
module aurora_64b66b_0(s_axi_tx_tdata, s_axi_tx_tlast, 
  s_axi_tx_tkeep, s_axi_tx_tvalid, s_axi_tx_tready, m_axi_rx_tdata, m_axi_rx_tlast, 
  m_axi_rx_tkeep, m_axi_rx_tvalid, rxp, rxn, txp, txn, refclk1_in, hard_err, soft_err, channel_up, 
  lane_up, mmcm_not_locked, user_clk, sync_clk, reset_pb, gt_rxcdrovrden_in, power_down, 
  loopback, pma_init, gt_pll_lock, gt_qpllclk_quad1_in, gt_qpllrefclk_quad1_in, 
  gt_qplllock_quad1_in, gt_qpllrefclklost_quad1, gt_to_common_qpllreset_out, init_clk, 
  link_reset_out, gt_powergood, sys_reset_out, bufg_gt_clr_out, tx_out_clk)
/* synthesis syn_black_box black_box_pad_pin="s_axi_tx_tdata[0:255],s_axi_tx_tlast,s_axi_tx_tkeep[0:31],s_axi_tx_tvalid,s_axi_tx_tready,m_axi_rx_tdata[0:255],m_axi_rx_tlast,m_axi_rx_tkeep[0:31],m_axi_rx_tvalid,rxp[0:3],rxn[0:3],txp[0:3],txn[0:3],refclk1_in,hard_err,soft_err,channel_up,lane_up[0:3],mmcm_not_locked,user_clk,sync_clk,reset_pb,gt_rxcdrovrden_in,power_down,loopback[2:0],pma_init,gt_pll_lock,gt_qpllclk_quad1_in,gt_qpllrefclk_quad1_in,gt_qplllock_quad1_in,gt_qpllrefclklost_quad1,gt_to_common_qpllreset_out,init_clk,link_reset_out,gt_powergood[3:0],sys_reset_out,bufg_gt_clr_out,tx_out_clk" */;
  input [0:255]s_axi_tx_tdata;
  input s_axi_tx_tlast;
  input [0:31]s_axi_tx_tkeep;
  input s_axi_tx_tvalid;
  output s_axi_tx_tready;
  output [0:255]m_axi_rx_tdata;
  output m_axi_rx_tlast;
  output [0:31]m_axi_rx_tkeep;
  output m_axi_rx_tvalid;
  input [0:3]rxp;
  input [0:3]rxn;
  output [0:3]txp;
  output [0:3]txn;
  input refclk1_in;
  output hard_err;
  output soft_err;
  output channel_up;
  output [0:3]lane_up;
  input mmcm_not_locked;
  input user_clk;
  input sync_clk;
  input reset_pb;
  input gt_rxcdrovrden_in;
  input power_down;
  input [2:0]loopback;
  input pma_init;
  output gt_pll_lock;
  input gt_qpllclk_quad1_in;
  input gt_qpllrefclk_quad1_in;
  input gt_qplllock_quad1_in;
  input gt_qpllrefclklost_quad1;
  output gt_to_common_qpllreset_out;
  input init_clk;
  output link_reset_out;
  output [3:0]gt_powergood;
  output sys_reset_out;
  output bufg_gt_clr_out;
  output tx_out_clk;
endmodule
