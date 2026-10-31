@echo off
call "C:\AMDDesignTools\2025.2\Vivado\bin\vivado.bat" -mode batch -source synth_system.tcl -log synthesis.log -nojournal
exit /b %errorlevel%
