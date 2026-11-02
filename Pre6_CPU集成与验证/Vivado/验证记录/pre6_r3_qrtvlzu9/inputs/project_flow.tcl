# Native GUI-compatible flow; MEM basenames are resolved from registered data files.
set root [file dirname [file normalize [info script]]]
if {[catch {
set kind [lindex $argv 0]
set mode [lindex $argv 1]
if {$kind ni {cpu board}} {error "Project kind must be cpu or board"}
if {[version -short] ne "2025.2"} {error "Use the reviewed Vivado 2025.2 toolchain"}
set project_dir [file join $root project]
if {[file exists $project_dir]} {error "Refusing to overwrite a project"}
create_project pre6_cpu $project_dir -part xc7z020clg484-1
set_property default_lib xil_defaultlib [current_project]
set_property target_language Verilog [current_project]
set_property simulator_language Mixed [current_project]
set_param general.maxThreads 4
set_property AUTO_INCREMENTAL_CHECKPOINT 0 [get_runs synth_1]
set rtl {}
foreach source [concat [glob [file join $root rtl *.v]] [glob [file join $root rtl *.sv]]] {
 set name [file tail $source]
 if {$kind eq "cpu" && $name in {ees331_application.sv pre6_ees331_top.sv}} {continue}
 if {$kind eq "board" && $name eq "pre6_cpu_top.v"} {continue}
 lappend rtl $source
}
add_files -norecurse $rtl
add_files -norecurse [list [file join $root data dut_im.mem] [file join $root data dut_dm.mem]]
add_files -fileset sim_1 -norecurse [list [file join $root data selected_events.mem] [file join $root data selected_stores.mem] [file join $root tb selected_expected.svh]]
set_property include_dirs [list [file join $root tb]] [get_filesets sim_1]
set_property xsim.simulate.runtime 0ns [get_filesets sim_1]
if {$kind eq "cpu"} {
 set top pre6_cpu_top
 set bench tb_pre6_cpu
 add_files -fileset sim_1 -norecurse [file join $root tb tb_pre6_cpu.sv]
 add_files -fileset constrs_1 -norecurse [file join $root constraints cpu_clock.xdc]
 # Ask the native run object for the documented mode property, then verify its command in the log.
 # AMD AR59168; this exact option is also checked in the native synth command.
 set_property -name {STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS} -value {-mode out_of_context} -objects [get_runs synth_1]
} else {
 set top pre6_ees331_top
 set bench tb_pre6_board
 add_files -fileset sim_1 -norecurse [file join $root tb tb_pre6_board.sv]
 add_files -fileset constrs_1 -norecurse [file join $root constraints ees331.xdc]
 add_files -fileset constrs_1 -norecurse [file join $root constraints human_io.xdc]
 set_property USED_IN_SYNTHESIS false [get_files *human_io.xdc]
 create_ip -name vio -vendor xilinx.com -library ip -version 3.0 -module_name ees331_vio
 set_property -dict [list CONFIG.C_NUM_PROBE_IN {2} CONFIG.C_PROBE_IN0_WIDTH {256} CONFIG.C_PROBE_IN1_WIDTH {160} CONFIG.C_NUM_PROBE_OUT {1} CONFIG.C_PROBE_OUT0_WIDTH {1} CONFIG.C_PROBE_OUT0_INIT_VAL {0x1} CONFIG.C_EN_PROBE_IN_ACTIVITY {0}] [get_ips ees331_vio]
 generate_target all [get_ips ees331_vio]
}
set_property top $top [get_filesets sources_1]
set_property top $bench [get_filesets sim_1]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
puts "PRE6_R3_PROJECT_READY kind=$kind top=$top bench=$bench images=dut_im.mem,dut_dm.mem"
if {$mode ne "create"} {
 launch_simulation -mode behavioral
 log_wave -r /*
 run all
 close_sim
 puts "PRE6_R3_BEHAVIORAL_COMPLETE"
}
if {$mode in {synthesis full}} {
 reset_run synth_1
 launch_runs synth_1 -jobs 4
 wait_on_run synth_1
 if {[get_property PROGRESS [get_runs synth_1]] ne "100%"} {error "Synthesis did not complete"}
 set fh [open [file join [get_property DIRECTORY [get_runs synth_1]] runme.log] r];set log [read $fh];close $fh
 if {[regexp {(?m)^ERROR:|^CRITICAL WARNING:} $log]} {error "Synthesis log contains an error or critical warning"}
 open_run synth_1
 file mkdir [file join $root reports]
 report_utilization -file [file join $root reports synthesis_utilization.rpt]
 report_timing_summary -file [file join $root reports synthesis_timing.rpt]
 write_checkpoint [file join $root reports synthesized.dcp]
 close_design
 puts "PRE6_R3_SYNTHESIS_COMPLETE kind=$kind"
 if {$kind eq "cpu"} {
  launch_simulation -mode post-synthesis -type functional
  log_wave -r /*
  run all
  close_sim
  puts "PRE6_R3_POST_SYNTH_COMPLETE"
 }
}
if {$kind eq "board" && $mode eq "full"} {
 launch_runs impl_1 -to_step write_bitstream -jobs 4
 wait_on_run impl_1
 if {[get_property PROGRESS [get_runs impl_1]] ne "100%"} {error "Implementation/bitstream did not complete"}
 open_run impl_1
 report_timing_summary -delay_type min_max -report_unconstrained -file [file join $root reports routed_timing.rpt]
 report_utilization -file [file join $root reports routed_utilization.rpt]
 report_drc -file [file join $root reports drc.rpt]
 set setup [get_property SLACK [get_timing_paths -delay_type max -max_paths 1]]
 set hold [get_property SLACK [get_timing_paths -delay_type min -max_paths 1]]
 if {$setup<0 || $hold<0} {error "Timing failed setup=$setup hold=$hold"}
 puts "PRE6_R3_IMPLEMENTATION_COMPLETE setup=$setup hold=$hold"
}
close_project
puts "PRE6_R3_FLOW_COMPLETE kind=$kind mode=$mode"
} message options]} {
 puts "PRE6_R3_FLOW_FAILED=$message"
 puts [dict get $options -errorinfo]
 catch {close_project}
 exit 1
}
exit 0
