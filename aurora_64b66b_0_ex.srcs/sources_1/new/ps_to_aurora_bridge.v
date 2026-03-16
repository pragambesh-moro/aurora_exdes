`timescale 1 ps / 1 ps

module ps_to_aurora_bridge
(
    // PS / AXI clock domain
    input              ps_clk_i,
    input              ps_rst_i,
    input      [31:0]  ps_gpio_tx_data0_i,
    input      [31:0]  ps_gpio_tx_data1_i,
    input      [31:0]  ps_gpio_tx_data2_i,
    input      [31:0]  ps_gpio_tx_data3_i,
    input      [31:0]  ps_gpio_tx_data4_i,
    input      [31:0]  ps_gpio_tx_data5_i,
    input      [31:0]  ps_gpio_tx_data6_i,
    input      [31:0]  ps_gpio_tx_data7_i,
    input              ps_gpio_tx_valid_i,
    output     [1:0]   ps_gpio_tx_status_o,

    // Aurora user clock domain
    input              aurora_user_clk_i,
    input              aurora_ps_ready_i,
    input              aurora_ps_busy_i,
    output reg [0:255] aurora_ps_data_o,
    output reg         aurora_ps_valid_o
);

    // ------------------------------------------------------------------------
    // Write-side pulse detect in PS clock domain
    // ------------------------------------------------------------------------
    reg ps_valid_d1 = 1'b0;
    wire ps_valid_rise;
    wire fifo_full;
    wire fifo_empty;
    wire [255:0] fifo_dout;
    reg fifo_rd_en = 1'b0;
    wire fifo_wr_en;

    reg aurora_busy_meta_ps  = 1'b0;
    reg aurora_busy_sync_ps  = 1'b0;
    reg aurora_ready_meta_ps = 1'b0;
    reg aurora_ready_sync_ps = 1'b0;

    assign ps_valid_rise = ps_gpio_tx_valid_i & ~ps_valid_d1;
    assign fifo_wr_en    = ps_valid_rise & ~fifo_full;

    always @(posedge ps_clk_i) begin
        ps_valid_d1 <= ps_gpio_tx_valid_i;

        aurora_busy_meta_ps  <= aurora_ps_busy_i;
        aurora_busy_sync_ps  <= aurora_busy_meta_ps;
        aurora_ready_meta_ps <= aurora_ps_ready_i;
        aurora_ready_sync_ps <= aurora_ready_meta_ps;
    end

    // Status back to PS software
    // bit0 = ready_for_new
    // bit1 = busy
    assign ps_gpio_tx_status_o[0] = aurora_ready_sync_ps & ~fifo_full;
    assign ps_gpio_tx_status_o[1] = aurora_busy_sync_ps  | ~fifo_empty;

    // ------------------------------------------------------------------------
    // Async FIFO: PS clock domain -> Aurora user clock domain
    // ------------------------------------------------------------------------
    xpm_fifo_async #(
        .CDC_SYNC_STAGES      (2),
        .DOUT_RESET_VALUE     ("0"),
        .ECC_MODE             ("no_ecc"),
        .FIFO_MEMORY_TYPE     ("auto"),
        .FIFO_READ_LATENCY    (0),
        .FIFO_WRITE_DEPTH     (16),
        .FULL_RESET_VALUE     (0),
        .PROG_EMPTY_THRESH    (10),
        .PROG_FULL_THRESH     (10),
        .RD_DATA_COUNT_WIDTH  (5),
        .READ_DATA_WIDTH      (256),
        .READ_MODE            ("fwft"),
        .RELATED_CLOCKS       (0),
        .SIM_ASSERT_CHK       (0),
        .USE_ADV_FEATURES     ("0707"),
        .WAKEUP_TIME          (0),
        .WRITE_DATA_WIDTH     (256),
        .WR_DATA_COUNT_WIDTH  (5)
    ) u_ps_to_aurora_fifo (
        .rst            (ps_rst_i),

        .wr_clk         (ps_clk_i),
        .wr_en          (fifo_wr_en),
        .din            ({ps_gpio_tx_data7_i,
                          ps_gpio_tx_data6_i,
                          ps_gpio_tx_data5_i,
                          ps_gpio_tx_data4_i,
                          ps_gpio_tx_data3_i,
                          ps_gpio_tx_data2_i,
                          ps_gpio_tx_data1_i,
                          ps_gpio_tx_data0_i}),
        .full           (fifo_full),
        .wr_data_count  (),
        .overflow       (),
        .prog_full      (),
        .wr_ack         (),
        .almost_full    (),

        .rd_clk         (aurora_user_clk_i),
        .rd_en          (fifo_rd_en),
        .dout           (fifo_dout),
        .empty          (fifo_empty),
        .rd_data_count  (),
        .underflow      (),
        .prog_empty     (),
        .data_valid     (),
        .almost_empty   (),

        .sleep          (1'b0),
        .injectsbiterr  (1'b0),
        .injectdbiterr  (1'b0),
        .sbiterr        (),
        .dbiterr        ()
    );

    // ------------------------------------------------------------------------
    // Read-side drive into Aurora mailbox inputs (Aurora clock domain)
    // ------------------------------------------------------------------------
    reg driving_req_r = 1'b0;

    always @(posedge aurora_user_clk_i) begin
        fifo_rd_en         <= 1'b0;

        // Default: keep previous data unless loading a new record
        if (!driving_req_r) begin
            // Only start a new Aurora request when Aurora mailbox is idle and FIFO has data
            if (!fifo_empty && !aurora_ps_busy_i) begin
                aurora_ps_data_o[  0: 31] <= fifo_dout[ 31:  0];
                aurora_ps_data_o[ 32: 63] <= fifo_dout[ 63: 32];
                aurora_ps_data_o[ 64: 95] <= fifo_dout[ 95: 64];
                aurora_ps_data_o[ 96:127] <= fifo_dout[127: 96];
                aurora_ps_data_o[128:159] <= fifo_dout[159:128];
                aurora_ps_data_o[160:191] <= fifo_dout[191:160];
                aurora_ps_data_o[192:223] <= fifo_dout[223:192];
                aurora_ps_data_o[224:255] <= fifo_dout[255:224];
                aurora_ps_valid_o         <= 1'b1;
                driving_req_r             <= 1'b1;
                fifo_rd_en                <= 1'b1;
            end
        end
        else begin
            // Hold valid high until Aurora mailbox reports busy, meaning it captured the request
            if (aurora_ps_busy_i) begin
                aurora_ps_valid_o <= 1'b0;
                driving_req_r     <= 1'b0;
            end
        end
    end

endmodule
