set task_dir [file dirname [file normalize [info script]]]
cd $task_dir
start_gui
foreach top {regfile4x16 alu16 pc16 imm_ext16} {
 open_checkpoint synthesis/${top}.dcp
 show_schematic -name ${top}_mapped [get_nets]
 write_schematic -force -format pdf -name ${top}_mapped -orientation landscape synthesis/${top}_schematic.pdf
 close_design
}
puts "SCHEMATICS_EXPORTED"
exit
