@echo off
call "C:\AMDDesignTools\2025.2\Vivado\bin\xvlog.bat" --sv -d POST_SYNTH -i tb eda/system_netlist.v tb/tb_cpu_system.sv "C:\AMDDesignTools\2025.2\Vivado\data\verilog\src\glbl.v"
exit /b %errorlevel%
