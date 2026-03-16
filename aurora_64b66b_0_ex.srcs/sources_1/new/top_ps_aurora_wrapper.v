//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/17/2026 01:20:57 AM
// Design Name: 
// Module Name: top_ps_aurora_wrapper
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`timescale 1 ps / 1 ps

module top_ps_aurora_wrapper_old
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
    // Wires from PS block design wrapper
    // ------------------------------------------------------------------------
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
    // Packed 256-bit PS->PL mailbox bus
    // IMPORTANT:
    // aurora_64b66b_0_exdes uses [0:255] indexing, so map carefully.
    // ------------------------------------------------------------------------
    wire [0:255] ps_pl_data_i;
    wire         ps_pl_valid_i;
    wire         ps_pl_ready_o;
    wire         ps_pl_busy_o;

    // ------------------------------------------------------------------------
    // Block design instance
    // ------------------------------------------------------------------------
    design_1_wrapper u_design_1_wrapper
    (
        .ps_gpio_tx_data0_tri_o   (ps_gpio_tx_data0),
        .ps_gpio_tx_data1_tri_o   (ps_gpio_tx_data1),
        .ps_gpio_tx_data2_tri_o   (ps_gpio_tx_data2),
        .ps_gpio_tx_data3_tri_o   (ps_gpio_tx_data3),
        .ps_gpio_tx_data4_tri_o   (ps_gpio_tx_data4),
        .ps_gpio_tx_data5_tri_o   (ps_gpio_tx_data5),
        .ps_gpio_tx_data6_tri_o   (ps_gpio_tx_data6),
        .ps_gpio_tx_data7_tri_o   (ps_gpio_tx_data7),
        .ps_gpio_tx_tstatus_tri_i (ps_gpio_tx_tstatus),
        .ps_gpio_tx_tvalid_tri_o  (ps_gpio_tx_tvalid)
    );

    // ------------------------------------------------------------------------
    // Pack 8 x 32-bit GPIO words into one 256-bit mailbox word
    //
    // Mapping:
    //   data0 -> [31:0]
    //   data1 -> [63:32]
    //   ...
    //   data7 -> [255:224]
    //
    // Because the Aurora module uses [0:255], we assign by slices in that order.
    // ------------------------------------------------------------------------
    assign ps_pl_data_i[  0: 31] = ps_gpio_tx_data0;
    assign ps_pl_data_i[ 32: 63] = ps_gpio_tx_data1;
    assign ps_pl_data_i[ 64: 95] = ps_gpio_tx_data2;
    assign ps_pl_data_i[ 96:127] = ps_gpio_tx_data3;
    assign ps_pl_data_i[128:159] = ps_gpio_tx_data4;
    assign ps_pl_data_i[160:191] = ps_gpio_tx_data5;
    assign ps_pl_data_i[192:223] = ps_gpio_tx_data6;
    assign ps_pl_data_i[224:255] = ps_gpio_tx_data7;

    assign ps_pl_valid_i        = ps_gpio_tx_tvalid[0];
    assign ps_gpio_tx_tstatus[0] = ps_pl_ready_o;
    assign ps_gpio_tx_tstatus[1] = ps_pl_busy_o;

    // ------------------------------------------------------------------------
    // Aurora example design instance
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

        .ps_pl_data_i  (ps_pl_data_i),
        .ps_pl_valid_i (ps_pl_valid_i),
        .ps_pl_ready_o (ps_pl_ready_o),
        .ps_pl_busy_o  (ps_pl_busy_o)
    );

endmodule