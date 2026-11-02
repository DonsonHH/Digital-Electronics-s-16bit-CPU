# Acceptance of a published/copied project, including real reset and relaunch paths.
if {[catch {
set project_file [file normalize [lindex $argv 0]]
open_project $project_file
set project_root [file dirname $project_file]
set root [file dirname $project_root]
if {[get_property PART [current_project]] ne "xc7z020clg484-1"} {error "Incorrect device"}
if {[get_property TOP [get_filesets sources_1]] ne "pre6_cpu_top"} {error "Incorrect verification top"}
set_property xsim.simulate.runtime 0ns [get_filesets sim_1]
foreach pass {first after_reset} {
 if {$pass eq "after_reset"} {reset_simulation -mode behavioral sim_1}
 launch_simulation -mode behavioral
 log_wave -r /*
 run all
 close_sim
 puts "GUI_BEHAVIORAL_PASS=$pass"
}
foreach pass {first after_reset} {
 set run_dir [file normalize [get_property DIRECTORY [get_runs synth_1]]]
 if {![string match "$root/*" $run_dir]} {error "Run path escaped working project"}
 reset_run synth_1
 launch_runs synth_1 -jobs 4
 wait_on_run synth_1
 if {[get_property PROGRESS [get_runs synth_1]] ne "100%"} {error "Synthesis incomplete"}
 set f [open [file join $run_dir runme.log] r];set text [read $f];close $f
 if {[regexp {(?m)^ERROR:|^CRITICAL WARNING:} $text]} {error "Synthesis error/critical warning"}
 if {![string match *-mode\ out_of_context* $text]} {error "OOC command absent"}
 puts "GUI_SYNTHESIS_PASS=$pass"
}
open_run synth_1
close_design
launch_simulation -mode post-synthesis -type functional
log_wave -r /*
run all
close_sim
puts "GUI_POST_SYNTH_PASS"
close_project
puts "PRE6_GUI_ACCEPTANCE_COMPLETE"
} message options]} {
 puts "PRE6_GUI_ACCEPTANCE_FAILED=$message"
 puts [dict get $options -errorinfo]
 catch {close_project}
 exit 1
}
exit 0
