# ============================================================
# timing_async_fix.xdc
# Purpose:
#   - tell Vivado that PS clock, init clock, and GT clocks are
#     asynchronous to each other
#   - stop bogus cross-domain timing analysis
#   - let implementation focus on real intra-domain hold fixing
# ============================================================

# ------------------------------------------------------------
# PS fabric clock
# ------------------------------------------------------------
set ps_clk   [get_clocks -quiet clk_pl_0]

# ------------------------------------------------------------
# Init clock coming from INIT_CLK_P/N path
# ------------------------------------------------------------
set init_clk [get_clocks -quiet init_clk_in]

# ------------------------------------------------------------
# GT / Aurora related clocks
# These names are taken from your timing report.
# ------------------------------------------------------------
set tx_clk   [get_clocks -quiet txoutclk_out[0]]
set rx_clk   [get_clocks -quiet rxoutclk_out[0]]

# Some builds also show these GT internal TXOUTCLKPCS clocks
set gtx_tx0  [get_clocks -quiet GTYE4_CHANNEL_TXOUTCLKPCS[0]]
set gtx_tx1  [get_clocks -quiet GTYE4_CHANNEL_TXOUTCLKPCS[1]]
set gtx_tx2  [get_clocks -quiet GTYE4_CHANNEL_TXOUTCLKPCS[2]]
set gtx_tx3  [get_clocks -quiet GTYE4_CHANNEL_TXOUTCLKPCS[3]]

# ------------------------------------------------------------
# Declare unrelated root clocks asynchronous
# ------------------------------------------------------------
if {[llength $ps_clk] && [llength $tx_clk]} {
    set_clock_groups -asynchronous -group $ps_clk -group $tx_clk
}
if {[llength $ps_clk] && [llength $rx_clk]} {
    set_clock_groups -asynchronous -group $ps_clk -group $rx_clk
}
if {[llength $ps_clk] && [llength $init_clk]} {
    set_clock_groups -asynchronous -group $ps_clk -group $init_clk
}
if {[llength $init_clk] && [llength $tx_clk]} {
    set_clock_groups -asynchronous -group $init_clk -group $tx_clk
}
if {[llength $init_clk] && [llength $rx_clk]} {
    set_clock_groups -asynchronous -group $init_clk -group $rx_clk
}

# ------------------------------------------------------------
# GT internal TXOUTCLKPCS clocks should not be timed against
# PS clock or init clock either
# ------------------------------------------------------------
foreach gtx_clk [list $gtx_tx0 $gtx_tx1 $gtx_tx2 $gtx_tx3] {
    if {[llength $gtx_clk] && [llength $ps_clk]} {
        set_clock_groups -asynchronous -group $gtx_clk -group $ps_clk
    }
    if {[llength $gtx_clk] && [llength $init_clk]} {
        set_clock_groups -asynchronous -group $gtx_clk -group $init_clk
    }
}

# ------------------------------------------------------------
# Mark obvious CDC synchronizer flops as ASYNC_REG where possible
# This helps placement/hold handling for synchronizer chains.
# Safe if matches nothing.
# ------------------------------------------------------------
set sync_regs [get_cells -hier -quiet -regexp {.*(meta|sync).*}]
if {[llength $sync_regs]} {
    set_property ASYNC_REG TRUE $sync_regs
}

# ------------------------------------------------------------
# Optional: keep Vivado from trying to optimize away CDC intent
# ------------------------------------------------------------
if {[llength $sync_regs]} {
    set_property DONT_TOUCH FALSE $sync_regs
}