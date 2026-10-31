@echo off
call "C:\AMDDesignTools\2025.2\Vivado\bin\xvlog.bat" --sv rtl/addsub16_cla.v rtl/alu16.v rtl/branch_target16.v rtl/cla16.v rtl/cla4_pg.v rtl/cpu_system.sv rtl/datapath_core.sv rtl/ees331_application.sv rtl/ees331_top.sv rtl/flags_reg.v rtl/imm_ext16.v rtl/isa_decode.v rtl/operand_forward.v rtl/pc16.v rtl/regfile4x16.v rtl/sync_memories.v tb/tb_board_application.sv
exit /b %errorlevel%
