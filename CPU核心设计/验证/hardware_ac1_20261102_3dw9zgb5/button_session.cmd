@echo off
call "C:\AMDDesignTools\2025.2\Vivado\bin\vivado.bat" -mode batch -source button_session.tcl -log button_session.log -journal button_session.jou
exit /b %errorlevel%
