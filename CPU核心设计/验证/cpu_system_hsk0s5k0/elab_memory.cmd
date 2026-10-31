@echo off
call "C:\AMDDesignTools\2025.2\Vivado\bin\xelab.bat" tb_memory_files -s memory_sim -debug typical -L unisims_ver
exit /b %errorlevel%
