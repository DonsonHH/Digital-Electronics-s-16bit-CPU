set root [file dirname [file normalize [info script]]]
cd $root
set part xc7z020clg484-1
if {[llength [get_parts $part]] != 1} {error "Required part unavailable: $part"}
file mkdir eda
set sources [concat [glob rtl/*.v] [glob rtl/*.sv]]
# All analysis is in-memory. Do not overwrite the delivered/user source XPR.
# Rebuilding that portable project is a separate create_project.tcl operation.
start_gui
# Exact RTL elaboration views (before technology mapping).
foreach {top stem} {datapath_core rtl_core alu16 rtl_alu cla16 rtl_cla16 cla4_pg rtl_cla4 operand_forward rtl_forward flags_reg rtl_flags} {
 create_project -in_memory -part $part
 read_verilog -sv $sources
 synth_design -rtl -top $top -part $part
 show_schematic -name $stem [get_nets]
 write_schematic -force -format pdf -name $stem -orientation landscape eda/${stem}.pdf
 close_project
}
create_project -in_memory -part $part
read_verilog -sv $sources
synth_design -top datapath_core -part $part -mode out_of_context -flatten_hierarchy none
create_clock -period 10.000 -name core_clk [get_ports clk]
report_utilization -hierarchical -file eda/utilization.rpt
report_timing_summary -report_unconstrained -file eda/post_synth_timing.rpt
write_checkpoint -force eda/core_synth.dcp
write_verilog -force -mode funcsim eda/core_netlist.v
show_schematic -name mapped_core [get_nets]
write_schematic -force -format pdf -name mapped_core -orientation landscape eda/mapped_core.pdf
puts "PRE4_EDA_PASS tool=[version -short] part=$part clock_constraint_ns=10.000 mode=OOC"
exit
