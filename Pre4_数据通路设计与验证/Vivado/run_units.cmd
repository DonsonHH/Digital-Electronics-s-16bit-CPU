@echo off
setlocal EnableExtensions
pushd "%~dp0" || exit /b 1
if not defined PRE4_VIVADO_BIN set "PRE4_VIVADO_BIN=C:\AMDDesignTools\2025.2\Vivado\bin"
call "%~dp0archive_results.cmd" units.log unit_results.json
if errorlevel 1 goto fail
if not errorlevel 0 goto fail
call compile_sources.cmd
if errorlevel 1 goto fail
if not errorlevel 0 goto fail
call "%PRE4_VIVADO_BIN%\xelab.bat" tb_units -s units_sim -debug typical
if errorlevel 1 goto fail
if not errorlevel 0 goto fail
call "%PRE4_VIVADO_BIN%\xsim.bat" units_sim -tclbatch run_all.tcl -log units.log
if errorlevel 1 goto fail
if not errorlevel 0 goto fail
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "%~dp0check_log.ps1" -Suite units
if errorlevel 1 goto fail
if not errorlevel 0 goto fail
findstr /I /L /C:"Fatal:" /C:"FATAL_ERROR" /C:"ERROR:" units.log >nul
if not errorlevel 1 goto fail
call "%~dp0check_receipts.cmd" unit_results.json
if errorlevel 1 goto fail
if not errorlevel 0 goto fail
popd
exit /b 0
:fail
popd
exit /b 1
