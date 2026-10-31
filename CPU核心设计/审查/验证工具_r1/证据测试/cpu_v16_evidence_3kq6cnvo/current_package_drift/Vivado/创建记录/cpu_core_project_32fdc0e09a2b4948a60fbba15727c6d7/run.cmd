@echo off
call "C:\AMDDesignTools\2025.2\Vivado\bin\vivado.bat" -mode batch -source entry.tcl -log create.log -nojournal
exit /b %errorlevel%
