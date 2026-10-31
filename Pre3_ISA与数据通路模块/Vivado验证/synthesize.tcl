set task_dir [file dirname [file normalize [info script]]]
cd $task_dir
file mkdir synthesis
set device xc7z010clg400-1
foreach top {regfile4x16 alu16 pc16 imm_ext16} {
 create_project -in_memory -part $device
 read_verilog [glob rtl/*.v]
 synth_design -top $top -part $device
 report_utilization -file synthesis/${top}_utilization.rpt
 write_checkpoint -force synthesis/${top}.dcp
 write_verilog -force -mode funcsim synthesis/${top}_netlist.v
 close_project
}
puts "PRE3_SYNTH_PASS target=$device"
puts [write_schematic -help]
exit
