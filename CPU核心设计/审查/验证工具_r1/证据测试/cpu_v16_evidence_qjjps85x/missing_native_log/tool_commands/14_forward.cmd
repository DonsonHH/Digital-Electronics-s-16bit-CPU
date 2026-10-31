@echo off
call "C:\AMDDesignTools\2025.2\Vivado\bin\xsim.bat" forward_v16_sim -tclbatch run_all.tcl -log forward.log -wdb forward.wdb
exit /b %errorlevel%
