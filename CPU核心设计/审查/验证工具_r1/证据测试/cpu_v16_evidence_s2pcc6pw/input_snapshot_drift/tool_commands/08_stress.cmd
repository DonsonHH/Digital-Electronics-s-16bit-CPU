@echo off
call "C:\AMDDesignTools\2025.2\Vivado\bin\xsim.bat" stress_v16_sim -tclbatch run_all.tcl -log stress.log -wdb stress.wdb
exit /b %errorlevel%
