///////////////////////////////////////////////////////////////////////////////
//
// Project:  Aurora 64B/66B
// Company:  Xilinx
//
//
// (c) Copyright 2008 - 2009 Xilinx, Inc. All rights reserved.
//
///////////////////////////////////////////////////////////////////////////////
//
//  EXAMPLE_DESIGN
//
//  Description:  This module instantiates 4 lane Aurora Module.
//                Used to exhibit functionality in hardware using the example design
//                The User Interface is connected to Data Generator and Checker.
///////////////////////////////////////////////////////////////////////////////

`timescale 1 ns / 10 ps

(* core_generation_info = "aurora_64b66b_0,aurora_64b66b_v12_0_10,{c_aurora_lanes=4,c_column_used=left,c_gt_clock_1=GTYQ0,c_gt_clock_2=None,c_gt_loc_1=1,c_gt_loc_10=X,c_gt_loc_11=X,c_gt_loc_12=X,c_gt_loc_13=X,c_gt_loc_14=X,c_gt_loc_15=X,c_gt_loc_16=X,c_gt_loc_17=X,c_gt_loc_18=X,c_gt_loc_19=X,c_gt_loc_2=2,c_gt_loc_20=X,c_gt_loc_21=X,c_gt_loc_22=X,c_gt_loc_23=X,c_gt_loc_24=X,c_gt_loc_25=X,c_gt_loc_26=X,c_gt_loc_27=X,c_gt_loc_28=X,c_gt_loc_29=X,c_gt_loc_3=3,c_gt_loc_30=X,c_gt_loc_31=X,c_gt_loc_32=X,c_gt_loc_33=X,c_gt_loc_34=X,c_gt_loc_35=X,c_gt_loc_36=X,c_gt_loc_37=X,c_gt_loc_38=X,c_gt_loc_39=X,c_gt_loc_4=4,c_gt_loc_40=X,c_gt_loc_41=X,c_gt_loc_42=X,c_gt_loc_43=X,c_gt_loc_44=X,c_gt_loc_45=X,c_gt_loc_46=X,c_gt_loc_47=X,c_gt_loc_48=X,c_gt_loc_5=X,c_gt_loc_6=X,c_gt_loc_7=X,c_gt_loc_8=X,c_gt_loc_9=X,c_lane_width=4,c_line_rate=10.3125,c_gt_type=GTYE4,c_qpll=true,c_nfc=false,c_nfc_mode=IMM,c_refclk_frequency=156.25,c_simplex=false,c_simplex_mode=TX,c_stream=false,c_ufc=false,c_user_k=false,flow_mode=None,interface_mode=Framing,dataflow_config=Duplex}" *)
(* DowngradeIPIdentifiedWarnings="yes" *)
module aurora_64b66b_0_exdes  #
(
    parameter   USE_CORE_TRAFFIC   = 1,
    parameter   USR_CLK_PCOUNT     = 9'd255,
    parameter   EXAMPLE_SIMULATION = 0
     //pragma translate_off
       | 1
     //pragma translate_on
     ,
     parameter   USE_LABTOOLS      = 0
)
(
    // System Interface
    INIT_CLK_P,
    INIT_CLK_N,

    // GT Reference Clock Interface
    GTYQ0_P,
    GTYQ0_N,

    // GT Serial I/O
    RXP,
    RXN,
    TXP,
    TXN,

    // Simple PS->PL single-record mailbox interface
    ps_pl_data_i,
    ps_pl_valid_i,
    ps_pl_ready_o,
    ps_pl_busy_o,
    
    user_clk_o
);

`define DLY #1

//***********************************Port Declarations*******************************

    input              INIT_CLK_P;
    input              INIT_CLK_N;
    output             user_clk_o;

    // GTX Reference Clock Interface
    input              GTYQ0_P;
    input              GTYQ0_N;

    // GTX Serial I/O
    input   [0:3]      RXP;
    input   [0:3]      RXN;

    output  [0:3]      TXP;
    output  [0:3]      TXN;

    // Simple PS->PL single-record mailbox interface
    input   [0:255]    ps_pl_data_i;
    input              ps_pl_valid_i;
    output             ps_pl_ready_o;
    output             ps_pl_busy_o;

//************************Internal Register Declarations*****************************

    reg                hard_err_r;
    reg                soft_err_r;
(* KEEP = "TRUE" *) reg [0:7] data_err_count_r;

    reg [0:3]          lane_up_r;
    reg                channel_up_r;

//********************************Wire Declarations**********************************

    wire [280:0]       tied_to_ground_vec_i;
    wire               INIT_CLK_IN;

    wire               RESET;
    wire               PMA_INIT;

    assign RESET    = 1'b0;
    assign PMA_INIT = 1'b0;

    // TX Interface
    wire [0:255]       tx_tdata_i;
    wire               tx_tvalid_i;
    wire [0:31]        tx_tkeep_i;
    wire               tx_tlast_i;
    wire               tx_tready_i;

    // RX Interface
    wire [0:255]       rx_tdata_i;
    wire               rx_tvalid_i;
    wire [0:31]        rx_tkeep_i;
    wire               rx_tlast_i;

    // legacy example signals (unused but kept to minimize change risk)
    wire [0:255]       tx_d_i;
    wire               tx_src_rdy_n_i;
    wire [0:4]         tx_rem_i;
    wire               tx_sof_n_i;
    wire               tx_eof_n_i;
    wire               tx_dst_rdy_n_i;

    wire [0:255]       rx_d_i;
    wire               rx_src_rdy_n_i;
    wire [0:4]         rx_rem_i;
    wire               rx_sof_n_i;
    wire               rx_eof_n_i;

    // Error Detection Interface
    wire               hard_err_i;
    wire               soft_err_i;

    // Status
    wire               channel_up_i;
    wire [0:3]         lane_up_i;

    // System Interface
    wire               reset_i;
    reg                reset_r1;
    reg                reset_r2;
    reg                reset_r3;
    wire               gt_rxcdrovrden_i;
    wire               power_down_i;
    wire [2:0]         loopback_i;
    wire               gt_pll_lock_i;
    wire               fsm_resetdone_i;
    wire               tx_out_clk_i;
    wire               bufg_gt_clr_out;

    // Error signals from the frame checker
    wire [0:7]         data_err_count_o;
    wire               data_err_init_clk_i;

    // clocks
    wire               user_clk_i;
    wire               sync_clk_i;
    wire               INIT_CLK_i  /* synthesis syn_keep = 1 */;

    wire               drp_clk_i = INIT_CLK_i;
    wire               DRP_CLK_i;
    wire [9:0]         drpaddr_in_i;
    wire [15:0]        drpdi_in_i;
    wire [15:0]        drpdo_out_i;
    wire               drprdy_out_i;
    wire               drpen_in_i;
    wire               drpwe_in_i;
    wire [9:0]         gt0_drpaddr_i;
    wire [15:0]        gt0_drpdi_i;
    wire               gt0_drpen_i;
    wire               gt0_drpwe_i;
    wire [15:0]        gt0_drpdo_i;
    wire [9:0]         drpaddr_in_lane1_i;
    wire [15:0]        drpdi_in_lane1_i;
    wire [15:0]        drpdo_out_lane1_i;
    wire               drprdy_out_lane1_i;
    wire               drpen_in_lane1_i;
    wire               drpwe_in_lane1_i;
    wire [9:0]         gt1_drpaddr_i;
    wire [15:0]        gt1_drpdi_i;
    wire               gt1_drpen_i;
    wire               gt1_drpwe_i;
    wire [15:0]        gt1_drpdo_i;
    wire [9:0]         drpaddr_in_lane2_i;
    wire [15:0]        drpdi_in_lane2_i;
    wire [15:0]        drpdo_out_lane2_i;
    wire               drprdy_out_lane2_i;
    wire               drpen_in_lane2_i;
    wire               drpwe_in_lane2_i;
    wire [9:0]         gt2_drpaddr_i;
    wire [15:0]        gt2_drpdi_i;
    wire               gt2_drpen_i;
    wire               gt2_drpwe_i;
    wire [15:0]        gt2_drpdo_i;
    wire [9:0]         drpaddr_in_lane3_i;
    wire [15:0]        drpdi_in_lane3_i;
    wire [15:0]        drpdo_out_lane3_i;
    wire               drprdy_out_lane3_i;
    wire               drpen_in_lane3_i;
    wire               drpwe_in_lane3_i;
    wire [9:0]         gt3_drpaddr_i;
    wire [15:0]        gt3_drpdi_i;
    wire               gt3_drpen_i;
    wire               gt3_drpwe_i;
    wire [15:0]        gt3_drpdo_i;
    wire               link_reset_i;
    wire               sysreset_from_vio_i = 1'b0;
    wire               gtreset_from_vio_i = 1'b0;
    wire               rx_cdrovrden_i = 1'b0;
    wire               gt_reset_i;
    wire               gt_reset_i_tmp;
    wire               gt_reset_i_tmp2;
    wire               sysreset_from_vio_r3;
    wire               sysreset_from_vio_r3_initclkdomain;
    wire               gtreset_from_vio_r3;
    wire               tied_to_ground_i;
    wire               tied_to_vcc_i;
    wire               gt_reset_i_eff;
    wire               system_reset_i;
    wire               pll_not_locked_i;

    reg                pma_init_from_fsm = 0;
    reg                pma_init_from_fsm_r1 = 0;
    reg                lane_up_vio_usrclk_r1 = 0;
    reg                data_err_count_o_r1 = 0;
(* mark_debug = "TRUE" *) reg rx_tvalid_r = 1'd0;

(* mark_debug = "TRUE" *) reg [8:0] usr_clk_counter = 9'd0;
(* mark_debug = "TRUE" *) wire usr_clk_count_done;

    wire               reset2FrameGen;
    wire               reset2FrameCheck;

    // ROM pattern source
    reg  [2:0]         tx_pat_idx_r = 3'd0;
    reg  [0:255]       tx_pattern_i;

    // PS-fed record registers (real single-entry mailbox path)
    reg  [0:255]       ps_data_r   = 256'd0;
    reg                ps_valid_r  = 1'b0;
    wire               ps_ready_i;

    // Synchronize PS valid into user_clk_i domain
    reg                ps_pl_valid_meta_r  = 1'b0;
    reg                ps_pl_valid_sync_r  = 1'b0;
    reg                ps_pl_valid_sync_d1 = 1'b0;
    wire               ps_pl_valid_rise_i;

    // Status back toward PS
    reg                ps_pl_busy_r = 1'b0;

    // Source select: 0 = ROM pattern, 1 = PS-fed record path
    reg                source_select_r = 1'b1;

    wire [0:255]       tx_mux_data_i;
    wire               tx_mux_valid_i;
    wire               tx_mux_last_i;

//*********************************Main Body of Code**********************************

    assign reset2FrameGen   = reset_r1 | !channel_up_i;
    assign reset2FrameCheck = reset_r2 | !channel_up_i;
    
    assign user_clk_o = user_clk_i;
    
    assign ps_pl_valid_rise_i = ps_pl_valid_sync_r & ~ps_pl_valid_sync_d1;

    assign ps_pl_ready_o = (source_select_r == 1'b1) && !ps_pl_busy_r && !ps_valid_r;
    assign ps_pl_busy_o  = (source_select_r == 1'b1) && (ps_pl_busy_r || ps_valid_r);

    always @(posedge user_clk_i)
        reset_r1 <= `DLY system_reset_i;

    always @(posedge user_clk_i)
        reset_r2 <= `DLY system_reset_i;

    always @(posedge user_clk_i)
        reset_r3 <= `DLY reset_i;

    IBUFDS IBUFDS_INIT_CLK
    (
        .I  (INIT_CLK_P),
        .IB (INIT_CLK_N),
        .O  (INIT_CLK_IN)
    );

    BUFG initclk_bufg_i
    (
        .I  (INIT_CLK_IN),
        .O  (INIT_CLK_i)
    );

    always @(posedge user_clk_i)
    begin
        hard_err_r       <= hard_err_i;
        soft_err_r       <= soft_err_i;
        lane_up_r        <= lane_up_i;
        channel_up_r     <= channel_up_i;
        data_err_count_r <= data_err_count_o;
    end

    assign power_down_i         = 1'b0;
    assign tied_to_ground_i     = 1'b0;
    assign tied_to_ground_vec_i = 281'd0;
    assign tied_to_vcc_i        = 1'b1;

    reg [127:0]       pma_init_stage = {128{1'b1}};
    reg [23:0]        pma_init_pulse_width_cnt = 24'h0;
    reg               pma_init_assertion = 1'b0;
    reg               pma_init_assertion_r;
    reg               gt_reset_i_delayed_r1;
    reg               gt_reset_i_delayed_r2;
    wire              gt_reset_i_delayed;

    generate
        always @(posedge INIT_CLK_i)
        begin
            pma_init_stage[127:0] <= {pma_init_stage[126:0], gt_reset_i_tmp};
        end

        assign gt_reset_i_delayed = pma_init_stage[127];

        always @(posedge INIT_CLK_i)
        begin
            gt_reset_i_delayed_r1 <= gt_reset_i_delayed;
            gt_reset_i_delayed_r2 <= gt_reset_i_delayed_r1;
            pma_init_assertion_r  <= pma_init_assertion;
            if (~gt_reset_i_delayed_r2 & gt_reset_i_delayed_r1 & ~pma_init_assertion & (pma_init_pulse_width_cnt != 24'hFFFFFF))
                pma_init_assertion <= 1'b1;
            else if (pma_init_assertion & pma_init_pulse_width_cnt == 24'hFFFFFF)
                pma_init_assertion <= 1'b0;

            if (pma_init_assertion)
                pma_init_pulse_width_cnt <= pma_init_pulse_width_cnt + 24'h1;
        end

        if (EXAMPLE_SIMULATION)
            assign gt_reset_i_eff = gt_reset_i_delayed;
        else
            assign gt_reset_i_eff = pma_init_assertion ? 1'b1 : gt_reset_i_delayed;

        if (USE_LABTOOLS)
        begin : chip_reset
            assign gt_reset_i_tmp    = PMA_INIT | gtreset_from_vio_r3 | pma_init_from_fsm_r1;
            assign reset_i           = RESET | sysreset_from_vio_r3;
            assign gt_reset_i        = gt_reset_i_eff;
            assign gt_rxcdrovrden_i  = rx_cdrovrden_i;
        end
        else
        begin : no_chip_reset
            assign gt_reset_i_tmp    = PMA_INIT;
            assign reset_i           = RESET | gt_reset_i_tmp2;
            assign gt_reset_i        = gt_reset_i_eff;
            assign gt_rxcdrovrden_i  = 1'b0;
            assign loopback_i        = 3'b000;
        end

        if (!USE_LABTOOLS)
        begin
            aurora_64b66b_0_rst_sync_exdes u_rst_sync_gtrsttmpi
            (
                .prmry_in    (gt_reset_i_tmp),
                .scndry_aclk (user_clk_i),
                .scndry_out  (gt_reset_i_tmp2)
            );
        end
    endgenerate

    //___________________________Module Instantiations_________________________________

    aurora_64b66b_0_support aurora_64b66b_0_block_i
    (
        .s_axi_tx_tdata          (tx_tdata_i),
        .s_axi_tx_tlast          (tx_tlast_i),
        .s_axi_tx_tkeep          (tx_tkeep_i),
        .s_axi_tx_tvalid         (tx_tvalid_i),
        .s_axi_tx_tready         (tx_tready_i),

        .m_axi_rx_tdata          (rx_tdata_i),
        .m_axi_rx_tlast          (rx_tlast_i),
        .m_axi_rx_tkeep          (rx_tkeep_i),
        .m_axi_rx_tvalid         (rx_tvalid_i),

        .rxp                     (RXP),
        .rxn                     (RXN),
        .txp                     (TXP),
        .txn                     (TXN),

        .gt_refclk1_p            (GTYQ0_P),
        .gt_refclk1_n            (GTYQ0_N),

        .hard_err                (hard_err_i),
        .soft_err                (soft_err_i),

        .channel_up              (channel_up_i),
        .lane_up                 (lane_up_i),

        .user_clk_out            (user_clk_i),
        .sync_clk_out            (sync_clk_i),
        .reset_pb                (reset_r3),
        .gt_rxcdrovrden_in       (gt_rxcdrovrden_i),
        .power_down              (power_down_i),
        .loopback                (loopback_i),
        .pma_init                (gt_reset_i),
        .gt_pll_lock             (gt_pll_lock_i),

        .init_clk                (INIT_CLK_i),
        .link_reset_out          (link_reset_i),
        .mmcm_not_locked_out     (pll_not_locked_i),

        .bufg_gt_clr_out         (bufg_gt_clr_out),

        .sys_reset_out           (system_reset_i),
        .tx_out_clk              (tx_out_clk_i)
    );

    // ROM pattern contents
    always @(*) begin
        case (tx_pat_idx_r)
            3'd0: tx_pattern_i = 256'h000102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F;
            3'd1: tx_pattern_i = 256'h1112131415161718191A1B1C1D1E1F202122232425262728292A2B2C2D2E2F30;
            3'd2: tx_pattern_i = 256'h22232425262728292A2B2C2D2E2F303132333435363738393A3B3C3D3E3F4041;
            3'd3: tx_pattern_i = 256'h333435363738393A3B3C3D3E3F404142434445464748494A4B4C4D4E4F505152;
            3'd4: tx_pattern_i = 256'h4445464748494A4B4C4D4E4F505152535455565758595A5B5C5D5E5F60616263;
            3'd5: tx_pattern_i = 256'h55565758595A5B5C5D5E5F606162636465666768696A6B6C6D6E6F7071727374;
            3'd6: tx_pattern_i = 256'h666768696A6B6C6D6E6F707172737475767778797A7B7C7D7E7F808182838485;
            3'd7: tx_pattern_i = 256'h7778797A7B7C7D7E7F808182838485868788898A8B8C8D8E8F90919293949596;
            default: tx_pattern_i = 256'h0000000000000000000000000000000000000000000000000000000000000000;
        endcase
    end

    // Synchronize the PS valid request into user_clk_i.
    // Practical first-cut assumption:
    //   - PS writes ps_pl_data_i first
    //   - PS then asserts ps_pl_valid_i
    //   - PS keeps data stable until ps_pl_busy_o goes high, then later returns low
    always @(posedge user_clk_i) begin
        if (reset2FrameGen) begin
            ps_pl_valid_meta_r  <= `DLY 1'b0;
            ps_pl_valid_sync_r  <= `DLY 1'b0;
            ps_pl_valid_sync_d1 <= `DLY 1'b0;
        end
        else begin
            ps_pl_valid_meta_r  <= `DLY ps_pl_valid_i;
            ps_pl_valid_sync_r  <= `DLY ps_pl_valid_meta_r;
            ps_pl_valid_sync_d1 <= `DLY ps_pl_valid_sync_r;
        end
    end

    // Single-entry mailbox for the PS-fed path.
    // When a new PS request is seen, latch exactly one 256-bit record and present it
    // to Aurora until the TX interface accepts it.
    always @(posedge user_clk_i) begin
        if (reset2FrameGen) begin
            ps_data_r    <= `DLY 256'd0;
            ps_valid_r   <= `DLY 1'b0;
            ps_pl_busy_r <= `DLY 1'b0;
        end
        else begin
            // Accept one new record from PS when idle and channel is up
            if ((source_select_r == 1'b1) &&
                channel_up_i &&
                !ps_pl_busy_r &&
                !ps_valid_r &&
                ps_pl_valid_rise_i) begin
                ps_data_r    <= `DLY ps_pl_data_i;
                ps_valid_r   <= `DLY 1'b1;
                ps_pl_busy_r <= `DLY 1'b1;
            end

            // Clear valid/busy after Aurora accepts the beat
            if (ps_ready_i) begin
                ps_valid_r   <= `DLY 1'b0;
                ps_pl_busy_r <= `DLY 1'b0;
            end
        end
    end

    // TX source mux
    assign tx_mux_data_i  = (source_select_r == 1'b0) ? tx_pattern_i           : ps_data_r;
    assign tx_mux_valid_i = (source_select_r == 1'b0) ? channel_up_i           : ps_valid_r;
    assign tx_mux_last_i  = (source_select_r == 1'b0) ? (tx_pat_idx_r == 3'd7) : 1'b1;

    assign ps_ready_i = (source_select_r == 1'b1) && tx_tready_i && tx_mux_valid_i;

    // ROM pattern index only advances in ROM mode
    always @(posedge user_clk_i) begin
        if (reset2FrameGen)
            tx_pat_idx_r <= `DLY 3'd0;
        else if ((source_select_r == 1'b0) && channel_up_i && tx_tvalid_i && tx_tready_i) begin
            if (tx_pat_idx_r == 3'd7)
                tx_pat_idx_r <= `DLY 3'd0;
            else
                tx_pat_idx_r <= `DLY tx_pat_idx_r + 3'd1;
        end
    end

    generate
        if (USE_CORE_TRAFFIC == 1)
        begin : core_traffic

            assign tx_tvalid_i = tx_mux_valid_i;
            assign tx_tdata_i  = tx_mux_data_i;
            assign tx_tkeep_i  = 32'hFFFF_FFFF;
            assign tx_tlast_i  = tx_mux_last_i;

            aurora_64b66b_0_FRAME_CHECK #
            (
                .DATA_WIDTH(256),
                .STRB_WIDTH(32)
            )
            frame_check_i
            (
                .AXI4_S_IP_TX_TVALID (rx_tvalid_i),
                .AXI4_S_IP_TX_TREADY (),
                .AXI4_S_IP_TX_TDATA  (rx_tdata_i),
                .AXI4_S_IP_TX_TKEEP  (rx_tkeep_i),
                .AXI4_S_IP_TX_TLAST  (rx_tlast_i),
                .DATA_ERR_COUNT      (data_err_count_o),

                .CHANNEL_UP          (channel_up_i),
                .USER_CLK            (user_clk_i),
                .RESET               (reset2FrameCheck)
            );
        end
        else
        begin : no_traffic
            // define traffic generation modules here
        end
    endgenerate

    always @(posedge user_clk_i)
        if (reset2FrameCheck)
            rx_tvalid_r <= `DLY 1'b0;
        else if (rx_tvalid_i)
            rx_tvalid_r <= `DLY 1'b1;
        else
            rx_tvalid_r <= `DLY rx_tvalid_r;

    always @(posedge user_clk_i)
        if (reset2FrameCheck)
            usr_clk_counter <= `DLY 'd0;
        else if (usr_clk_counter >= USR_CLK_PCOUNT)
            usr_clk_counter <= `DLY USR_CLK_PCOUNT;
        else
            usr_clk_counter <= `DLY usr_clk_counter + 1'b1;

    assign usr_clk_count_done = (usr_clk_counter >= USR_CLK_PCOUNT) ? 1'b1 : 1'b0;

    reg usr_clk_count_done_r;
    reg usr_clk_count_done_r2;

    always @(posedge user_clk_i)
        usr_clk_count_done_r <= `DLY usr_clk_count_done;

    always @(posedge user_clk_i)
        usr_clk_count_done_r2 <= `DLY usr_clk_count_done_r;

//------------------------------------------------------------------------------
ila_0 u_ila (
    .clk(user_clk_i),
    .probe0(channel_up_i),         // 1
    .probe1(lane_up_i),            // 4
    .probe2(hard_err_i),           // 1
    .probe3(soft_err_i),           // 1
    .probe4(tx_tvalid_i),          // 1
    .probe5(tx_tready_i),          // 1
    .probe6(tx_tlast_i),           // 1
    .probe7(rx_tvalid_i),          // 1
    .probe8(rx_tlast_i),           // 1
    .probe9(tx_pat_idx_r),         // 3
    .probe10(source_select_r),     // 1
    .probe11(ps_valid_r),          // 1
    .probe12(ps_ready_i),          // 1
    .probe13(tx_tdata_i),          // 256
    .probe14(rx_tdata_i)           // 256
);

endmodule