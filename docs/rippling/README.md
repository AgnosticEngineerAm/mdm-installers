# Rippling MDM Deployment Guide

Rippling is an HRIS platform that includes a built-in IT and Device Management (MDM) module.

## Supported Deployment Types
Rippling supports executing Bash (macOS/Linux) and PowerShell (Windows) scripts.

## Adapting Scripts for Rippling

Scripts in the `mdm-installers` repository are highly compatible with Rippling, with a few caveats:

### 1. Root Execution
Rippling executes scripts on macOS as the `root` user by default. Our scripts check `[[ "$(id -u)" -eq 0 ]]`, so they will pass validation immediately.

### 2. Parameter Passing
Rippling does not support passing arguments to scripts in the same way Jamf does (e.g., no `$4`). You must modify the `CONFIG` block at the top of our scripts to include your specific URLs or Site Tokens before pasting the script into the Rippling console.

### 3. App Catalog
Rippling has an extensive built-in App Catalog. It is highly recommended to use Rippling's native App Catalog for standard apps (like Slack or Zoom) rather than deploying them via our custom scripts. Reserve our scripts for complex security tools (like CrowdStrike or SentinelOne) that require custom configurations or specific installation parameters not supported natively by the Rippling App Catalog.

## Configuration Profiles
Rippling supports uploading custom `.mobileconfig` files for macOS. Ensure you deploy these custom profiles *before* you assign the installation script to the device.
