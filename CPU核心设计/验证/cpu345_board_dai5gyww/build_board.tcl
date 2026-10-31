# Full board implementation, fixed strategy; no physical programming here.
if {[catch {
set root [file dirname [file normalize [info script]]]
cd $root
create_project ees331 ./project -part xc7z020clg484-1
set_param general.maxThreads 4
set_property target_language Verilog [current_project]
set_property simulator_language Mixed [current_project]
add_files -norecurse [concat [glob rtl/*.v] [glob rtl/*.sv]]
add_files -norecurse [list programs/dut_im.mem programs/dut_dm.mem]
create_ip -name vio -vendor xilinx.com -library ip -version 3.0 -module_name ees331_vio
set_property -dict [list CONFIG.C_NUM_PROBE_IN {2} CONFIG.C_PROBE_IN0_WIDTH {256} CONFIG.C_PROBE_IN1_WIDTH {160} CONFIG.C_NUM_PROBE_OUT {1} CONFIG.C_PROBE_OUT0_WIDTH {1} CONFIG.C_PROBE_OUT0_INIT_VAL {0x1} CONFIG.C_EN_PROBE_IN_ACTIVITY {0}] [get_ips ees331_vio]
generate_target all [get_ips ees331_vio]
add_files -fileset constrs_1 -norecurse constraints/ees331.xdc
add_files -fileset constrs_1 -norecurse constraints/human_io.xdc
set_property USED_IN_SYNTHESIS false [get_files *human_io.xdc]
set_property top ees331_top [get_filesets sources_1]
set_property generic "BUILD_ID=64'h$env(CPU_BOARD_BUILD_ID)" [get_filesets sources_1]
update_compile_order -fileset sources_1
launch_runs synth_1 -jobs 4
wait_on_run synth_1
if {[get_property PROGRESS [get_runs synth_1]] ne "100%"} {error "Board synthesis failed"}
open_run synth_1
if {[llength [get_pins -hier -filter {NAME =~ */release_sync_reg*/PRE}]]!=3} {error "Expected3 asynchronous reset synchronizer PRE pins"}
file mkdir reports
report_utilization -hierarchical -file reports/post_synth_utilization.rpt
launch_runs impl_1 -to_step route_design -jobs 4
wait_on_run impl_1
if {[get_property PROGRESS [get_runs impl_1]] ne "100%"} {error "Board routing failed"}
open_run impl_1
report_timing_summary -delay_type min_max -report_unconstrained -max_paths 10 -file reports/timing.rpt
report_timing -delay_type max -max_paths 10 -path_type full_clock_expanded -file reports/setup_paths.rpt
report_timing -delay_type min -max_paths 10 -path_type full_clock_expanded -file reports/hold_paths.rpt
report_utilization -hierarchical -file reports/utilization.rpt
report_drc -file reports/drc.rpt
check_timing -verbose -file reports/check_timing.rpt
report_exceptions -file reports/exceptions.rpt
report_clock_utilization -file reports/clocks.rpt
report_io -file reports/io.rpt
file mkdir output
write_checkpoint output/routed.dcp
write_debug_probes output/debug.ltx
set setup [get_property SLACK [get_timing_paths -delay_type max -max_paths 1]]
set hold [get_property SLACK [get_timing_paths -delay_type min -max_paths 1]]
if {$setup<0 || $hold<0} {error "Board timing not met setup=$setup hold=$hold"}
write_bitstream output/ees331.bit
set lut [llength [get_cells -hier -filter {REF_NAME =~ LUT*}]]
set ff [llength [get_cells -hier -filter {REF_NAME =~ FD*}]]
set bram [llength [get_cells -hier -filter {REF_NAME =~ RAMB*}]]
set carry [llength [get_cells -hier -filter {REF_NAME =~ CARRY*}]]
set output [open reports/implementation.json w]
puts $output "{\"build_id\":\"$env(CPU_BOARD_BUILD_ID)\",\"tool\":\"[version -short]\",\"part\":\"xc7z020clg484-1\",\"top\":\"ees331_top\",\"period_ns\":10,\"wns_ns\":$setup,\"whs_ns\":$hold,\"lut\":$lut,\"ff\":$ff,\"bram18_primitives\":$bram,\"carry4\":$carry,\"placed_and_routed\":true,\"board_validated\":false}"
close $output
puts "BOARD_IMPLEMENTATION_COMPLETE attempt=$env(CPU_BOARD_ATTEMPT) build_id=$env(CPU_BOARD_BUILD_ID) scope=routed_design_not_physical_validation"
} message options]} {
    puts "BOARD_BUILD_FAILED=$message"
    puts [dict get $options -errorinfo]
    exit 1
}
exit
