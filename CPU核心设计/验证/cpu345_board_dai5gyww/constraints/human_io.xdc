# Implementation-only netlist constraints. The only untimed external IO is
# the asynchronous button and LEDs with no synchronous external receiver.
# The3 synchronizer PRE pins are separately counted by build_board.tcl.
set_false_path -from [get_ports reset_btn_n] -to [get_pins -hier -filter {NAME =~ */release_sync_reg*/PRE}]
set_false_path -to [get_ports {led[*]}]
