@echo off
call "C:\AMDDesignTools\2025.2\Vivado\bin\xsim.bat" units_v16_sim -tclbatch run_all.tcl -log units.log -wdb units.wdb
exit /b %errorlevel%
