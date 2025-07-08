@echo off

REM Set the PowerShell execution policy for the current user.
REM This is necessary to allow PowerShell scripts to run on the system.
PowerShell.exe -NoProfile -ExecutionPolicy Bypass -Command "Set-ExecutionPolicy -Scope CurrentUser Unrestricted -Force"

set "SCRIPT_DIR=%~dp0"
set "POWERSHELL_SCRIPT="%SCRIPT_DIR%launch_goose.ps1""

REM Executes the main PowerShell script (launch_goose.ps1).
REM -NoProfile: Does not load the user's PowerShell profile.
REM -ExecutionPolicy Bypass: Allows the script to run even with restrictive execution policies.
REM -File: Specifies the script to be executed.
PowerShell.exe -NoProfile -ExecutionPolicy Bypass -File %POWERSHELL_SCRIPT%

exit
