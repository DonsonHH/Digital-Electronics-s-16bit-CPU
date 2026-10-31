open_vcd modules.vcd
log_vcd /tb_modules/*
run 300 ns
close_vcd
run all
quit
