@echo off
set "PRE6_PY=C:\Users\Donson\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
if not exist "%PRE6_PY%" set "PRE6_PY=python"
"%PRE6_PY%" -B -X utf8 "%~dp0run_project.py" --program all
if errorlevel 1 (
  echo PRE6 VERIFICATION FAILED - inspect the new result.json and console.log.
) else (
  echo PRE6 VERIFICATION PASSED - six fresh simulation projects.
)
pause
