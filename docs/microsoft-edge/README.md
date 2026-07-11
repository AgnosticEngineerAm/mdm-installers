# Microsoft Edge MDM Deployment Guide

Microsoft Edge is a Chromium-based browser with deep integration into the Microsoft 365 ecosystem.

## Platforms Supported
- ✅ **macOS**: PKG (Universal)
- ✅ **Windows**: MSI
- ✅ **Linux**: DEB / RPM

## Installation Scripts
- [macOS Install Script](file:///Users/machine/Documents/VStudio/mdm-installer/scripts/macos/microsoft-edge/install.sh)
- [macOS Uninstall Script](file:///Users/machine/Documents/VStudio/mdm-installer/scripts/macos/microsoft-edge/uninstall.sh)
- [Windows Install Script](file:///Users/machine/Documents/VStudio/mdm-installer/scripts/windows/microsoft-edge/install.ps1)
- [Linux Install Script](file:///Users/machine/Documents/VStudio/mdm-installer/scripts/linux/microsoft-edge/install.sh)

## MDM Deployment Notes

### macOS
- **Format**: `.pkg`
- **Updates**: Microsoft AutoUpdate (MAU) manages Edge updates. Deploying the Edge PKG will also install MAU.
- **Policies**: Configure via the `com.microsoft.edgemac` domain.

### Windows (Intune)
- **Format**: `.msi`
- **Notes**: Often pre-installed on Windows 10/11. The installer script ensures the enterprise version is fully provisioned. Intune has built-in administrative templates for Edge.

### Linux
- The script adds the Microsoft Linux repository and installs `microsoft-edge-stable`.

## Security Profiles
- Edge can enforce Defender SmartScreen and Conditional Access when signed in with a work account.
