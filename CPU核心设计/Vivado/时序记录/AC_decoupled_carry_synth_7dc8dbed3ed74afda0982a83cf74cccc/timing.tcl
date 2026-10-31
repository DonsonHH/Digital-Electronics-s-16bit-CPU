set root [file dirname [file normalize [info script]]]
cd $root
create_project -in_memory -part xc7z020clg484-1
read_verilog -sv [concat [glob rtl/*.v] [glob rtl/*.sv]]
read_xdc constraints/core_ooc.xdc
synth_design -top datapath_core -part xc7z020clg484-1 -mode out_of_context -flatten_hierarchy none
write_checkpoint post_synth.dcp
write_verilog -mode funcsim post_synth_netlist.v
report_utilization -hierarchical -file utilization.rpt
report_timing_summary -report_unconstrained -max_paths 20 -file timing_summary.rpt
report_timing -delay_type max -max_paths 50 -nworst 1 -slack_lesser_than 0.0 -input_pins -nets -path_type full_clock_expanded -file failed_paths.rpt
report_timing -delay_type max -max_paths 10 -nworst 1 -input_pins -nets -path_type full_clock_expanded -file worst_paths.rpt
check_timing -verbose -file check_timing.rpt
report_drc -file drc.rpt
report_methodology -file methodology.rpt
set f [open timing_paths.tsv w]
puts $f "startpoint\tendpoint\tslack\tdatapath_delay\tlogic_levels"
foreach p [get_timing_paths -max_paths 50 -nworst 1 -slack_lesser_than 0.0] {
 puts $f "[get_property STARTPOINT_PIN $p]\t[get_property ENDPOINT_PIN $p]\t[get_property SLACK $p]\t[get_property DATAPATH_DELAY $p]\t[get_property LOGIC_LEVELS $p]"
}
close $f
set f [open resource_counts.tsv w]
puts $f "ref_name\tcount"
foreach ref {LUT1 LUT2 LUT3 LUT4 LUT5 LUT6 CARRY4 FDRE FDSE LDCE DSP48E1 RAMB18E1 RAMB36E1} {
 puts $f "$ref\t[llength [get_cells -hier -filter [format {REF_NAME == %s} $ref]]]"
}
close $f
set f [open clocks.txt w]
puts $f "tool=[version -short]"
puts $f "part=[get_property PART [current_design]]"
puts $f "clock_period=[get_property PERIOD [get_clocks core_clk]]"
close $f
puts "TIMING_EXPERIMENT_COMPLETE AC_decoupled_carry_synth_7dc8dbed3ed74afda0982a83cf74cccc input=2d0188de5e675e1627cf91dc7c0ff1defd4550c3a321dd0aa7f930ac1a722fc1 level=OOC_SYNTH no_place_no_route"
exit
