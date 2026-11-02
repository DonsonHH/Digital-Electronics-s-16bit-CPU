# Physical binding: user confirms only EES-331 USB/JTAG is connected.
# This writes volatile FPGA configuration only. No cfgmem/Flash or UART commands.
proc program_confirmed {} {
    set expected_target {localhost:3121/xilinx_tcf/Xilinx/1234-tulA}
    set expected_device {xc7z020_1}
    set bit [file normalize [file join [file dirname [info script]] .. ees331_led.bit]]
    if {![file isfile $bit]} { error "Reviewed bitstream missing" }
    if {[version -short] ne "2025.2"} { error "Expected Vivado2025.2" }
    open_hw_manager
    connect_hw_server -url localhost:3121
    set targets [get_hw_targets -quiet]
    if {[llength $targets] != 1 || [lindex $targets 0] ne $expected_target} {
        error "Hardware target set changed after physical confirmation: $targets"
    }
    current_hw_target [lindex $targets 0]
    open_hw_target
    set fpgas {}
    foreach device [get_hw_devices -quiet] {
        if {[get_property PART $device] eq "xc7z020"} { lappend fpgas $device }
    }
    if {[llength $fpgas] != 1 || [lindex $fpgas 0] ne $expected_device} {
        error "Expected exact inspected FPGA $expected_device, found $fpgas"
    }
    set device [lindex $fpgas 0]
    if {[get_property IDCODE_HEX $device] ne "23727093"} { error "Inspected IDCODE changed" }
    current_hw_device $device
    puts "LED_CONFIRMED_TARGET=[current_hw_target]"
    puts "LED_CONFIRMED_DEVICE=$device"
    puts "LED_CONFIRMED_BIT=$bit"
    set_property PROGRAM.FILE $bit $device
    puts "LED_PROGRAM_BEGIN"
    program_hw_devices $device
    puts "LED_PROGRAM_RETURNED"
    refresh_hw_device $device
    report_property $device
    set usr [string toupper [get_property REGISTER.USR_ACCESS $device]]
    set done [get_property {REGISTER.CONFIG_STATUS.BIT13_DONE_INTERNAL_SIGNAL_STATUS} $device]
    set eos [get_property {REGISTER.CONFIG_STATUS.BIT04_END_OF_STARTUP_(EOS)_STATUS} $device]
    set crc_error [get_property {REGISTER.CONFIG_STATUS.BIT00_CRC_ERROR} $device]
    set f [open program.tsv w]
    puts $f "target\t[current_hw_target]"
    puts $f "device\t$device"
    puts $f "usr_access\t$usr"
    puts $f "done\t$done"
    puts $f "eos\t$eos"
    puts $f "crc_error\t$crc_error"
    close $f
    if {$usr ne "15B4E958" || $done ne "1" || $eos ne "1" || $crc_error ne "0"} {
        error "Post-program configuration mismatch usr=$usr done=$done eos=$eos crc=$crc_error"
    }
    puts "LED_PROGRAM_CONFIGURATION_VERIFIED"
    close_hw_target
    disconnect_hw_server
    close_hw_manager
}
if {[catch {program_confirmed} message options]} {
    puts stderr "LED_CONFIRMED_PROGRAM_FAILED=$message"
    puts stderr [dict get $options -errorinfo]
    exit 1
}
puts "LED_CONFIRMED_PROGRAM_COMPLETE"
exit 0
