@echo off
call "C:\AMDDesignTools\2025.2\Vivado\bin\xsim.bat" trace_v16_sim -tclbatch trace.tcl -log trace.log -wdb trace.wdb
exit /b %errorlevel%
