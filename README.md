<p align="center">
  <img src="https://github.com/TogoFire/DesktopGoose/blob/main/Assets/Images/OtherGfx/banner.png" width="450px" />
</p>

# 🚀 Goose Desktop

Quick guide

---

## ✨ Key Components

* **`launch_goose.exe`**: Starts the application, automatically clicking 'Yes' on the prompt, bypassing it.
* **`Schedule-DG.exe`**: Ensures Desktop Goose remains installed and configures its automatic execution.
* **`Setup-DG.exe`**: Downloads Desktop Goose to the `C:\Program Files\DesktopGoose` directory.
* **`Close Goose.exe`**: Simply closes the running Desktop Goose application. Alternatively, just hold ESC.

---

## ⚠️ Important: Run as Administrator!

**For the installation to succeed, you MUST run your PowerShell terminal as an Administrator.**

By default, [Winget](https://github.com/asheroto/winget-install) comes installed on Windows, starting from Windows 10 version 2004. If needed, verify its installation with the commands `winget`, `winget --version`, and `winget --info`.
To fix "Winget is not Recognized as an internal or external command," watch this video: [Fix Winget is not Recognized](https://youtu.be/NXHrHRXGv04)

If you need to install Winget, simply use this command:
```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/asheroto/winget-install/master/winget-install.ps1" -OutFile "$env:TEMP\winget-install.ps1" -ErrorAction Stop; & "$env:TEMP\winget-install.ps1"
```

---

## 📥 How to Install (via PowerShell)

The `Schedule-DG.bat` setup script will be downloaded and run, configuring Desktop Goose to keep it automatically installed via its scheduled tasks.

The `Setup-DG.bat` just downloads Desktop Goose to its default directory.

### For Windows PowerShell 5.1 (Default on Windows)

Use this command. It downloads the script and executes it natively.

```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/TogoFire/DesktopGoose/main/Schedule-DG.bat" -OutFile "$env:TEMP\Schedule-DG.bat" -ErrorAction Stop; & "$env:TEMP\Schedule-DG.bat"
```

```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/TogoFire/DesktopGoose/main/Setup-DG.bat" -OutFile "$env:TEMP\Setup-DG.bat" -ErrorAction Stop; & "$env:TEMP\Setup-DG.bat"
```

---

## 📝 Notes

* Only stable and useful mods have been added.
* Scripts are provided by [@TogoFire](https://github.com/TogoFire).

---

## ✨ Extra Features

* Goose Meme Pack
* Notepad Pack

---

## 🦆 Included Mods

* **All here:**
    https://github.com/TogoFire/DesktopGoose/blob/main/Assets/Mods/README.md
