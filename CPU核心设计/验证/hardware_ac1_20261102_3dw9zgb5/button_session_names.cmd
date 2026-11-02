@echo off
call "C:\AMDDesignTools\2025.2\Vivado\bin\vivado.bat" -mode batch -source button_session_names.tcl -log button_session_names.log -journal button_session_names.jou
exit /b %errorlevel%
