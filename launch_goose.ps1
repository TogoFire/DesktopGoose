# --- Configuration ---
$ahkScriptPath = Join-Path -Path $PSScriptRoot -ChildPath "goose_automation.ahk" # <--- KEEPS .AHK HERE

# --- Function to check if a command exists (General purpose) ---
function Test-CommandExists {
    param(
        [string]$Command
    )
    # Attempts to get the command from PATH.
    (Get-Command -Name $Command -ErrorAction SilentlyContinue) -ne $null
}

# --- Function to check for AutoHotkey v2+ installation (Specific to AHK v2 or greater) ---
function Test-AutoHotkeyV2Installed { # Renamed to reflect v2+ check
    # Check if the AutoHotkey executable (usually AutoHotkeyU64.exe for 64-bit) exists in standard directories
    $ahkInstallPath64 = "C:\Program Files\AutoHotkey\AutoHotkeyU64.exe"
    $ahkInstallPath32 = "C:\Program Files (x86)\AutoHotkey\AutoHotkeyU32.exe" # Or AutoHotkey.exe for 32-bit if applicable

    if (Test-Path $ahkInstallPath64) {
        Write-Host "Found AutoHotkey executable at $ahkInstallPath64" # Removed "U64" for simpler message
        # Verify the version to ensure it's V2 or newer.
        try {
            $versionInfo = (Get-Item $ahkInstallPath64).VersionInfo
            if ($versionInfo.ProductMajorPart -ge 2) {
                Write-Host "AutoHotkey (v2 or newer) detected: $($versionInfo.ProductVersion)"
                return $true
            }
        } catch {
            Write-Warning "Could not get AutoHotkey version info: $($_.Exception.Message)"
        }
    }
    if (Test-Path $ahkInstallPath32) {
        Write-Host "Found AutoHotkey executable at $ahkInstallPath32" # Removed "U32" for simpler message
        try {
            $versionInfo = (Get-Item $ahkInstallPath32).VersionInfo
            if ($versionInfo.ProductMajorPart -ge 2) {
                Write-Host "AutoHotkey (v2 or newer) detected: $($versionInfo.ProductVersion)"
                return $true
            }
        } catch {
            Write-Warning "Could not get AutoHotkey version info: $($_.Exception.Message)"
        }
    }

    # As a fallback, check if 'autohotkey.exe' is in the PATH and try to verify its version.
    if (Test-CommandExists "autohotkey.exe") {
        Write-Host "AutoHotkey executable found in PATH. Checking version..."
        try {
            $ahkPath = (Get-Command "autohotkey.exe").Source
            $versionInfo = (Get-Item $ahkPath).VersionInfo
            if ($versionInfo.ProductMajorPart -ge 2) {
                Write-Host "AutoHotkey (v2 or newer) detected in PATH: $($versionInfo.ProductVersion)"
                return $true
            } else {
                Write-Host "AutoHotkey found in PATH is an older version ($($versionInfo.ProductVersion)). Installing a compatible version."
                return $false # It's an older version, needs v2+ installation
            }
        } catch {
            Write-Warning "Could not get AutoHotkey version info from PATH executable: $($_.Exception.Message). Assuming not v2+ or problematic."
            return $false
        }
    }

    return $false # AutoHotkey v2+ not found
}

# --- 1. Check for Chocolatey and Install if Missing ---
Write-Host "Checking for Chocolatey installation..."
if (-not (Test-CommandExists "choco")) {
    Write-Host "Chocolatey not found. Attempting to install Chocolatey..."
    # You MUST run this script as Administrator to install Chocolatey.
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Error "To install Chocolatey, you MUST run this script as an Administrator."
        Write-Error "Please right-click on this .ps1 file and select 'Run as Administrator'."
        exit 1 # Exit if not running as admin
    }

    try {
        # Execute the specific Chocolatey installation command provided by the user.
        # This command handles setting execution policy and security protocols, then executes the install script.
        $chocoInstallCommand = "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
        Invoke-Expression $chocoInstallCommand

        Write-Host "Chocolatey installed successfully."
        # Rehash environment variables to make 'choco' command available immediately
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Process") # Updates PATH for the current session
    }
    catch {
        Write-Error "Failed to install Chocolatey. Error: $($_.Exception.Message)"
        Write-Error "Please check your internet connection or try installing manually."
        exit 1 # Exit if Chocolatey installation fails
    }
} else {
    Write-Host "Chocolatey is already installed."
}

# --- 2. Check for AutoHotkey and Install via Winget if Missing ---
Write-Host "Checking for AutoHotkey installation..."
if (-not (Test-AutoHotkeyV2Installed)) { # Checks for v2 or greater
    Write-Host "AutoHotkey not found or not the correct version. Attempting to install AutoHotkey via Winget..."

    # You MUST run this script as Administrator to install AutoHotkey via Winget if it requires system-wide permissions.
    # The Winget installation command is already in place as requested in the previous code.

    try {
        winget install AutoHotkey.AutoHotkey --silent --accept-source-agreements --accept-package-agreements
        Write-Host "AutoHotkey installed successfully via Winget."

        # Optional: choco install autohotkey -y --force-dependencies --force -ErrorAction Stop

        # After AHK installation, reinforce PATH update for the session
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Process")
    }
    catch {
        Write-Error "Failed to install AutoHotkey via Winget. Error: $($_.Exception.Message)"
        Write-Error "Please ensure Winget is installed and check the Winget package source (Winget is typically installed by default on Windows 11)."
        # Note: The previous error messages related to Chocolatey have been replaced here to reflect Winget installation.
        exit 1 # Exit if AHK installation fails
    }
} else {
    Write-Host "AutoHotkey is already installed."
}

# --- 3. Run the AutoHotkey Script ---
Write-Host "Running the AutoHotkey script: '$ahkScriptPath'..."
try {
    # Start-Process will launch the .ahk file with the default associated program (AutoHotkey)
    Start-Process -FilePath $ahkScriptPath -WindowStyle Hidden # Run AHK script hidden
    Write-Host "AutoHotkey script launched."
}catch {
    Write-Error "Failed to launch AutoHotkey script. Error: $($_.Exception.Message)"
    exit 1
}
Write-Host "Setup and AHK script execution complete."

# --- Registry configuration ---
# Define entries for Command Prompt custom menus
$cmdEntries = @(
    @{
        Path = "HKEY_CLASSES_ROOT\Directory\shell\01MenuCmd"
        Values = @{
            "MUIVerb" = "Command Prompts"
            "Icon" = "cmd.exe"
            "ExtendedSubCommandsKey" = "Directory\ContextMenus\MenuCmd"
            "Extended" = "" # This makes this menu appear only with Shift+Right-Click
        }
    },
    @{
        Path = "HKEY_CLASSES_ROOT\Directory\background\shell\01MenuCmd"
        Values = @{
            "MUIVerb" = "Command Prompts"
            "Icon" = "cmd.exe"
            "ExtendedSubCommandsKey" = "Directory\ContextMenus\MenuCmd"
            "Extended" = "" # This makes this menu appear only with Shift+Right-Click
        }
    },
    @{
        Path = "HKEY_CLASSES_ROOT\Directory\ContextMenus\MenuCmd\shell\open"
        Values = @{
            "MUIVerb" = "Command Prompt"
            "Icon" = "cmd.exe"
        }
    },
    @{
        Path = "HKEY_CLASSES_ROOT\Directory\ContextMenus\MenuCmd\shell\open\command"
        Values = @{
            # cmd.exe
            "(Default)" = 'cmd.exe /s /k pushd "%V"'
        }
    },
    @{
        Path = "HKEY_CLASSES_ROOT\Directory\ContextMenus\MenuCmd\shell\runas"
        Values = @{
            "MUIVerb" = "Command Prompt Elevated"
            "Icon" = "cmd.exe"
            "HasLUAShield" = ""
        }
    },
    @{
        Path = "HKEY_CLASSES_ROOT\Directory\ContextMenus\MenuCmd\shell\runas\command"
        Values = @{
            # cmd.exe
            "(Default)" = 'cmd.exe /s /k pushd "%V"'
        }
    }
)

# Define entries for PowerShell custom menus
$psEntries = @(
    @{
        Path = "HKEY_CLASSES_ROOT\Directory\shell\02MenuPowerShell"
        Values = @{
            "MUIVerb" = "PowerShell Prompts"
            "Icon" = "powershell.exe"
            "ExtendedSubCommandsKey" = "Directory\ContextMenus\MenuPowerShell"
            "Extended" = "" # This makes this menu appear only with Shift+Right-Click
        }
    },
    @{
        Path = "HKEY_CLASSES_ROOT\Directory\background\shell\02MenuPowerShell"
        Values = @{
            "MUIVerb" = "PowerShell Prompts"
            "Icon" = "powershell.exe"
            "ExtendedSubCommandsKey" = "Directory\ContextMenus\MenuPowerShell"
            "Extended" = "" # This makes this menu appear only with Shift+Right-Click
        }
    },
    @{
        Path = "HKEY_CLASSES_ROOT\Directory\ContextMenus\MenuPowerShell\shell\open"
        Values = @{
            "MUIVerb" = "PowerShell"
            "Icon" = "powershell.exe"
        }
    },
    @{
        Path = "HKEY_CLASSES_ROOT\Directory\ContextMenus\MenuPowerShell\shell\open\command"
        Values = @{
            # PowerShell path handling
            "(Default)" = 'powershell.exe -noexit -command Set-Location ''%V'''
        }
    },
    @{
        Path = "HKEY_CLASSES_ROOT\Directory\ContextMenus\MenuPowerShell\shell\runas"
        Values = @{
            "MUIVerb" = "PowerShell Elevated"
            "Icon" = "powershell.exe"
            "HasLUAShield" = ""
        }
    },
    @{
        Path = "HKEY_CLASSES_ROOT\Directory\ContextMenus\MenuPowerShell\shell\runas\command"
        Values = @{
            # PowerShell path handling
            "(Default)" = 'powershell.exe -noexit -command Set-Location ''%V'''
        }
    }
)

# The extendedEntries array is now empty and will no longer be passed to Set-RegistryEntries.
$extendedEntries = @()

## Registry Function

# Function to create keys and set values
function Set-RegistryEntries {
    param (
        [Parameter(Mandatory=$true)]
        [array]$Entries
    )

    foreach ($entry in $Entries) {
        $path = $entry.Path
        $values = $entry.Values

        Write-Host "Processing key: $path"

        # --- Ensure all parent keys exist ---
        # Split the path into components (e.g., HKEY_CLASSES_ROOT, Directory, ContextMenus, etc.)
        # The first component (e.g., HKEY_CLASSES_ROOT) is the root and doesn't need creation.
        $pathComponents = $path.Split('\')
        $currentPath = $pathComponents[0] # Start with the root, e.g., HKEY_CLASSES_ROOT

        # Iterate through the components, creating each part of the path if it doesn't exist
        for ($i = 1; $i -lt $pathComponents.Length; $i++) {
            $currentPath = "$currentPath\$($pathComponents[$i])"
            Try {
                if (-not (Test-Path "Registry::$currentPath")) {
                    New-Item -Path "Registry::$currentPath" -ErrorAction Stop | Out-Null
                    Write-Host "Created parent key: $currentPath"
                }
            }
            Catch [System.Management.Automation.DriveNotFoundException] {
                Write-Error "Error: Could not create parent key '$currentPath'. Ensure you are running PowerShell as Administrator and the path is valid. $($_.Exception.Message)"
                # Stop processing this entry if a parent key cannot be created
                continue
            }
            Catch {
                Write-Error "An unexpected error occurred while creating/checking parent key '$currentPath': $($_.Exception.Message)"
                # Stop processing this entry if a parent key cannot be created
                continue
            }
        }
        # --- End Ensure ---

        # Now that all parent keys are guaranteed to exist, create the final key if it doesn't.
        Try {
            if (-not (Test-Path "Registry::$path")) {
                New-Item -Path "Registry::$path" -ErrorAction Stop | Out-Null
                Write-Host "Key created: $path"
            } else {
                Write-Host "Key already exists: $path"
            }
        }
        Catch [System.Management.Automation.DriveNotFoundException] {
            Write-Error "Error: Could not create key '$path'. Ensure you are running PowerShell as Administrator and the path is valid. $($_.Exception.Message)"
            continue
        }
        Catch {
            Write-Error "An unexpected error occurred while creating/checking key '$path': $($_.Exception.Message)"
            continue
        }

        # Set the values
        foreach ($key in $values.Keys) {
            $value = $values[$key]
            Try {
                if ($key -eq "(Default)") {
                    Set-ItemProperty -LiteralPath "Registry::$path" -Name "(Default)" -Value $value -Force -ErrorAction Stop
                    Write-Host "Set default value to '$value' in $path"
                } else {
                    Set-ItemProperty -LiteralPath "Registry::$path" -Name $key -Value $value -Force -ErrorAction Stop
                    Write-Host "Set value '$key' = '$value' in $path"
                }
            }
            Catch [System.Management.Automation.DriveNotFoundException] {
                Write-Error "Error: Could not set property '$key' in '$path'. Ensure you are running PowerShell as Administrator and the path is valid. $($_.Exception.Message)"
            }
            Catch {
                Write-Error "An unexpected error occurred while setting property '$key' in '$path': $($_.Exception.Message)"
            }
        }
    }
}

## Script Execution

Write-Host "Starting Registry configuration for Command Prompt and PowerShell..."

# Execute Command Prompt configurations
Set-RegistryEntries -Entries $cmdEntries

# Execute PowerShell configurations
Set-RegistryEntries -Entries $psEntries

Write-Host "Registry configuration completed successfully! 🎉"

# --- Revert Execution Policy to RemoteSigned for CurrentUser ---
Write-Host "Reverting PowerShell execution policy to RemoteSigned for current user..."
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned -Force
Write-Host "Execution policy set to RemoteSigned for current user."
