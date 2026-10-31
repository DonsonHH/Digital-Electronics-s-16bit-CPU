@echo off
call "C:\AMDDesignTools\2025.2\Vivado\bin\xelab.bat" tb_selected_program -s selected_sim -debug typical
exit /b %errorlevel%
