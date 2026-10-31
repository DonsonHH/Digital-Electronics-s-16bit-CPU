@echo off
call "C:\AMDDesignTools\2025.2\Vivado\bin\xsim.bat" contract_v16_sim -tclbatch run_all.tcl -log contract.log -wdb contract.wdb
exit /b %errorlevel%
