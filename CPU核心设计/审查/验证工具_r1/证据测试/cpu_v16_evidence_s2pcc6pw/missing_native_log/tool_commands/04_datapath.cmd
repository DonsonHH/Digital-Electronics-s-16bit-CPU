@echo off
call "C:\AMDDesignTools\2025.2\Vivado\bin\xsim.bat" datapath_v16_sim -tclbatch sim.tcl -log datapath.log -wdb datapath.wdb
exit /b %errorlevel%
