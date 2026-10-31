@echo off
call "C:\AMDDesignTools\2025.2\Vivado\bin\xelab.bat" tb_isa_contract -s contract_v16_sim -debug typical
exit /b %errorlevel%
