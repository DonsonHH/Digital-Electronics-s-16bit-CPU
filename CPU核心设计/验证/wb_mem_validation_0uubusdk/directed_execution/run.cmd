@echo off
call "C:\AMDDesignTools\2025.2\Vivado\bin\xvlog.bat" --sv -i . rtl/addsub16_cla.v rtl/alu16.v rtl/branch_target16.v rtl/cla16.v rtl/cla4_pg.v rtl/datapath_core.sv rtl/flags_reg.v rtl/imm_ext16.v rtl/isa_decode.v rtl/operand_forward.v rtl/pc16.v rtl/regfile4x16.v rtl/sync_memories.v tb_adversarial.sv
if errorlevel 1 exit /b 1
call "C:\AMDDesignTools\2025.2\Vivado\bin\xelab.bat" tb_adversarial -s candidate_sim -debug typical
if errorlevel 1 exit /b 1
call "C:\AMDDesignTools\2025.2\Vivado\bin\xsim.bat" candidate_sim -tclbatch run.tcl -log private.log
exit /b %errorlevel%
