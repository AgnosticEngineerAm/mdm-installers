# Visual Studio Code MDM Deployment Guide

Visual Studio Code (VS Code) is a lightweight but powerful source code editor.

## Platforms Supported
- ✅ **macOS**: ZIP (Unzips to .app)
- ✅ **Windows**: System Installer (EXE)
- ✅ **Linux**: DEB / RPM

## Installation Scripts
- [macOS Install Script](file:///Users/machine/Documents/VStudio/mdm-installer/scripts/macos/visual-studio-code/install.sh)
- [macOS Uninstall Script](file:///Users/machine/Documents/VStudio/mdm-installer/scripts/macos/visual-studio-code/uninstall.sh)
- [Windows Install Script](file:///Users/machine/Documents/VStudio/mdm-installer/scripts/windows/visual-studio-code/install.ps1)
- [Linux Install Script](file:///Users/machine/Documents/VStudio/mdm-installer/scripts/linux/visual-studio-code/install.sh)

## MDM Deployment Notes

### macOS
- **Format**: `.zip`
- **Details**: VS Code doesn't offer a native `.pkg`. The provided script downloads the ZIP, extracts it, and moves `Visual Studio Code.app` to `/Applications`. Set `chown -R root:wheel` to prevent standard users from modifying the bundle.

### Windows
- **Format**: System Installer `.exe`
- **Flags**: `/verysilent /suppressmsgboxes /mergetasks=!runcode`
- **Details**: Make sure to use the System Installer, not the User Installer, for MDM deployments to `C:\Program Files`.

### Linux
- Adds the Microsoft repository and installs the `code` package.
