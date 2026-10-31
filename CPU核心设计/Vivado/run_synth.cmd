@echo off
setlocal EnableExtensions
pushd "%~dp0" || exit /b 1
if not defined CPU_VIVADO_BIN (
 echo ERROR: Set CPU_VIVADO_BIN or use run_synthesis.ps1 for resolved configuration.
 popd
 exit /b 2
)
call "%CPU_VIVADO_BIN%\vivado.bat" -mode batch -source synth_ooc.tcl -log synthesis.log -nojournal
if errorlevel 1 goto fail
if not errorlevel 0 goto fail
popd
exit /b 0
:fail
popd
exit /b 1
