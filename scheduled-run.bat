@echo off
chcp 65001 >nul
rem ============================================================
rem Non-interactive check-in runner for Task Scheduler.
rem Resolves python, runs python signin.py auto, writes the result
rem to a log file, and (if configured) pushes the result to a Feishu
rem (Lark) webhook. The webhook is read by signin.py from config.json
rem (or WORKBUDDY_FEISHU_WEBHOOK env). No pause; safe for scheduled runs.
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
  echo [ERROR] Python not found in PATH. Please add python to PATH.
  exit /b 1
)

echo [INFO] Running WorkBuddy auto check-in ...
"%PY_EXE%" "%PROJECT_DIR%signin.py" auto > "%LOG%" 2>&1
set "RC=%errorlevel%"

echo [INFO] Exit code: %RC%
type "%LOG%"

rem Feishu push is handled inside signin.py (reads config.json / WORKBUDDY_FEISHU_WEBHOOK).
exit /b %RC%
rem ============================================================
