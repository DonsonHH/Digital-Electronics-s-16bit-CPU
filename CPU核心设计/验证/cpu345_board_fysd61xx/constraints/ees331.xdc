# EES-331 User Manual PDF pages5,7,29,30: PL banks3.3V; clock100MHz.
create_clock -name board_clk -period 10.000 [get_ports clk100]
set_property PACKAGE_PIN M19 [get_ports clk100]
set_property PACKAGE_PIN L18 [get_ports reset_btn_n]
set_property IOSTANDARD LVCMOS33 [get_ports {clk100 reset_btn_n led[*]}]
foreach {index pin} {0 V4 1 U6 2 U5 3 V7 4 W7 5 W6 6 W5 7 U7} {
    set_property PACKAGE_PIN $pin [get_ports led[$index]]
}
set_property DRIVE 4 [get_ports {led[*]}]
set_property SLEW SLOW [get_ports {led[*]}]
# Legitimate asynchronous human-interface endpoints ONLY. No CPU data path
# exceptions and no invented synchronous input/output delays for buttons/LEDs.
set reset_presets [get_pins -hier -filter {NAME =~ */release_sync_reg*/PRE}]
if {[llength $reset_presets]!=3} {error "Expected3 asynchronous reset synchronizer PRE pins"}
set_false_path -from [get_ports reset_btn_n] -to $reset_presets
set_false_path -to [get_ports {led[*]}]
