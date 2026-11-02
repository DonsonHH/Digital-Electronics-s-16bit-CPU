@echo off
call "C:\AMDDesignTools\2025.2\Vivado\bin\vivado.bat" -mode batch -source button_session_long.tcl -log button_session_long.log -journal button_session_long.jou
exit /b %errorlevel%
