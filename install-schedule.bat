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

rem Resolve python absolute path (scheduler env may lack python in PATH)
set "PY_EXE=python"
for /f "delims=" %%i in ('where python 2^>nul') do (
  set "PY_EXE=%%i"
  goto :found_python
)
:found_python
if "%PY_EXE%"=="python" (
  for /f "delims=" %%i in ('where python3 2^>nul') do (
    set "PY_EXE=%%i"
    goto :found_python3
  )
)
:found_python3
if "%PY_EXE%"=="python" (
  echo [ERROR] Python not found. Please install Python 3 and add it to PATH.
  exit /b 1
)

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
