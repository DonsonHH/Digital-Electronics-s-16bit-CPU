open_vcd datapath.vcd
log_vcd /tb_datapath/dut/core/*
log_vcd /tb_datapath/dut/*
log_vcd /tb_datapath/clk /tb_datapath/rst
log_wave -r /tb_datapath/dut/core/*
run all
close_vcd
quit
