@echo off
call "C:\AMDDesignTools\2025.2\Vivado\bin\xelab.bat" tb_cpu_system -s system_sim -debug typical
exit /b %errorlevel%
