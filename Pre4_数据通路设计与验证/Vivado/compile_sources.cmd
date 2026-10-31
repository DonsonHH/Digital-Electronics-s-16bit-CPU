@echo off
setlocal EnableExtensions
pushd "%~dp0" || exit /b 1
if not defined PRE4_VIVADO_BIN set "PRE4_VIVADO_BIN=C:\AMDDesignTools\2025.2\Vivado\bin"
call "%PRE4_VIVADO_BIN%\xvlog.bat" --sv rtl/cla4_pg.v rtl/cla16.v rtl/addsub16_cla.v rtl/alu16.v rtl/flags_reg.v rtl/isa_decode.v rtl/regfile4x16.v rtl/pc16.v rtl/imm_ext16.v rtl/branch_target16.v rtl/operand_forward.v rtl/datapath_core.sv rtl/sync_memories.v tb/tb_datapath.sv tb/tb_units.sv
if errorlevel 1 goto fail
if not errorlevel 0 goto fail
if not exist tb\tb_stress.sv goto compiled
call "%PRE4_VIVADO_BIN%\xvlog.bat" --sv tb/tb_stress.sv
if errorlevel 1 goto fail
if not errorlevel 0 goto fail
:compiled
popd
exit /b 0
:fail
popd
exit /b 1
