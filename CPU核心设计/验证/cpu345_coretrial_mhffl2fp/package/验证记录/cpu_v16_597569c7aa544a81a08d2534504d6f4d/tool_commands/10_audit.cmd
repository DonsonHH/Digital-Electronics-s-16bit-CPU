@echo off
call "C:\AMDDesignTools\2025.2\Vivado\bin\xsim.bat" audit_v16_sim -tclbatch run_all.tcl -log audit.log -wdb audit.wdb
exit /b %errorlevel%
