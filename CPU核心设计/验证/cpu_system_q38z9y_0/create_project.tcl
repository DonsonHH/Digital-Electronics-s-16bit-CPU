# Create a NEW source-backed EES-331 system project; existing projects survive.
set root [file dirname [file normalize [info script]]]
set package [file dirname $root]
set core_rtl [file join $package Vivado rtl]
# A private verification snapshot places all 14 RTLs beside this script.
if {[file isdirectory [file join $root rtl]] && [file exists [file join $root rtl datapath_core.sv]]} {set core_rtl [file join $root rtl]}
set project_dir [file join $root project]
if {[llength $argv] > 0} {set project_dir [file normalize [lindex $argv 0]]}
if {[file exists $project_dir]} {error "Refusing to overwrite project: $project_dir"}
create_project cpu_system $project_dir -part xc7z020clg484-1
set_property target_language Verilog [current_project]
set_property simulator_language Mixed [current_project]
set sources [concat [glob [file join $core_rtl *.v]] [glob [file join $core_rtl *.sv]]]
set system_source [file join $root rtl cpu_system.sv]
if {[lsearch -exact $sources $system_source] < 0} {lappend sources $system_source}
if {[llength $sources] != 14} {error "Expected 13 core RTLs plus cpu_system"}
add_files -norecurse $sources
add_files -fileset sim_1 -norecurse [glob [file join $root tb *.sv]]
add_files -fileset sim_1 -norecurse [glob [file join $root tb *.svh]]
set_property include_dirs [list [file join $root tb]] [get_filesets sim_1]
add_files -norecurse [glob [file join $root programs *.mem]]
add_files -fileset constrs_1 -norecurse [file join $root constraints system_ooc.xdc]
set_property top cpu_system [get_filesets sources_1]
set_property top tb_cpu_system [get_filesets sim_1]
set_property xsim.simulate.runtime 0ns [get_filesets sim_1]
# Preserve the relative programs/... names used by both HDL and checker.
# Each freshly generated project owns these immutable image snapshots.
foreach destination [list [file join $project_dir cpu_system.sim sim_1 behav xsim] [file join $project_dir cpu_system.runs synth_1]] {
    file mkdir $destination
    file copy [file join $root programs] $destination
}
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
foreach item [get_files -of_objects [get_filesets sources_1]] {
    if {[file extension [get_property NAME $item]] in {.v .sv}} {puts "SYSTEM_PROJECT_SOURCE=[get_property NAME $item]"}
}
puts "SYSTEM_PROJECT_READY top=cpu_system part=xc7z020clg484-1 rtl=14"
if {[llength $argv] > 1 && [lindex $argv 1] eq "verify"} {
    launch_simulation -mode behavioral
    puts "SYSTEM_ATTEMPT=$env(CPU_SYSTEM_ATTEMPT)"
    run all
    close_sim
}
close_project
exit
