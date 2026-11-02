@echo off
call "C:\AMDDesignTools\2025.2\Vivado\bin\vivado.bat" -mode batch -source create_project.tcl -log vivado.log -nojournal -tclargs baseline
exit /b %errorlevel%
