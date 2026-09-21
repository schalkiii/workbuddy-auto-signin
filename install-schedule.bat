@echo off
chcp 65001 >nul
rem ============================================================
rem Install a daily Windows Task Scheduler job for WorkBuddy auto check-in.
rem Usage:
rem   install-schedule.bat           default daily at 00:05
rem   install-schedule.bat 09:30     custom time (24h)
rem The job calls scheduled-run.bat, which runs python signin.py auto.
rem Python absolute path is embedded so the non-interactive scheduler
rem can find python even without it on PATH.
rem ============================================================

set "TASK_NAME=WorkBuddyAutoSignin"
set "TIME=00:05"
if not "%1"=="" set "TIME=%1"

set "PROJECT_DIR=%~dp0"
set "RUNNER=%PROJECT_DIR%scheduled-run.bat"

rem Resolve python absolute path (scheduler env may lack python in PATH).
rem Skip the WindowsApps Store stub (0-byte shim that exists on PATH but
rem fails every run with exit code 9009), fall back to python3, then to
rem the per-user install folder.
set "PY_EXE="
for /f "delims=" %%i in ('where python 2^>nul ^| findstr /v /i "WindowsApps"') do if not defined PY_EXE set "PY_EXE=%%i"
if defined PY_EXE goto :python_ok
for /f "delims=" %%i in ('where python3 2^>nul ^| findstr /v /i "WindowsApps"') do if not defined PY_EXE set "PY_EXE=%%i"
if defined PY_EXE goto :python_ok
for /f "delims=" %%i in ('dir /b /s "%LOCALAPPDATA%\Programs\Python\python.exe" 2^>nul') do if not defined PY_EXE set "PY_EXE=%%i"
if defined PY_EXE goto :python_ok
echo [ERROR] Python not found in PATH.
exit /b 1
:python_ok

rem Remove existing task first to avoid duplicate-registration errors
schtasks /Delete /TN "%TASK_NAME%" /F >nul 2>nul

rem Create daily task that calls the non-interactive runner.
schtasks /Create /TN "%TASK_NAME%" /TR "\"%RUNNER%\"" /SC DAILY /ST "%TIME%" /F

if errorlevel 1 (
  echo [ERROR] Task creation failed. Run as Administrator or check schtasks permissions.
  exit /b 1
)

echo [OK] Daily check-in task created:
echo   Task name : %TASK_NAME%
echo   Time      : daily at %TIME%
echo   Command   : "%RUNNER%"
echo.
echo View details with: schtasks /Query /TN "%TASK_NAME%" /V
echo Remove with: uninstall-schedule.bat
exit /b 0
