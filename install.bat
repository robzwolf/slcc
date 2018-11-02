@echo off &setlocal

powershell -ExecutionPolicy ByPass "%~dp0install\install.ps1" %~dp0 %*
exit /B %ERRORLEVEL%
