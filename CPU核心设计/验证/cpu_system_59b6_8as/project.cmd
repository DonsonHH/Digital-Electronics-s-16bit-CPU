@echo off
call "C:\AMDDesignTools\2025.2\Vivado\bin\vivado.bat" -mode batch -source create_project.tcl -tclargs project verify -log project.log -nojournal
exit /b %errorlevel%
