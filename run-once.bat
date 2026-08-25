@echo off
chcp 65001 >nul
rem ============================================================
rem One-click manual check-in (test run). Resolves python, runs
rem signin.py auto --no-push (does NOT push to Feishu), so you can
rem test the flow without duplicate notifications. For a real push,
rem run scheduled-run.bat, or drop --no-push and set the webhook via
rem config.json feishuWebhook / WORKBUDDY_FEISHU_WEBHOOK.
rem ============================================================

set "PROJECT_DIR=%~dp0"
set "LOG=%TEMP%\workbuddy-signin.log"

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
  echo [ERROR] Python not found in PATH.
  exit /b 1
)

echo [INFO] Running check-in (no-push test) ...
"%PY_EXE%" "%PROJECT_DIR%signin.py" auto --no-push > "%LOG%" 2>&1
set "RC=%errorlevel%"
type "%LOG%"

rem Feishu push is handled inside signin.py when not using --no-push.
exit /b %RC%
