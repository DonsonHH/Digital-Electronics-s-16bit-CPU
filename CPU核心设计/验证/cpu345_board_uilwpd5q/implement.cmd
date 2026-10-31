@echo off
call "C:\AMDDesignTools\2025.2\Vivado\bin\vivado.bat" -mode batch -source build_board.tcl -log implementation.log -nojournal
exit /b %errorlevel%
