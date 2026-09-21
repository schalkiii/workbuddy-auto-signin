@echo off
chcp 65001 >nul
rem Force UTF-8 for python stdout/stderr so redirected logs stay readable.
set PYTHONIOENCODING=utf-8
rem ============================================================
rem Non-interactive check-in runner for scheduled runs.
rem Resolves python, runs python signin.py auto, writes the result
rem to a log file, and (if configured) pushes the result to a Feishu
rem (Lark) webhook. The webhook is read by signin.py from config.json
rem (or WORKBUDDY_FEISHU_WEBHOOK env). No pause; safe for scheduled runs.
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
echo [ERROR] Python not found in PATH. Please add python to PATH.
exit /b 1
:python_ok

echo [INFO] Running WorkBuddy auto check-in ...
"%PY_EXE%" "%PROJECT_DIR%signin.py" auto > "%LOG%" 2>&1
set "RC=%errorlevel%"

echo [INFO] Exit code: %RC%
type "%LOG%"

rem Feishu push is handled inside signin.py (reads config.json / WORKBUDDY_FEISHU_WEBHOOK).
exit /b %RC%
rem ============================================================
