@echo off
setlocal EnableExtensions
pushd "%~dp0" || exit /b 1
if not defined PRE4_VIVADO_BIN set "PRE4_VIVADO_BIN=C:\AMDDesignTools\2025.2\Vivado\bin"
set "PRE4_AUDIT_RTL=%~dp0..\Vivado\rtl"
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "%~dp0check_audit3.ps1" -Prepare
if errorlevel 1 goto fail
if not errorlevel 0 goto fail
call "%PRE4_VIVADO_BIN%\xvlog.bat" --sv "%PRE4_AUDIT_RTL%\cla4_pg.v" "%PRE4_AUDIT_RTL%\cla16.v" "%PRE4_AUDIT_RTL%\addsub16_cla.v" "%PRE4_AUDIT_RTL%\alu16.v" "%PRE4_AUDIT_RTL%\flags_reg.v" "%PRE4_AUDIT_RTL%\isa_decode.v" "%PRE4_AUDIT_RTL%\regfile4x16.v" "%PRE4_AUDIT_RTL%\pc16.v" "%PRE4_AUDIT_RTL%\imm_ext16.v" "%PRE4_AUDIT_RTL%\branch_target16.v" "%PRE4_AUDIT_RTL%\operand_forward.v" "%PRE4_AUDIT_RTL%\datapath_core.sv" "%PRE4_AUDIT_RTL%\sync_memories.v" tb_audit3.sv
if errorlevel 1 goto fail
if not errorlevel 0 goto fail
call "%PRE4_VIVADO_BIN%\xelab.bat" tb_audit3 -s audit3_sim -debug typical
if errorlevel 1 goto fail
if not errorlevel 0 goto fail
call "%PRE4_VIVADO_BIN%\xsim.bat" audit3_sim -tclbatch audit3_run_all.tcl -log audit3.log
if errorlevel 1 goto fail
if not errorlevel 0 goto fail
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "%~dp0check_audit3.ps1"
if errorlevel 1 goto fail
if not errorlevel 0 goto fail
popd
exit /b 0
:fail
popd
exit /b 1
