# Same cpu_system top and all_ops file images as the public RTL-system checker.
set root [file dirname [file normalize [info script]]]
cd $root
set part xc7z020clg484-1
file mkdir eda
create_project -in_memory -part $part
read_verilog -sv [concat [glob rtl/*.v] [glob rtl/*.sv]]
read_xdc constraints/system_ooc.xdc
synth_design -top cpu_system -part $part -mode out_of_context -flatten_hierarchy none
set clock [get_clocks system_clk]
if {[llength $clock] != 1 || [get_property PERIOD $clock] != 10.000} {error "Missing 10 ns system clock"}
report_utilization -hierarchical -file eda/utilization.rpt
report_timing_summary -report_unconstrained -file eda/timing.rpt
report_timing -max_paths 10 -path_type full_clock_expanded -file eda/critical_paths.rpt
report_drc -file eda/drc.rpt
check_timing -verbose -file eda/check_timing.rpt
write_checkpoint eda/system_synth.dcp
write_verilog -mode funcsim eda/system_netlist.v
set lut [llength [get_cells -hier -filter {REF_NAME =~ LUT*}]]
set ff [llength [get_cells -hier -filter {REF_NAME =~ FD*}]]
set bram [llength [get_cells -hier -filter {REF_NAME =~ RAMB*}]]
set carry [llength [get_cells -hier -filter {REF_NAME =~ CARRY*}]]
set output [open eda/synthesis.json w]
puts $output "{\"tool\":\"Vivado [version -short]\",\"part\":\"$part\",\"top\":\"cpu_system\",\"period_ns\":10,\"lut\":$lut,\"ff\":$ff,\"bram\":$bram,\"carry4\":$carry}"
close $output
puts "SYSTEM_SYNTHESIS_COMPLETE attempt=$env(CPU_SYSTEM_ATTEMPT) part=$part period_ns=[get_property PERIOD $clock] scope=OOC_not_board"
exit
