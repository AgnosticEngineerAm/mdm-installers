# VLC Media Player MDM Deployment Guide

VLC is a free and open source cross-platform multimedia player.

## Platforms Supported
- ✅ **macOS**: DMG
- ✅ **Windows**: EXE (NSIS)
- ✅ **Linux**: Native package managers

## Installation Scripts
- [macOS Install Script](file:///Users/machine/Documents/VStudio/mdm-installer/scripts/macos/vlc-media-player/install.sh)
- [macOS Uninstall Script](file:///Users/machine/Documents/VStudio/mdm-installer/scripts/macos/vlc-media-player/uninstall.sh)
- [Windows Install Script](file:///Users/machine/Documents/VStudio/mdm-installer/scripts/windows/vlc-media-player/install.ps1)
- [Linux Install Script](file:///Users/machine/Documents/VStudio/mdm-installer/scripts/linux/vlc-media-player/install.sh)

## MDM Deployment Notes

### macOS
- **Format**: `.dmg`
- **Details**: The script mounts the DMG, copies `VLC.app` to `/Applications`, and unmounts it. 

### Windows
- **Format**: `.exe` (NSIS)
- **Flags**: `/S /L=1033` (Silent, English language).
- **Details**: Official installer is fully silent and system-wide.

### Linux
- Uses `apt install vlc` or `yum install vlc`.
