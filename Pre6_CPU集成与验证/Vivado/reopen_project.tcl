# Check that a copied XPR really opens and runs from the user's course folder.
if {[llength $argv]!=1} {error "Pass the relocated pre6_cpu.xpr path"}
open_project [file normalize [lindex $argv 0]]
if {[get_property PART [current_project]] ne "xc7z020clg484-1"} {error "Wrong part"}
if {[get_property TOP [get_filesets sim_1]] ne "tb_selected_program"} {error "Wrong simulation top"}
set_property xsim.simulate.runtime 0ns [get_filesets sim_1]
foreach item [get_files -of_objects [get_filesets sources_1]] {
    set source_name [get_property NAME $item]
    if {[file extension $source_name] in {.v .sv}} {puts "PRE6_RELOCATED_RTL=[file normalize $source_name]"}
}
launch_simulation -mode behavioral
log_wave -r /*
run all
close_sim
close_project
puts "PRE6_RELOCATED_PROJECT_COMPLETE"
exit
