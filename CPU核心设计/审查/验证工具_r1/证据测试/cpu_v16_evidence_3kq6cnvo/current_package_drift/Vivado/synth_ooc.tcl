# Post-synthesis OOC estimate only. No placement, routing or board claim.
set root [file dirname [file normalize [info script]]]
cd $root
set part xc7z020clg484-1
if {[llength [get_parts $part]] != 1} {error "Target part is unavailable: $part"}
file mkdir eda
create_project -in_memory -part $part
read_verilog -sv [concat [glob rtl/*.v] [glob rtl/*.sv]]
read_xdc constraints/core_ooc.xdc
synth_design -top datapath_core -part $part -mode out_of_context -flatten_hierarchy none
set clock [get_clocks core_clk]
if {[llength $clock] != 1 || [get_property PERIOD $clock] != 10.000} {
    error "Expected core_clk period 10 ns was not applied during synthesis"
}
report_utilization -hierarchical -file eda/utilization.rpt
report_timing_summary -report_unconstrained -file eda/post_synth_timing.rpt
write_checkpoint eda/core_synth.dcp
write_verilog -mode funcsim eda/core_netlist.v
puts "CPU_V16_SYNTHESIS_COMPLETE tool=[version -short] part=$part constraint_ns=[get_property PERIOD $clock] mode=OOC timing_closure_not_claimed"
exit
