@echo off
call "C:\AMDDesignTools\2025.2\Vivado\bin\xsim.bat" uniform_v16_sim -tclbatch run_all.tcl -log uniform.log -wdb uniform.wdb
exit /b %errorlevel%
