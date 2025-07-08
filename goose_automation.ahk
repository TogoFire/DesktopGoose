; AutoHotkey v2 Syntax

#SingleInstance Force
SetWorkingDir A_ScriptDir

; --- 1. Close the application (if running) using taskkill to avoid AHK's 'Process' warning ---
; This command attempts to forcefully terminate the process by its image name.
/* RunWait 'taskkill /F /IM goosedesktop.exe', , 'Hide' ; 'Hide' keeps the cmd window hidden
Sleep 1000 ; Give it a moment to close */

; --- 2. Start the application ---
Run A_ScriptDir '\goosedesktop.exe'
; WinWait expects the window title. Use the EXACT title from your image "Mod Enabler Warning".
WinWait('Mod Enabler Warning', , 30) ; Wait up to 30 seconds for the window to appear

; --- 3. Interact with the warning window (Mod Enabler Warning) ---
; Check if the EXACT window title exists
if WinExist('Mod Enabler Warning')
{
    WinActivate ; Activate the window to ensure ControlClick works reliably
    Sleep 200 ; Give it a moment to activate

    Success := false

    ; List of "Yes" translations to try, in order of commonality/preference
    ; Ensure these are the exact text on the button
    yesOptions := ["Yes", "Sim", "Sí"
                , "Ja", "Oui", "Sì", "はい", "예", "是", "Так", "Да", "हाँ"
                , "Evet", "Vâng", "Có", "ใช่", "Ya", "Kyllä", "כן", "Ναι"
                ]

    for index, option in yesOptions
    {
        try {
            if ControlClick(option, 'Mod Enabler Warning')
            {
                Success := true
                Break ; Exit the loop if a click was successful
            }
        } catch {
            ; Ignore the error and proceed to the next option.
        }
    }

    /*
    if (Success)
    {
        ; Opcional: MsgBox 'Successfully clicked the warning button.'
    }
    */
    ; Failure MsgBox has been removed to ignore if it fails.
}
else
{
    MsgBox 'Warning window "Mod Enabler Warning" did not appear or timed out.'
}

ExitApp ; Exit the AutoHotkey script
