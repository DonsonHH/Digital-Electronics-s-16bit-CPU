@echo off
call "C:\AMDDesignTools\2025.2\Vivado\bin\xelab.bat" tb_datapath -s datapath_v16_sim -debug typical
exit /b %errorlevel%
