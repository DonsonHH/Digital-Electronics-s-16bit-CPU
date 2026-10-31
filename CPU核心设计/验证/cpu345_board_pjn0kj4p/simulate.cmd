@echo off
call "C:\AMDDesignTools\2025.2\Vivado\bin\xsim.bat" board_sim -tclbatch sim.tcl -log simulation.log -wdb simulation.wdb
exit /b %errorlevel%
