proc inspect_current {} {
    puts "LED_CURRENT_VIVADO=[version -short]"
    open_hw_manager
    connect_hw_server -url localhost:3121
    set targets [get_hw_targets -quiet]
    puts "LED_CURRENT_TARGET_COUNT=[llength $targets]"
    foreach t $targets { puts "LED_CURRENT_TARGET=$t" }
    if {[llength $targets] != 1} { error "Exactly one physically confirmed EES-331 target is required" }
    set target [lindex $targets 0]
    current_hw_target $target
    open_hw_target
    puts "LED_CURRENT_OPEN_TARGET=[current_hw_target]"
    set f [open inspect.tsv w]
    puts $f "target\t$target"
    set fpga_count 0
    foreach device [get_hw_devices -quiet] {
        set part [get_property PART $device]
        puts "LED_CURRENT_DEVICE=$device PART=$part"
        puts $f "device\t$device\t$part"
        if {$part eq "xc7z020"} {
            incr fpga_count
            current_hw_device $device
            report_property $device
            puts $f "fpga\t$device\t[get_property IDCODE_HEX $device]\t[get_property REGISTER.USR_ACCESS $device]"
        }
    }
    close $f
    if {$fpga_count != 1} { error "Expected exactly one xc7z020 FPGA" }
    close_hw_target
    disconnect_hw_server
    close_hw_manager
    puts "LED_CURRENT_INSPECT_COMPLETE"
}
if {[catch {inspect_current} message options]} {
    puts stderr "LED_CURRENT_INSPECT_FAILED=$message"
    puts stderr [dict get $options -errorinfo]
    exit 1
}
exit 0
