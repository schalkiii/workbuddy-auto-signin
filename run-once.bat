@echo off
chcp 65001 >nul
rem Force UTF-8 for python stdout/stderr so redirected logs stay readable.
set PYTHONIOENCODING=utf-8
rem ============================================================
rem One-click manual check-in (test run). Resolves python, runs
rem signin.py auto --no-push (does NOT push to Feishu), so you can
rem test the flow without duplicate notifications. For a real push,
rem run scheduled-run.bat, or drop --no-push and set the webhook via
rem config.json feishuWebhook / WORKBUDDY_FEISHU_WEBHOOK.
rem ============================================================

set "PROJECT_DIR=%~dp0"
set "LOG=%TEMP%\workbuddy-signin.log"

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

echo [INFO] Running check-in (no-push test) ...
"%PY_EXE%" "%PROJECT_DIR%signin.py" auto --no-push > "%LOG%" 2>&1
set "RC=%errorlevel%"
type "%LOG%"

rem Feishu push is handled inside signin.py when not using --no-push.
exit /b %RC%
