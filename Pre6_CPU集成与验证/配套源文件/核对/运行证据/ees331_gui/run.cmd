@echo off
call C:\AMDDesignTools\2025.2\Vivado\bin\vivado.bat -mode gui -source bootstrap.tcl -log native.log -nojournal
exit /b %errorlevel%
