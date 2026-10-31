@echo off
setlocal EnableExtensions
pushd "%~dp0" || exit /b 1
if not defined PRE4_VIVADO_BIN set "PRE4_VIVADO_BIN=C:\AMDDesignTools\2025.2\Vivado\bin"
call "%~dp0archive_results.cmd" datapath.log case_results.csv baseline_trace.csv case_timings.csv datapath.vcd datapath.wdb
if errorlevel 1 goto fail
if not errorlevel 0 goto fail
call compile_sources.cmd
if errorlevel 1 goto fail
if not errorlevel 0 goto fail
call "%PRE4_VIVADO_BIN%\xelab.bat" tb_datapath -s pre4_sim -debug typical
if errorlevel 1 goto fail
if not errorlevel 0 goto fail
call "%PRE4_VIVADO_BIN%\xsim.bat" pre4_sim -tclbatch sim.tcl -wdb datapath.wdb -log datapath.log
if errorlevel 1 goto fail
if not errorlevel 0 goto fail
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "%~dp0check_log.ps1" -Suite datapath
if errorlevel 1 goto fail
if not errorlevel 0 goto fail
findstr /I /L /C:"Fatal:" /C:"FATAL_ERROR" /C:"ERROR:" datapath.log >nul
if not errorlevel 1 goto fail
call "%~dp0check_receipts.cmd" case_results.csv baseline_trace.csv case_timings.csv datapath.vcd datapath.wdb
if errorlevel 1 goto fail
if not errorlevel 0 goto fail
popd
exit /b 0
:fail
popd
exit /b 1
