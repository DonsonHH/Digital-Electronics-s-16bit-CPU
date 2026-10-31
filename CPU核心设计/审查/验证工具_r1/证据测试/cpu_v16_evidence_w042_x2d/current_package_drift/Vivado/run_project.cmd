@echo off
"C:\Users\Donson\.cache\codex-runtimes\codex-primary-runtime\dependencies\native\powershell\pwsh.exe" -NoProfile -File "%~dp0create_project.ps1"
exit /b %errorlevel%
