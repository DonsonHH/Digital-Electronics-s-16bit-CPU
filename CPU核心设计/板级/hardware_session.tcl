# Invoked only by the explicit confirmed-board host entry. No first-target guess.
proc cpu_hardware_session {} {
global env
if {[version -short] ne "2025.2"} {error "Pinned Vivado2025.2 required"}
if {$env(CPU_CONFIRMED_BOARD) ne "EES-331"} {error "Physical board confirmation missing"}
open_hw_manager
connect_hw_server -url localhost:3121
set target [get_hw_targets $env(CPU_HW_TARGET)]
if {[llength $target]!=1 || "$target" ne $env(CPU_HW_TARGET)} {error "Exact selected target not found"}
current_hw_target $target
set_property PARAM.FREQUENCY 6000000 $target
open_hw_target $target
set device [get_hw_devices -filter {PART == xc7z020}]
if {[llength $device]!=1} {error "Expected one selected xc7z020 device"}
current_hw_device $device
set_property PROBES.FILE $env(CPU_HW_LTX) $device
if {$env(CPU_HW_PROGRAM)==1} {
 set_property PROGRAM.FILE $env(CPU_HW_BIT) $device
 puts "HARDWARE_PROGRAM_REQUESTED"
 program_hw_devices $device
 puts "HARDWARE_DEVICE_PROGRAMMED"
}
refresh_hw_device $device
set vio [get_hw_vios -of_objects $device]
if {[llength $vio]!=1} {error "Expected one VIO"}
set state_probe [get_hw_probes $env(CPU_HW_STATE_NET) -of_objects $vio]
set perf_probe [get_hw_probes $env(CPU_HW_PERF_NET) -of_objects $vio]
set reset_probe [get_hw_probes $env(CPU_HW_RESET_NET) -of_objects $vio]
if {[llength $state_probe]!=1 || [llength $perf_probe]!=1 || [llength $reset_probe]!=1} {error "Expected state/perf/reset probes missing"}
refresh_hw_vio $vio
set state_value [get_property INPUT_VALUE $state_probe]
puts "HARDWARE_INITIAL_STATE=$state_value"
# Guard wrong/stale images BEFORE writing the CPU reset control.
set initial_number [expr 0x$state_value]
set expected_build_id [expr 0x$env(CPU_HW_BUILD_ID)]
if {($initial_number >> 192) != $expected_build_id} {error "Programmed build identity differs"}
if {$env(CPU_HW_RUN)==1} {
 set_property OUTPUT_VALUE 1 $reset_probe
 commit_hw_vio $reset_probe
 puts "HARDWARE_RESET_ASSERTED"
 after 100
 refresh_hw_vio $vio
 set reset_state [expr 0x[get_property INPUT_VALUE $state_probe]]
 if {(($reset_state>>140)&1)!=1} {error "CPU reset not observed"}
 set_property OUTPUT_VALUE 0 $reset_probe
 commit_hw_vio $reset_probe
 puts "HARDWARE_RESET_RELEASED"
 set stopped 0
 for {set i 0} {$i<200} {incr i} {
  after 10
  refresh_hw_vio $vio
  set current [expr 0x[get_property INPUT_VALUE $state_probe]]
  if {(($current>>86)&1)==1} {set stopped 1;break}
 }
 if {!$stopped} {error "CPU did not reach a stable stop"}
}
set capture [open snapshots.tsv w]
for {set i 0} {$i<2} {incr i} {
 refresh_hw_vio $vio
 puts $capture "$i\t[get_property INPUT_VALUE $state_probe]\t[get_property INPUT_VALUE $perf_probe]"
 after 20
}
close $capture
close_hw_target $target
disconnect_hw_server
close_hw_manager
puts "HARDWARE_CAPTURE_COMPLETE attempt=$env(CPU_HW_ATTEMPT)"
}
if {[catch {cpu_hardware_session} message options]} {
 puts "HARDWARE_SESSION_FAILED=$message"
 exit 1
}
exit
