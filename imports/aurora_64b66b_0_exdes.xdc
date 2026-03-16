################################################################################
# Aurora 64B/66B example design constraints
# RFSoC 4x2 / XCZU48DR / QSFP28 loopback
################################################################################

# ------------------------------------------------------------------------------
# Clear any stale top-level INIT clock constraints first
# ------------------------------------------------------------------------------

reset_property PACKAGE_PIN [get_ports {INIT_CLK_P INIT_CLK_N}]
reset_property LOC         [get_ports {INIT_CLK_P INIT_CLK_N}]
reset_property IOSTANDARD  [get_ports {INIT_CLK_P INIT_CLK_N}]

# ------------------------------------------------------------------------------
# INIT clock: RFSoC 4x2 PL DDR4 reference clock
# IMPORTANT: Vivado indicates G12 is the N-side of the pair, so map:
#   INIT_CLK_P -> G13
#   INIT_CLK_N -> G12
# ------------------------------------------------------------------------------

set_property PACKAGE_PIN G13 [get_ports {INIT_CLK_P}]
set_property PACKAGE_PIN G12 [get_ports {INIT_CLK_N}]
set_property IOSTANDARD DIFF_SSTL12 [get_ports {INIT_CLK_P INIT_CLK_N}]
create_clock -name init_clk_in -period 5.000 [get_ports {INIT_CLK_P}]

# ------------------------------------------------------------------------------
# QSFP GT reference clock: 156.25 MHz
# ------------------------------------------------------------------------------

set_property PACKAGE_PIN AA33 [get_ports {GTYQ0_P}]
set_property PACKAGE_PIN AA34 [get_ports {GTYQ0_N}]
create_clock -name gt_refclk1_in -period 6.400 [get_ports {GTYQ0_P}]

# ------------------------------------------------------------------------------
# Declare INIT clock and GT refclk asynchronous to each other
# ------------------------------------------------------------------------------

set_clock_groups -asynchronous \
  -group [get_clocks init_clk_in -include_generated_clocks] \
  -group [get_clocks gt_refclk1_in -include_generated_clocks]

# ------------------------------------------------------------------------------
# False path constraints for example design CDC paths
# ------------------------------------------------------------------------------

set_false_path -to [get_pins -hier *aurora_64b66b_0_cdc_to*/D]

# ------------------------------------------------------------------------------
# QSFP serial lanes
# ------------------------------------------------------------------------------

# TX lanes
set_property PACKAGE_PIN Y35 [get_ports {TXP[0]}]
set_property PACKAGE_PIN Y36 [get_ports {TXN[0]}]

set_property PACKAGE_PIN T35 [get_ports {TXP[1]}]
set_property PACKAGE_PIN T36 [get_ports {TXN[1]}]

set_property PACKAGE_PIN V35 [get_ports {TXP[2]}]
set_property PACKAGE_PIN V36 [get_ports {TXN[2]}]

set_property PACKAGE_PIN R33 [get_ports {TXP[3]}]
set_property PACKAGE_PIN R34 [get_ports {TXN[3]}]

# RX lanes
set_property PACKAGE_PIN R38  [get_ports {RXP[0]}]
set_property PACKAGE_PIN R39  [get_ports {RXN[0]}]

set_property PACKAGE_PIN W38  [get_ports {RXP[1]}]
set_property PACKAGE_PIN W39  [get_ports {RXN[1]}]

set_property PACKAGE_PIN U38  [get_ports {RXP[2]}]
set_property PACKAGE_PIN U39  [get_ports {RXN[2]}]

set_property PACKAGE_PIN AA38 [get_ports {RXP[3]}]
set_property PACKAGE_PIN AA39 [get_ports {RXN[3]}]