@echo off
call "C:\AMDDesignTools\2025.2\Vivado\bin\xvlog.bat" --sv -i tb rtl/cla4_pg.v rtl/cla16.v rtl/addsub16_cla.v rtl/alu16.v rtl/flags_reg.v rtl/isa_decode.v rtl/regfile4x16.v rtl/pc16.v rtl/imm_ext16.v rtl/branch_target16.v rtl/operand_forward.v rtl/datapath_core.sv rtl/sync_memories.v tb/tb_isa_contract.sv tb/tb_datapath.sv tb/tb_units.sv tb/tb_stress.sv tb/tb_audit3.sv tb/tb_uniform_smoke.sv tb/tb_forward_contract.sv tb/tb_trace.sv tb/tb_hazards.sv
exit /b %errorlevel%
