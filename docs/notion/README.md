# Notion MDM Deployment Guide

Notion is a single space where you can think, write, and plan.

## Platforms Supported
- ✅ **macOS**: DMG
- ✅ **Windows**: EXE

## Installation Scripts
- [macOS Install Script](file:///Users/machine/Documents/VStudio/mdm-installer/scripts/macos/notion/install.sh)
- [macOS Uninstall Script](file:///Users/machine/Documents/VStudio/mdm-installer/scripts/macos/notion/uninstall.sh)
- [Windows Install Script](file:///Users/machine/Documents/VStudio/mdm-installer/scripts/windows/notion/install.ps1)

## MDM Deployment Notes

### macOS
- **Format**: `.dmg`
- **Details**: Mounts DMG and copies `Notion.app` to `/Applications`.

### Windows
- **Format**: `.exe` (Squirrel)
- **Details**: The script executes the installer silently.

### Linux
- **Note**: Notion does not provide an official Linux desktop client. Linux users are recommended to use Notion in the web browser.
