# Microsoft Teams MDM Deployment Guide

This guide covers the **New Teams** (Enterprise) deployment.

## Platforms Supported
- ✅ **macOS**: PKG
- ✅ **Windows**: EXE (Bootstrapper)
- ⚠️ **Linux**: DEB / RPM (Note: Native client is deprecated, PWA is recommended by MS)

## Installation Scripts
- [macOS Install Script](file:///Users/machine/Documents/VStudio/mdm-installer/scripts/macos/microsoft-teams/install.sh)
- [macOS Uninstall Script](file:///Users/machine/Documents/VStudio/mdm-installer/scripts/macos/microsoft-teams/uninstall.sh)
- [Windows Install Script](file:///Users/machine/Documents/VStudio/mdm-installer/scripts/windows/microsoft-teams/install.ps1)
- [Linux Install Script](file:///Users/machine/Documents/VStudio/mdm-installer/scripts/linux/microsoft-teams/install.sh)

## MDM Deployment Notes

### macOS
- **Format**: `.pkg`
- **Details**: The New Teams client uses a unified PKG. Uninstalling requires removing containers and application support data.

### Windows
- **Format**: `teamsbootstrapper.exe`
- **Details**: The New Teams is an MSIX package. The bootstrapper provisions it machine-wide. Detection via registry might fail immediately after bootstrapper exit; `Get-AppxProvisionedPackage` is the reliable detection method.

### Linux
- Microsoft announced the retirement of the native Linux client. The Linux install script provided uses the legacy repository, but migrating to the Edge/Chrome PWA is highly recommended.
