@echo off
call "C:\AMDDesignTools\2025.2\Vivado\bin\xsim.bat" mapped_sim -tclbatch mapped.tcl -log mapped.log -wdb mapped.wdb
exit /b %errorlevel%
