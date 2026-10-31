@echo off
call "C:\AMDDesignTools\2025.2\Vivado\bin\xsim.bat" selected_sim -tclbatch sim.tcl -log selected.log -wdb selected.wdb
exit /b %errorlevel%
