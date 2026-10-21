@echo off
setlocal
rem Let Windows PowerShell build its own module paths when started from PowerShell 7.
set "PSModulePath="
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\setup-thor.ps1" %*
set "setup_result=%errorlevel%"
echo.
pause
exit /b %setup_result%
