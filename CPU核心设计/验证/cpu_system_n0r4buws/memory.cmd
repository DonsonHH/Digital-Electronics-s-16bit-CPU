@echo off
call "C:\AMDDesignTools\2025.2\Vivado\bin\xsim.bat" memory_sim -tclbatch memory.tcl -log memory.log -wdb memory.wdb
exit /b %errorlevel%
