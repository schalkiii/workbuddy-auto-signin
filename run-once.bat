@echo off
chcp 65001 >nul
rem ============================================================
rem One-click manual check-in. Suitable for a manual daily run or
rem a quick test of the scheduled flow. Non-interactive: resolves
rem python, runs signin.py auto, optionally pushes to Feishu.
rem ============================================================

set "PROJECT_DIR=%~dp0"
set "LOG=%TEMP%\workbuddy-signin.log"
if not defined WORKBUDDY_FEISHU_WEBHOOK set "WORKBUDDY_FEISHU_WEBHOOK="

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
  echo [ERROR] Python not found in PATH.
  exit /b 1
)

echo [INFO] Running check-in ...
"%PY_EXE%" "%PROJECT_DIR%signin.py" auto > "%LOG%" 2>&1
set "RC=%errorlevel%"
type "%LOG%"

if not "%WORKBUDDY_FEISHU_WEBHOOK%"=="" (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%PROJECT_DIR%scripts\notify.ps1" -Webhook "%WORKBUDDY_FEISHU_WEBHOOK%" -LogPath "%LOG%"
)
exit /b %RC%
