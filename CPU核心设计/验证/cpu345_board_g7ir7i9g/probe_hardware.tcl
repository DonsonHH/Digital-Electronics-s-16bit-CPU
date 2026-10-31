# Read-only cable/device inventory. Never configures FPGA or PS.
if {[catch {
    open_hw_manager
    connect_hw_server -url localhost:3121
    set targets [get_hw_targets]
    puts "HW_SCAN_TARGET_COUNT=[llength $targets]"
    foreach target $targets {
        puts "HW_SCAN_TARGET=$target"
        open_hw_target $target
        foreach device [get_hw_devices] {
            puts "HW_SCAN_DEVICE=$device PART=[get_property PART $device]"
        }
        close_hw_target $target
    }
    disconnect_hw_server
    close_hw_manager
} message options]} {
    puts "HW_SCAN_FAILED=$message"
    exit 1
}
puts "HW_SCAN_COMPLETE read_only=1"
exit
