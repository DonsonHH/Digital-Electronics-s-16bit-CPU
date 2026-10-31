@echo off
call "C:\AMDDesignTools\2025.2\Vivado\bin\xvlog.bat" --sv -i tb rtl/addsub16_cla.v rtl/alu16.v rtl/branch_target16.v rtl/cla16.v rtl/cla4_pg.v rtl/datapath_core.sv rtl/flags_reg.v rtl/imm_ext16.v rtl/isa_decode.v rtl/operand_forward.v rtl/pc16.v rtl/regfile4x16.v rtl/sync_memories.v tb/tb_audit3.sv tb/tb_datapath.sv tb/tb_forward_contract.sv tb/tb_hazards.sv tb/tb_isa_contract.sv tb/tb_stress.sv tb/tb_trace.sv tb/tb_uniform_smoke.sv tb/tb_units.sv 
if errorlevel 1 exit /b 1
call "C:\AMDDesignTools\2025.2\Vivado\bin\xelab.bat" tb_stress -s private_sim -debug typical
if errorlevel 1 exit /b 1
call "C:\AMDDesignTools\2025.2\Vivado\bin\xsim.bat" private_sim -tclbatch run.tcl -log private.log
if errorlevel 1 exit /b 1
exit /b 0
