if {[catch {
set project_file [file normalize [lindex $argv 0]]
open_project $project_file
if {[get_property TOP [get_filesets sources_1]] ne "pre6_ees331_top"} {error "Wrong board top"}
set root [file dirname [file dirname $project_file]]
set_property xsim.simulate.runtime 0ns [get_filesets sim_1]
launch_simulation -mode behavioral
run all
close_sim
reset_run synth_1
launch_runs synth_1 -jobs 4
wait_on_run synth_1
if {[get_property PROGRESS [get_runs synth_1]] ne "100%"} {error "Board synthesis failed"}
set f [open [file join [get_property DIRECTORY [get_runs synth_1]] runme.log] r];set text [read $f];close $f
if {[regexp {(?m)^ERROR:|^CRITICAL WARNING:} $text]} {error "Board synthesis error/critical warning"}
launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1
if {[get_property PROGRESS [get_runs impl_1]] ne "100%"} {error "Board implementation failed"}
open_run impl_1
file mkdir [file join $root reports]
report_timing_summary -delay_type min_max -report_unconstrained -file [file join $root reports gui_routed_timing.rpt]
report_drc -file [file join $root reports gui_drc.rpt]
set setup [get_property SLACK [get_timing_paths -delay_type max -max_paths 1]]
set hold [get_property SLACK [get_timing_paths -delay_type min -max_paths 1]]
if {$setup<0 || $hold<0} {error "Board timing violation"}
if {[llength [glob -nocomplain [file join [get_property DIRECTORY [get_runs impl_1]] *.bit]]]!=1} {error "Missing board bitstream"}
puts "GUI_BOARD_TIMING setup=$setup hold=$hold"
close_project
puts "PRE6_BOARD_GUI_ACCEPTANCE_COMPLETE"
} message options]} {
puts "PRE6_BOARD_GUI_ACCEPTANCE_FAILED=$message"
puts [dict get $options -errorinfo]
catch {close_project}
exit 1
}
exit 0
