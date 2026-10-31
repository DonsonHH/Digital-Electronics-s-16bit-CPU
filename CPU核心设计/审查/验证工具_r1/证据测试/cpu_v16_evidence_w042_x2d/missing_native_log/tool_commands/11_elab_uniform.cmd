@echo off
call "C:\AMDDesignTools\2025.2\Vivado\bin\xelab.bat" tb_uniform_smoke -s uniform_v16_sim -debug typical
exit /b %errorlevel%
