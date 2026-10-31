set task_dir [file dirname [file normalize [info script]]]
open_wave_database [file join $task_dir display.wdb]
create_wave_config
add_wave /tb_modules/clk /tb_modules/rst_rf /tb_modules/we /tb_modules/wa /tb_modules/wd /tb_modules/qa /tb_modules/qb
add_wave /tb_modules/a /tb_modules/b /tb_modules/op /tb_modules/result /tb_modules/eq /tb_modules/illegal
add_wave /tb_modules/rst_pc /tb_modules/hold /tb_modules/redirect /tb_modules/target /tb_modules/pc
add_wave /tb_modules/imm /tb_modules/sign_mode /tb_modules/extended
