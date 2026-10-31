@echo off
call "C:\AMDDesignTools\2025.2\Vivado\bin\xelab.bat" tb_board_application -s board_sim -debug typical
exit /b %errorlevel%
