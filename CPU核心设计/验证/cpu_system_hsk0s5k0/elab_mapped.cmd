@echo off
call "C:\AMDDesignTools\2025.2\Vivado\bin\xelab.bat" tb_cpu_system_mapped glbl -s mapped_sim -debug typical -L unisims_ver
exit /b %errorlevel%
