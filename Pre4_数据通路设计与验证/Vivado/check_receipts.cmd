@echo off
setlocal EnableExtensions
pushd "%~dp0" || exit /b 1
:next
if "%~1"=="" goto done
if not exist "%~1" goto fail
set "PRE4_RECEIPT_ATTR=%~a1"
if /I "%PRE4_RECEIPT_ATTR:~0,1%"=="d" goto fail
if "%~z1"=="" goto fail
if %~z1 LEQ 0 goto fail
shift /1
goto next
:done
popd
exit /b 0
:fail
popd
exit /b 1
