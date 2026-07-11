# Adobe Acrobat Reader MDM Deployment Guide

Adobe Acrobat Reader is a standard PDF viewer in enterprise environments.

## Platforms Supported
- ✅ **macOS**: PKG
- ✅ **Windows**: EXE

## Installation Scripts
- [macOS Install Script](file:///Users/machine/Documents/VStudio/mdm-installer/scripts/macos/adobe-acrobat-reader/install.sh)
- [macOS Uninstall Script](file:///Users/machine/Documents/VStudio/mdm-installer/scripts/macos/adobe-acrobat-reader/uninstall.sh)
- [Windows Install Script](file:///Users/machine/Documents/VStudio/mdm-installer/scripts/windows/adobe-acrobat-reader/install.ps1)

## MDM Deployment Notes

### macOS
- **Format**: `.pkg`
- **Details**: Adobe often distributes customized PKGs via the Adobe Admin Console. You must generate your own package or obtain the enterprise URL and update the script's `ACROBAT_PKG_URL` variable.

### Windows
- **Format**: `.exe`
- **Flags**: `/sAll /rs /msi EULA_ACCEPT=YES`
- **Details**: The Windows script expects the full offline installer EXE. Ensure you replace `PASTE_YOUR_ACROBAT_READER_EXE_URL_HERE` with your hosted URL.
