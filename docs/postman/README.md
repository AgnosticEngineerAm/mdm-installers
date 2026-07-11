# Postman MDM Deployment Guide

Postman is an API platform for building and using APIs.

## Platforms Supported
- ✅ **macOS**: ZIP
- ✅ **Windows**: EXE (Squirrel)
- ✅ **Linux**: Tarball

## Installation Scripts
- [macOS Install Script](file:///Users/machine/Documents/VStudio/mdm-installer/scripts/macos/postman/install.sh)
- [macOS Uninstall Script](file:///Users/machine/Documents/VStudio/mdm-installer/scripts/macos/postman/uninstall.sh)
- [Windows Install Script](file:///Users/machine/Documents/VStudio/mdm-installer/scripts/windows/postman/install.ps1)
- [Linux Install Script](file:///Users/machine/Documents/VStudio/mdm-installer/scripts/linux/postman/install.sh)

## MDM Deployment Notes

### macOS
- **Format**: `.zip`
- **Details**: The script unzips the downloaded file and moves `Postman.app` to `/Applications`.

### Windows
- **Format**: `.exe` (Squirrel)
- **Details**: Postman for Windows is a Squirrel installer. The script uses the `-s` flag to install silently. It typically installs into the user profile (`%LocalAppData%`) if run as a user, but system-wide deployment methods may vary based on your MDM agent context.

### Linux
- **Format**: `.tar.gz`
- **Details**: Extracted to `/opt/Postman` and symlinked to `/usr/bin/postman`.
