# iTerm2 MDM Deployment Guide

iTerm2 is a terminal emulator for macOS that does amazing things.

## Platforms Supported
- ✅ **macOS**: ZIP (macOS exclusive)

## Installation Scripts
- [macOS Install Script](file:///Users/machine/Documents/VStudio/mdm-installer/scripts/macos/iterm2/install.sh)
- [macOS Uninstall Script](file:///Users/machine/Documents/VStudio/mdm-installer/scripts/macos/iterm2/uninstall.sh)

## MDM Deployment Notes

### macOS
- **Format**: `.zip`
- **Details**: The script unzips the downloaded file and moves `iTerm.app` to `/Applications`.
- **Profiles**: iTerm2 supports custom preferences via `com.googlecode.iterm2` domain. You can configure it to load a specific `com.googlecode.iterm2.plist` via MDM to enforce themes, fonts, or profiles.
