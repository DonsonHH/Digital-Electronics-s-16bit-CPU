@echo off
call "C:\AMDDesignTools\2025.2\Vivado\bin\xsim.bat" hazards_v16_sim -tclbatch run_all.tcl -log hazards.log -wdb hazards.wdb
exit /b %errorlevel%
