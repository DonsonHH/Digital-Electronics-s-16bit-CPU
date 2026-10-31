# Portable source project. Run from any directory; every source resolves
# relative to this script. Generated project stays under ./project only.
set root [file dirname [file normalize [info script]]]
set part xc7z020clg484-1
# Never erase an existing project/cache as part of source registration.
# Optional -tclargs project_new selects a separate relative output directory.
set project_dir [file join $root project]
if {[llength $argv] > 0} {set project_dir [file join $root [lindex $argv 0]]}
create_project cpu_v16 $project_dir -part $part
set_property target_language Verilog [current_project]
set_property simulator_language Mixed [current_project]
set sources [concat [glob [file join $root rtl *.v]] [glob [file join $root rtl *.sv]]]
add_files -norecurse $sources
add_files -fileset sim_1 -norecurse [glob [file join $root tb *.sv]]
add_files -fileset sim_1 -norecurse [glob [file join $root tb *.svh]]
set_property include_dirs [list [file join $root tb]] [get_filesets sim_1]
add_files -fileset constrs_1 -norecurse [list [file join $root constraints core_ooc.xdc]]
set_property top datapath_core [get_filesets sources_1]
set_property top tb_datapath [get_filesets sim_1]
set_property xsim.simulate.runtime {0ns} [get_filesets sim_1]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
puts "PROJECT_READY=[file join $project_dir cpu_v16.xpr]"
puts "SIM_TOP=tb_datapath; run all in XSim Tcl console for the full regression."
set reg [open [file join $project_dir source_registration.tsv] w]
fconfigure $reg -encoding utf-8
puts $reg "fileset\tname\ttype"
foreach fs {sources_1 sim_1 constrs_1} {
 foreach item [get_files -of_objects [get_filesets $fs]] {
  puts $reg "$fs\t[get_property NAME $item]\t[get_property FILE_TYPE $item]"
 }
}
close $reg
puts "CORE_PROJECT_SOURCES_VERIFIED tool=[version -short] part=$part"
close_project
exit
