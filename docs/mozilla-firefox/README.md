# Mozilla Firefox MDM Deployment Guide

Mozilla Firefox is a popular enterprise browser with robust management capabilities.

## Platforms Supported
- ✅ **macOS**: Enterprise PKG
- ✅ **Windows**: Enterprise MSI
- ✅ **Linux**: Native package managers (apt, dnf, yum)

## Installation Scripts
- [macOS Install Script](file:///Users/machine/Documents/VStudio/mdm-installer/scripts/macos/mozilla-firefox/install.sh)
- [macOS Uninstall Script](file:///Users/machine/Documents/VStudio/mdm-installer/scripts/macos/mozilla-firefox/uninstall.sh)
- [Windows Install Script](file:///Users/machine/Documents/VStudio/mdm-installer/scripts/windows/mozilla-firefox/install.ps1)
- [Linux Install Script](file:///Users/machine/Documents/VStudio/mdm-installer/scripts/linux/mozilla-firefox/install.sh)

## MDM Deployment Notes

### macOS (Jamf Pro / Kandji / Intune)
- **Format**: `.pkg`
- **Updates**: Firefox Auto-Updater is included, but can be disabled via a Configuration Profile setting `DisableAppUpdate` to true.
- **Policies**: Use the [Mozilla Firefox ADMX template](https://github.com/mozilla/policy-templates) to generate a macOS `.mobileconfig`.

### Windows (Intune / SCCM)
- **Format**: `.msi`
- **System context**: Install as System.
- **Updates**: Can be managed via Group Policy Object (GPO). Download the ADMX templates from Mozilla.

### Linux
- **Format**: `.deb` / `.rpm`
- **Notes**: On Ubuntu 22.04+, `apt install firefox` installs the snap version by default. The script handles standard `apt` installation.

## Configuration Profiles
Enterprise policies such as Homepage, Bookmarks, and Extension Whitelisting can be deployed using the `org.mozilla.firefox` domain.
