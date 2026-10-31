# vtools-r1: correlation is additional to actual executor process records.
if {[info exists ::env(CPU_VERIFY_ATTEMPT_ID)] && [info exists ::env(CPU_VERIFY_INPUT_SHA256)]} {
 puts "CPU_VERIFY_ATTEMPT id=$::env(CPU_VERIFY_ATTEMPT_ID) input_sha256=$::env(CPU_VERIFY_INPUT_SHA256)"
} else {
 puts "CPU_VERIFY_UNBOUND_RUN new_execution_receipt_not_authorized"
}
open_vcd interlock.vcd
log_vcd /tb_trace/test/dut/core/*
log_vcd /tb_trace/test/dut/*
log_vcd /tb_trace/test/clk /tb_trace/test/rst
run all
close_vcd
quit
