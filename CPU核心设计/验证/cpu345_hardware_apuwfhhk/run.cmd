@echo off
call "C:\AMDDesignTools\2025.2\Vivado\bin\vivado.bat" -mode batch -source hardware_session.tcl -log hardware.log -nojournal
exit /b %errorlevel%
