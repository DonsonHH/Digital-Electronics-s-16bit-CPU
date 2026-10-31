@echo off
call "C:\AMDDesignTools\2025.2\Vivado\bin\xelab.bat" tb_forward_contract -s forward_v16_sim -debug typical
exit /b %errorlevel%
