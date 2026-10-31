@echo off
setlocal EnableExtensions
pushd "%~dp0" || exit /b 1
if not defined CPU_VIVADO_BIN (
 echo ERROR: Set CPU_VIVADO_BIN or use run_verify.ps1 for resolved configuration.
 popd
 exit /b 2
)
call "%CPU_VIVADO_BIN%\xvlog.bat" --sv -i tb rtl/cla4_pg.v rtl/cla16.v rtl/addsub16_cla.v rtl/alu16.v rtl/flags_reg.v rtl/isa_decode.v rtl/regfile4x16.v rtl/pc16.v rtl/imm_ext16.v rtl/branch_target16.v rtl/operand_forward.v rtl/datapath_core.sv rtl/sync_memories.v tb/tb_isa_contract.sv tb/tb_datapath.sv tb/tb_units.sv tb/tb_stress.sv tb/tb_audit3.sv tb/tb_hazards.sv tb/tb_uniform_smoke.sv tb/tb_forward_contract.sv tb/tb_trace.sv
if errorlevel 1 goto fail
if not errorlevel 0 goto fail
call :suite tb_isa_contract contract contract_v16_sim run_all.tcl
if errorlevel 1 goto fail
call :suite tb_datapath datapath datapath_v16_sim sim.tcl
if errorlevel 1 goto fail
call :suite tb_units units units_v16_sim run_all.tcl
if errorlevel 1 goto fail
call :suite tb_stress stress stress_v16_sim run_all.tcl
if errorlevel 1 goto fail
call :suite tb_audit3 audit audit_v16_sim run_all.tcl
if errorlevel 1 goto fail
call :suite tb_uniform_smoke uniform uniform_v16_sim run_all.tcl
if errorlevel 1 goto fail
call :suite tb_forward_contract forward forward_v16_sim run_all.tcl
if errorlevel 1 goto fail
call :suite tb_trace trace trace_v16_sim trace.tcl
if errorlevel 1 goto fail
call :suite tb_hazards hazards hazards_v16_sim run_all.tcl
if errorlevel 1 goto fail
popd
exit /b 0
:suite
call "%CPU_VIVADO_BIN%\xelab.bat" %1 -s %3 -debug typical
if errorlevel 1 exit /b 1
if not errorlevel 0 exit /b 1
call "%CPU_VIVADO_BIN%\xsim.bat" %3 -tclbatch %4 -log %2.log -wdb %2.wdb
if errorlevel 1 exit /b 1
if not errorlevel 0 exit /b 1
exit /b 0
:fail
popd
exit /b 1
