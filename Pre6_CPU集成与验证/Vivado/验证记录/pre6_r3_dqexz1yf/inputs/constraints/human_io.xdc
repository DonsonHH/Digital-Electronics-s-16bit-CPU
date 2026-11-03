# Implementation-only netlist constraints. The only untimed external IO is
# the asynchronous button and LEDs with no synchronous external receiver.
# Only the first request-synchronizer D is exempt; all core reset/data paths
# remain clocked and timed. Its exact presence is checked by build_board.tcl.
set_false_path -from [get_ports reset_btn_n] -to [get_pins -hier -regexp {^.*/request_sync_reg\[0\]/D$}]
set_false_path -to [get_ports {led[*]}]
