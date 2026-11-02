# A fresh relocatable project. No hardware-manager or programming commands.
set root [file dirname [file normalize [info script]]]
if {[version -short] ne "2025.2"} {error "Reviewed tool version is Vivado 2025.2"}
set target [file join $root project]
if {[file exists $target]} {error "Refusing to overwrite an existing project"}
set top tb_selected_program
if {[llength $argv] > 0 && [lindex $argv 0] eq "system"} {set top tb_cpu_system}
create_project pre6_cpu $target -part xc7z020clg484-1
set_property target_language Verilog [current_project]
set_property simulator_language Mixed [current_project]
set rtl [concat [glob [file join $root rtl *.v]] [glob [file join $root rtl *.sv]]]
if {[llength $rtl] != 15} {error "Expected 13 core + system + application RTL files"}
add_files -norecurse $rtl
add_files -fileset sim_1 -norecurse [concat [glob [file join $root tb *.sv]] [glob [file join $root tb *.svh]]]
set_property include_dirs [list [file join $root tb]] [get_filesets sim_1]
add_files -norecurse [glob [file join $root programs *.mem]]
add_files -fileset constrs_1 -norecurse [file join $root constraints system_ooc.xdc]
set_property top cpu_system [get_filesets sources_1]
set_property top $top [get_filesets sim_1]
set_property xsim.simulate.runtime 0ns [get_filesets sim_1]
foreach dir [list [file join $target pre6_cpu.sim sim_1 behav xsim] [file join $target pre6_cpu.runs synth_1]] {
    file mkdir $dir
    file copy [file join $root programs] $dir
}
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
puts "PRE6_PROJECT_READY rtl=15 top=cpu_system sim=$top part=xc7z020clg484-1"
launch_simulation -mode behavioral
log_wave -r /*
if {$top eq "tb_selected_program"} {
    open_vcd pre6_selected.vcd
    log_vcd [get_objects -r /*]
}
run all
if {$top eq "tb_selected_program"} {close_vcd}
close_sim
close_project
puts "PRE6_SIMULATION_COMPLETE"
exit
