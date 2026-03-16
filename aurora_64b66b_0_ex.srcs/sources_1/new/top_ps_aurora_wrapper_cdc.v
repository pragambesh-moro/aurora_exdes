`timescale 1 ps / 1 ps

module top_ps_aurora_wrapper
(
    // Aurora example design physical ports
    input              INIT_CLK_P,
    input              INIT_CLK_N,
    input              GTYQ0_P,
    input              GTYQ0_N,
    input      [0:3]   RXP,
    input      [0:3]   RXN,
    output     [0:3]   TXP,
    output     [0:3]   TXN
);

    // ------------------------------------------------------------------------
    // Wires from block design wrapper
    // NOTE: design_1_wrapper must export pl_clk0 as pl_clk0_0.
    // ------------------------------------------------------------------------
    wire        pl_clk0_0;
    wire [31:0] ps_gpio_tx_data0;
    wire [31:0] ps_gpio_tx_data1;
    wire [31:0] ps_gpio_tx_data2;
    wire [31:0] ps_gpio_tx_data3;
    wire [31:0] ps_gpio_tx_data4;
    wire [31:0] ps_gpio_tx_data5;
    wire [31:0] ps_gpio_tx_data6;
    wire [31:0] ps_gpio_tx_data7;
    wire [1:0]  ps_gpio_tx_tstatus;
    wire [0:0]  ps_gpio_tx_tvalid;

    // ------------------------------------------------------------------------
    // Bridge <-> Aurora mailbox wires
    // ------------------------------------------------------------------------
    wire [0:255] bridge_to_aurora_data;
    wire         bridge_to_aurora_valid;
    wire         aurora_to_bridge_ready;
    wire         aurora_to_bridge_busy;
    wire         aurora_user_clk_o;

    // ------------------------------------------------------------------------
    // Block design instance
    // ------------------------------------------------------------------------
    design_1_wrapper u_design_1_wrapper
    (
        .pl_clk0_0                 (pl_clk0_0),
        .ps_gpio_tx_data0_tri_o    (ps_gpio_tx_data0),
        .ps_gpio_tx_data1_tri_o    (ps_gpio_tx_data1),
        .ps_gpio_tx_data2_tri_o    (ps_gpio_tx_data2),
        .ps_gpio_tx_data3_tri_o    (ps_gpio_tx_data3),
        .ps_gpio_tx_data4_tri_o    (ps_gpio_tx_data4),
        .ps_gpio_tx_data5_tri_o    (ps_gpio_tx_data5),
        .ps_gpio_tx_data6_tri_o    (ps_gpio_tx_data6),
        .ps_gpio_tx_data7_tri_o    (ps_gpio_tx_data7),
        .ps_gpio_tx_tstatus_tri_i  (ps_gpio_tx_tstatus),
        .ps_gpio_tx_tvalid_tri_o   (ps_gpio_tx_tvalid)
    );

    // ------------------------------------------------------------------------
    // CDC-correct bridge: PS clock domain -> Aurora user clock domain
    // ------------------------------------------------------------------------
    ps_to_aurora_bridge u_ps_to_aurora_bridge
    (
        .ps_clk_i              (pl_clk0_0),
        .ps_rst_i              (1'b0),
        .ps_gpio_tx_data0_i    (ps_gpio_tx_data0),
        .ps_gpio_tx_data1_i    (ps_gpio_tx_data1),
        .ps_gpio_tx_data2_i    (ps_gpio_tx_data2),
        .ps_gpio_tx_data3_i    (ps_gpio_tx_data3),
        .ps_gpio_tx_data4_i    (ps_gpio_tx_data4),
        .ps_gpio_tx_data5_i    (ps_gpio_tx_data5),
        .ps_gpio_tx_data6_i    (ps_gpio_tx_data6),
        .ps_gpio_tx_data7_i    (ps_gpio_tx_data7),
        .ps_gpio_tx_valid_i    (ps_gpio_tx_tvalid[0]),
        .ps_gpio_tx_status_o   (ps_gpio_tx_tstatus),
        .aurora_user_clk_i     (aurora_user_clk_o),
        .aurora_ps_ready_i     (aurora_to_bridge_ready),
        .aurora_ps_busy_i      (aurora_to_bridge_busy),
        .aurora_ps_data_o      (bridge_to_aurora_data),
        .aurora_ps_valid_o     (bridge_to_aurora_valid)
    );

    // ------------------------------------------------------------------------
    // Aurora example design instance
    // NOTE: aurora_64b66b_0_exdes must export user_clk_o.
    // ------------------------------------------------------------------------
    aurora_64b66b_0_exdes u_aurora_64b66b_0_exdes
    (
        .INIT_CLK_P    (INIT_CLK_P),
        .INIT_CLK_N    (INIT_CLK_N),
        .GTYQ0_P       (GTYQ0_P),
        .GTYQ0_N       (GTYQ0_N),
        .RXP           (RXP),
        .RXN           (RXN),
        .TXP           (TXP),
        .TXN           (TXN),

        .ps_pl_data_i  (bridge_to_aurora_data),
        .ps_pl_valid_i (bridge_to_aurora_valid),
        .ps_pl_ready_o (aurora_to_bridge_ready),
        .ps_pl_busy_o  (aurora_to_bridge_busy),
        .user_clk_o    (aurora_user_clk_o)
    );

endmodule
