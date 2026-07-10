# Microsoft Intune Deployment Guide

## Overview
Enterprise UEM from Microsoft, primarily for Windows but supports macOS/Linux.

## Script Deployment
Deploy .ps1 scripts natively on Windows. For macOS, upload as Shell Scripts.

## Variables & Secrets
Supports variables via standard environment variable passing or config files.

## Best Practices
1. **Idempotency:** All scripts in `mdm-installers` are idempotent. You can run them repeatedly without causing issues.
2. **Execution Context:** Always ensure scripts run as **System** (Windows) or **Root** (macOS/Linux).
3. **Profiles First:** Deploy any required `.mobileconfig` profiles *before* executing the installation scripts to avoid user prompts.
