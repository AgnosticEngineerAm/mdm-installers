# Jamf Pro Deployment Guide

## Overview
The gold standard for macOS and iOS device management.

## Script Deployment
Upload .sh scripts to Settings > Computer Management > Scripts. Use Extension Attributes for reporting.

## Variables & Secrets
Jamf passes script parameters via $4 through $11. Modify our scripts to accept these arguments if desired.

## Best Practices
1. **Idempotency:** All scripts in `mdm-installers` are idempotent. You can run them repeatedly without causing issues.
2. **Execution Context:** Always ensure scripts run as **System** (Windows) or **Root** (macOS/Linux).
3. **Profiles First:** Deploy any required `.mobileconfig` profiles *before* executing the installation scripts to avoid user prompts.
