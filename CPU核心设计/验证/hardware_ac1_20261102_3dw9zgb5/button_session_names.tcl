# Read-only VIO observation. Reset is requested only by the human pressing PL S1.
proc button_sample {vio state_probe perf_probe channel label} {
    refresh_hw_vio $vio
    set state [get_property INPUT_VALUE $state_probe]
    set perf [get_property INPUT_VALUE $perf_probe]
    puts $channel "$label\t[clock milliseconds]\t$state\t$perf"
    flush $channel
    return [list [expr 0x$state] [expr 0x$perf]]
}
proc observe_button {} {
    set expected_target {localhost:3121/xilinx_tcf/Xilinx/1234-tulA}
    if {[version -short] ne "2025.2"} {error "Expected Vivado2025.2"}
    open_hw_manager
    connect_hw_server -url localhost:3121
    set targets [get_hw_targets -quiet]
    if {[llength $targets]!=1 || [lindex $targets 0] ne $expected_target} {error "Physical target set changed"}
    current_hw_target [lindex $targets 0]
    open_hw_target
    set devices [get_hw_devices -filter {PART == xc7z020}]
    if {[llength $devices]!=1} {error "Expected one selected xc7z020"}
    set device [lindex $devices 0]
    set ltx [file normalize [file join [file dirname [info script]] .. cpu345_board_5prio5st output debug.ltx]]
    set_property PROBES.FILE $ltx $device
    refresh_hw_device $device
    set vio [get_hw_vios -of_objects $device]
    if {[llength $vio]!=1} {error "Expected one VIO"}
    set state_probe [get_hw_probes {state_probe} -of_objects $vio]
    set perf_probe [get_hw_probes {perf_probe} -of_objects $vio]
    set reset_probe [get_hw_probes {debug_reset} -of_objects $vio]
    if {[llength $state_probe]!=1 || [llength $perf_probe]!=1 || [llength $reset_probe]!=1} {error "Expected state/performance/reset probes"}
    refresh_hw_vio $vio
    if {[expr 0x[get_property OUTPUT_VALUE $reset_probe]]!=0} {error "VIO reset must already be released"}
    set capture [open button_snapshots.tsv w]
    lassign [button_sample $vio $state_probe $perf_probe $capture before] state perf
    if {($state >> 192)!=0x22b2a23f057c652b || (($state>>86)&1)!=1 || (($state>>140)&1)!=0} {error "Expected stopped copy_checksum image before button test"}
    puts "BUTTON_LISTEN_READY"
    flush stdout
    set pressed 0
    set deadline [expr [clock milliseconds]+90000]
    while {[clock milliseconds]<$deadline} {
        after 100
        refresh_hw_vio $vio
        set state [expr 0x[get_property INPUT_VALUE $state_probe]]
        if {(($state>>140)&1)==1} {set pressed 1;break}
    }
    if {!$pressed} {error "No physical S1 press observed before timeout"}
    lassign [button_sample $vio $state_probe $perf_probe $capture pressed] state perf
    if {($state >> 192)!=0x22b2a23f057c652b || ($state&0x7ffffffffffffffff)!=0 || (($state>>86)&31)!=0 || (($state>>107)&1)!=0 || $perf!=0} {error "Reset did not clear RF/flags/stop/counters"}
    puts "BUTTON_PRESS_AND_RESET_OBSERVED"
    flush stdout
    set stopped 0
    set deadline [expr [clock milliseconds]+15000]
    while {[clock milliseconds]<$deadline} {
        after 100
        refresh_hw_vio $vio
        set state [expr 0x[get_property INPUT_VALUE $state_probe]]
        if {(($state>>140)&1)==0 && (($state>>86)&1)==1} {set stopped 1;break}
    }
    if {!$stopped} {error "No normal stop after S1 release"}
    button_sample $vio $state_probe $perf_probe $capture after_0
    after 100
    button_sample $vio $state_probe $perf_probe $capture after_1
    close $capture
    close_hw_target
    disconnect_hw_server
    close_hw_manager
    puts "BUTTON_PHYSICAL_RESET_OBSERVATION_COMPLETE"
}
if {[catch {observe_button} message options]} {
    puts stderr "BUTTON_SESSION_FAILED=$message"
    puts stderr [dict get $options -errorinfo]
    exit 1
}
exit 0
