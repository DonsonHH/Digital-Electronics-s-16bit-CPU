@echo off
setlocal EnableExtensions
pushd "%~dp0" || exit /b 1
if not defined CPU_VIVADO_BIN set "CPU_VIVADO_BIN=C:\AMDDesignTools\2025.2\Vivado\bin"
call "%CPU_VIVADO_BIN%\vivado.bat" -mode batch -source synth_ooc.tcl -log synthesis.log -nojournal
if errorlevel 1 goto fail
if not errorlevel 0 goto fail
popd
exit /b 0
:fail
popd
exit /b 1
