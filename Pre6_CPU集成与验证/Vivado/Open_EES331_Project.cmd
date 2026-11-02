@echo off
set "PRE6_PY=C:\Users\Donson\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
if not exist "%PRE6_PY%" set "PRE6_PY=python"
"%PRE6_PY%" -B -X utf8 "%~dp0open_gui.py" board
if errorlevel 1 pause
