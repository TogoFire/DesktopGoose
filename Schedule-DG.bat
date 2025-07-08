@echo off
title DesktopGoose Setup
setlocal enabledelayedexpansion

:: --- CONFIGURATION ---
set "ZIP_URL=https://github.com/TogoFire/DesktopGoose/archive/refs/heads/main.zip"
set "INSTALL_DIR=C:\Program Files\DesktopGoose"
set "GOOSE_APP_DIR=%INSTALL_DIR%"
set "LAUNCH_GOOSE_EXE=%GOOSE_APP_DIR%\launch_goose.exe"
set "TASK_NAME=LaunchGooseDaily" :: This task is for daily noon launch
set "TEMP_ZIP_FILE=%TEMP%\DesktopGoose_main.zip"
set "EXTRACT_TEMP_DIR=%TEMP%\DesktopGoose_extracted"

:: --- CONFIGURATION FOR SCHEDULE-DG ---
set "SCHEDULE_DG_SOURCE=%INSTALL_DIR%\Schedule-DG.exe"
set "TOOLS_DIR=C:\Program Files\Tools"
set "SCHEDULE_DG_DESTINATION=%TOOLS_DIR%\Schedule-DG.exe"
set "SCHEDULE_DG_TASK_NAME=ScheduleDGMon"

echo Checking and closing goosedesktop.exe , if running...
tasklist /FI "IMAGENAME eq goosedesktop.exe " 2>NUL | find /I /N "goosedesktop.exe ">NUL
if "%ERRORLEVEL%"=="0" (
    taskkill /im goosedesktop.exe /t /f >nul 2>&1
    echo goosedesktop.exe closed.
) else (
    echo goosedesktop.exe is not running.
)

echo.
echo Creating installation directory: "%INSTALL_DIR%"
if not exist "%INSTALL_DIR%" (
    mkdir "%INSTALL_DIR%" || (
        echo ERROR: Failed to create installation directory.
        pause
        goto :TheEnd
    )
) else (
    echo Installation directory already exists.
)

echo.
echo Starting DesktopGoose ZIP download...

:: Clean up previous temporary files
if exist "%TEMP_ZIP_FILE%" del "%TEMP_ZIP_FILE%" >nul 2>&1
if exist "%EXTRACT_TEMP_DIR%" rmdir /s /q "%EXTRACT_TEMP_DIR%" >nul 2>&1
mkdir "%EXTRACT_TEMP_DIR%" >nul 2>&1

echo --- CURL OUTPUT ---
:: Download the ZIP file using curl. No stderr redirection to see error messages.
curl.exe -L "%ZIP_URL%" --output "%TEMP_ZIP_FILE%"
set "CURL_ERROR_CODE=%ERRORLEVEL%"
echo --- END OF CURL OUTPUT ---

echo.
:: Check if curl returned a non-zero error.
if "%CURL_ERROR_CODE%" NEQ "0" (
    echo ERROR: Curl command failed.
    echo Curl returned error code: %CURL_ERROR_CODE%. Please inspect the output above.
    echo Check your internet connection and if the link is working: %ZIP_URL%
    pause
    goto :TheEnd
)

:: Check if the ZIP file was actually created and is not empty
if not exist "%TEMP_ZIP_FILE%" (
    echo CRITICAL ERROR: ZIP file not found after download, even if curl indicated success.
    echo Expected path: "%TEMP_ZIP_FILE%"
    pause
    goto :TheEnd
)
for %%F in ("%TEMP_ZIP_FILE%") do set /a FILE_SIZE=%%~zF
if %FILE_SIZE% EQU 0 (
    echo CRITICAL ERROR: ZIP file was downloaded, but it is empty!
    echo Size: %FILE_SIZE% bytes.
    pause
    goto :TheEnd
)
echo Download complete. File saved to: "%TEMP_ZIP_FILE%" (Size: %FILE_SIZE% bytes)

echo.
echo Extracting files...
:: Extract the ZIP using PowerShell. No stderr redirection to see error messages.
powershell -Command "Expand-Archive -Path '%TEMP_ZIP_FILE%' -DestinationPath '%EXTRACT_TEMP_DIR%' -Force"
set "PS_ERROR_CODE=%ERRORLEVEL%"

:: Check if PowerShell returned an error
if "%PS_ERROR_CODE%" NEQ "0" (
    echo CRITICAL ERROR: Failed to extract ZIP file.
    echo PowerShell error code: %PS_ERROR_CODE%. Please inspect the output above.
    echo Check if the ZIP is not corrupted or if there are permissions to extract to "%EXTRACT_TEMP_DIR%".
    pause
    goto :TheEnd
)

:: Check if the expected folder was created inside the temporary extraction directory
:: The folder name is usually DesktopGoose-main (the GitHub branch name)
set "SOURCE_EXTRACTED_DIR="
for /D %%D in ("%EXTRACT_TEMP_DIR%\DesktopGoose-main") do (
    set "SOURCE_EXTRACTED_DIR=%%D"
)
if not defined SOURCE_EXTRACTED_DIR (
    echo CRITICAL ERROR: 'DesktopGoose-main' folder not found after extraction.
    echo Check the contents of "%EXTRACT_TEMP_DIR%".
    dir "%EXTRACT_TEMP_DIR%"
    pause
    goto :TheEnd
)
if not exist "!SOURCE_EXTRACTED_DIR!\" (
    echo CRITICAL ERROR: 'DesktopGoose-main' folder was defined but does not exist.
    echo Path: "!SOURCE_EXTRACTED_DIR!"
    dir "%EXTRACT_TEMP_DIR%"
    pause
    goto :TheEnd
)
echo Extraction complete. Files extracted to: "!SOURCE_EXTRACTED_DIR!"

echo.
echo Moving files to installation directory...
:: Move the extracted files to the final installation directory
xcopy "!SOURCE_EXTRACTED_DIR!\*.*" "%INSTALL_DIR%\" /E /H /Y /C /R
set "XCOPY_ERROR_CODE=%ERRORLEVEL%"

:: Check if xcopy returned an error
if "%XCOPY_ERROR_CODE%" NEQ "0" (
    echo CRITICAL ERROR: Failed to move extracted files to the final directory.
    echo XCOPY error code: %XCOPY_ERROR_CODE%. Please inspect the output above.
    echo Check permissions to write to "%INSTALL_DIR%".
    pause
    goto :TheEnd
)
echo Files moved.

:: Clean up temporary files and directories
del "%TEMP_ZIP_FILE%" >nul 2>&1
rmdir /s /q "%EXTRACT_TEMP_DIR%" >nul 2>&1
echo Temporary files cleaned up.

echo.
echo Scheduling daily task to launch DesktopGoose.
schtasks /query /tn "%TASK_NAME%" > nul 2>&1
IF %ERRORLEVEL% EQU 1 (
    schtasks /create /tn "%TASK_NAME%" /tr "\"%LAUNCH_GOOSE_EXE%\"" /sc daily /st 12:00:00 /ru SYSTEM /rl HIGHEST /f >nul 2>&1
    if "%ERRORLEVEL%"=="0" (
        echo Scheduled task "%TASK_NAME%" created successfully.
    ) else (
        echo ERROR: Failed to create scheduled task "%TASK_NAME%". Error code: %ERRORLEVEL%.
    )
) ELSE (
    schtasks /create /tn "%TASK_NAME%" /tr "\"%LAUNCH_GOOSE_EXE%\"" /sc daily /st 12:00:00 /ru SYSTEM /rl HIGHEST /f >nul 2>&1
    if "%ERRORLEVEL%"=="0" (
        echo Scheduled task "%TASK_NAME%" updated.
    ) else (
        echo ERROR: Failed to update scheduled task "%TASK_NAME%". Error code: %ERRORLEVEL%.
    )
)

echo.
echo Checking for and copying Schedule-DG.exe and scheduling task...
if exist "%SCHEDULE_DG_SOURCE%" (
    echo Found "%SCHEDULE_DG_SOURCE%".
    echo Creating directory "%TOOLS_DIR%" if it does not exist...
    if not exist "%TOOLS_DIR%" (
        mkdir "%TOOLS_DIR%" || (
            echo ERROR: Failed to create directory "%TOOLS_DIR%".
            pause
            goto :TheEnd
        )
    ) else (
        echo Directory "%TOOLS_DIR%" already exists.
    )

    echo Copying "%SCHEDULE_DG_SOURCE%" to "%SCHEDULE_DG_DESTINATION%"...
    copy /Y "%SCHEDULE_DG_SOURCE%" "%TOOLS_DIR%\" >nul
    if "%ERRORLEVEL%"=="0" (
        echo "%SCHEDULE_DG_SOURCE%" copied successfully to "%TOOLS_DIR%".
    ) else (
        echo ERROR: Failed to copy "%SCHEDULE_DG_SOURCE%". Error code: %ERRORLEVEL%.
        echo Check permissions to write to "%TOOLS_DIR%".
        pause
        goto :TheEnd
    )

    echo.
    echo Scheduling task to execute "%SCHEDULE_DG_DESTINATION%" every Monday at 14:00...
    schtasks /query /tn "%SCHEDULE_DG_TASK_NAME%" > nul 2>&1
    IF %ERRORLEVEL% EQU 1 (
        schtasks /create /tn "%SCHEDULE_DG_TASK_NAME%" /tr "\"%SCHEDULE_DG_DESTINATION%\"" /sc weekly /d MON /st 14:00:00 /ru SYSTEM /rl HIGHEST /f >nul 2>&1
        if "%ERRORLEVEL%"=="0" (
            echo Scheduled task "%SCHEDULE_DG_TASK_NAME%" created successfully.
        ) else (
            echo ERROR: Failed to create scheduled task "%SCHEDULE_DG_TASK_NAME%". Error code: %ERRORLEVEL%.
        )
    ) ELSE (
        schtasks /create /tn "%SCHEDULE_DG_TASK_NAME%" /tr "\"%SCHEDULE_DG_DESTINATION%\"" /sc weekly /d MON /st 14:00:00 /ru SYSTEM /rl HIGHEST /f >nul 2>&1
        if "%ERRORLEVEL%"=="0" (
            echo Scheduled task "%SCHEDULE_DG_TASK_NAME%" updated.
        ) else (
            echo ERROR: Failed to update scheduled task "%SCHEDULE_DG_TASK_NAME%". Error code: %ERRORLEVEL%.
        )
    )
) else (
    echo "%SCHEDULE_DG_SOURCE%" not found. Could not copy or schedule the task.
)

echo.
echo DesktopGoose installation and configuration complete!

echo.
echo Launching DesktopGoose now...
start "" "%LAUNCH_GOOSE_EXE%" || (
    echo ERROR: Failed to launch "%LAUNCH_GOOSE_EXE%". Please check the path and permissions.
)

:TheEnd
echo.
echo Press any key to exit.
pause >nul
exit
