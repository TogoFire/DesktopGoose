@echo off
setlocal

:: Define the current directory where the .bat file is located
set "CURRENT_DIR=%~dp0"

:: Attempt to find GooseDesktop.exe in the current directory
set "GOOSE_PATH=%CURRENT_DIR%GooseDesktop.exe"

echo.
echo --- Starting GooseDesktop Automation Process ---
echo.

:: 1. Check if GooseDesktop.exe exists
if not exist "%GOOSE_PATH%" (
    echo ERROR: "GooseDesktop.exe" not found in "%CURRENT_DIR%".
    echo Please ensure this .bat script is in the same folder as the executable.
    echo.
    pause
    goto :eof
)

:: 2. Close goosedesktop.exe if running
:: echo Attempting to close goosedesktop.exe...
:: taskkill /F /IM goosedesktop.exe >nul 2>&1
:: timeout /t 1 /nobreak >nul
:: echo GooseDesktop.exe closed (if it was running).
:: echo.

:: 3. Start goosedesktop.exe
echo Starting GooseDesktop.exe...
:: Use /D to explicitly set the working directory for the executable.
:: This is crucial for the program to find its dependencies (DLLs, etc.).
start "" /D "%CURRENT_DIR%" "%GOOSE_PATH%"
echo.

:: There will be no attempt to interact with the "Mod Enabler Warning" window in this script.
:: If you still need to click "Yes", AutoHotkey (AHK) is the most reliable tool for that.

echo.
echo --- GooseDesktop Automation Completed ---
echo.

endlocal
exit /b
