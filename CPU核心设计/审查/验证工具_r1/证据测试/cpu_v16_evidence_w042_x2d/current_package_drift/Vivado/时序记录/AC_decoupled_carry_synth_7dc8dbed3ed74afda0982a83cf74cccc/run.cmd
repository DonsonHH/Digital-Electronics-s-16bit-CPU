@echo off
call "C:\AMDDesignTools\2025.2\Vivado\bin\vivado.bat" -mode batch -source timing.tcl -log vivado.log -nojournal
exit /b %errorlevel%
