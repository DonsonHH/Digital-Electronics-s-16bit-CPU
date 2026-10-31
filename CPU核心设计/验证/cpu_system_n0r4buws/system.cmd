@echo off
call "C:\AMDDesignTools\2025.2\Vivado\bin\xsim.bat" system_sim -tclbatch system.tcl -log system.log -wdb system.wdb
exit /b %errorlevel%
