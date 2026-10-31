@echo off
setlocal EnableExtensions
set "PRE4_RECEIPT_ROOT=%~dp0"
if /I "%~1"=="--eda" (
  set "PRE4_RECEIPT_ROOT=%~dp0eda"
  shift /1
)
if not exist "%PRE4_RECEIPT_ROOT%" exit /b 0
pushd "%PRE4_RECEIPT_ROOT%" || exit /b 1
:choose
set "PRE4_MANUAL_ARCHIVE=%~dp0previous_runs\manual_%RANDOM%_%RANDOM%"
if exist "%PRE4_MANUAL_ARCHIVE%" goto choose
:next
if "%~1"=="" goto done
rem Only local basenames are permitted; callers pass a fixed receipt list.
if not "%~1"=="%~nx1" goto fail
if not exist "%~1" goto advance
set "PRE4_ARCHIVE_ATTR=%~a1"
if /I "%PRE4_ARCHIVE_ATTR:~0,1%"=="d" goto fail
if exist "%PRE4_MANUAL_ARCHIVE%" goto movefile
mkdir "%PRE4_MANUAL_ARCHIVE%"
if errorlevel 1 goto fail
if not errorlevel 0 goto fail
:movefile
move "%~1" "%PRE4_MANUAL_ARCHIVE%\%~nx1" >nul
if errorlevel 1 goto fail
if not errorlevel 0 goto fail
:advance
shift /1
goto next
:done
popd
exit /b 0
:fail
popd
exit /b 1
