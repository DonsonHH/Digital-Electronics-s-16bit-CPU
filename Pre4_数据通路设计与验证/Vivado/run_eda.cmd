@echo off
setlocal EnableExtensions
pushd "%~dp0" || exit /b 1
if not defined PRE4_VIVADO_BIN set "PRE4_VIVADO_BIN=C:\AMDDesignTools\2025.2\Vivado\bin"
if not exist eda.log goto analyze
set "PRE4_EDA_ARCHIVE=previous_runs\eda_%RANDOM%_%RANDOM%"
mkdir "%PRE4_EDA_ARCHIVE%"
if errorlevel 1 goto fail
if not errorlevel 0 goto fail
move eda.log "%PRE4_EDA_ARCHIVE%\eda.log" >nul
if errorlevel 1 goto fail
if not errorlevel 0 goto fail
:analyze
call "%~dp0archive_results.cmd" --eda rtl_core.pdf rtl_alu.pdf rtl_cla16.pdf rtl_cla4.pdf rtl_forward.pdf rtl_flags.pdf mapped_core.pdf core_synth.dcp core_netlist.v utilization.rpt post_synth_timing.rpt
if errorlevel 1 goto fail
if not errorlevel 0 goto fail
call "%PRE4_VIVADO_BIN%\vivado.bat" -mode batch -source eda.tcl -log eda.log -nojournal
if errorlevel 1 goto fail
if not errorlevel 0 goto fail
findstr /B /L /C:"PRE4_EDA_PASS tool=" eda.log >nul
if errorlevel 1 goto fail
if not errorlevel 0 goto fail
findstr /I /C:"ERROR:" /C:"CRITICAL WARNING:" eda.log >nul
if not errorlevel 1 goto fail
for %%F in (rtl_core.pdf rtl_alu.pdf rtl_cla16.pdf rtl_cla4.pdf rtl_forward.pdf rtl_flags.pdf mapped_core.pdf core_synth.dcp core_netlist.v utilization.rpt post_synth_timing.rpt) do (
 call :checkfile "eda\%%F"
 if errorlevel 1 goto fail
 if not errorlevel 0 goto fail
)
popd
exit /b 0
:fail
popd
exit /b 1
:checkfile
if not exist "%~1" exit /b 1
set "PRE4_ARTIFACT_ATTR=%~a1"
if "%PRE4_ARTIFACT_ATTR:~0,1%"=="d" exit /b 1
if "%~z1"=="" exit /b 1
if %~z1 LEQ 0 exit /b 1
exit /b 0
