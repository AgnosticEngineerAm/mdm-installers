# Figma MDM Deployment Guide

Figma is a collaborative interface design tool.

## Platforms Supported
- ✅ **macOS**: ZIP
- ✅ **Windows**: EXE

## Installation Scripts
- [macOS Install Script](file:///Users/machine/Documents/VStudio/mdm-installer/scripts/macos/figma/install.sh)
- [macOS Uninstall Script](file:///Users/machine/Documents/VStudio/mdm-installer/scripts/macos/figma/uninstall.sh)
- [Windows Install Script](file:///Users/machine/Documents/VStudio/mdm-installer/scripts/windows/figma/install.ps1)

## MDM Deployment Notes

### macOS
- **Format**: `.zip`
- **Details**: The script unzips the downloaded file and moves `Figma.app` to `/Applications`.

### Windows
- **Format**: `.exe` (Squirrel)
- **Details**: The Windows script uses the `--silent` flag. Note that Figma is a user-level app on Windows by default, which can make system-level MDM deployment slightly tricky if the MSI is not used. Figma provides an MSI for Enterprise customers which may be preferred if available in your tenant.
