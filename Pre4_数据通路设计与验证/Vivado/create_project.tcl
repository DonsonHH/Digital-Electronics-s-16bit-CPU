# Portable source project. Run from any directory; every source resolves
# relative to this script. Generated project stays under ./project only.
set root [file dirname [file normalize [info script]]]
set part xc7z020clg484-1
# Never erase an existing project/cache as part of source registration.
# Optional -tclargs project_new selects a separate relative output directory.
set project_dir [file join $root project]
if {[llength $argv] > 0} {set project_dir [file join $root [lindex $argv 0]]}
create_project pre4_v14 $project_dir -part $part
set_property target_language Verilog [current_project]
set_property simulator_language Mixed [current_project]
set sources [concat [glob [file join $root rtl *.v]] [glob [file join $root rtl *.sv]]]
add_files -norecurse $sources
add_files -fileset sim_1 -norecurse [glob [file join $root tb *.sv]]
set_property top datapath_core [get_filesets sources_1]
set_property top tb_datapath [get_filesets sim_1]
set_property xsim.simulate.runtime {0ns} [get_filesets sim_1]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
puts "PROJECT_READY=[file join $project_dir pre4_v14.xpr]"
puts "SIM_TOP=tb_datapath; run all in XSim Tcl console for the full regression."
close_project
exit
