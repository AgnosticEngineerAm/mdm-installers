# Kandji Deployment Guide

## Overview
Modern, automated MDM for Apple devices with an extensive auto-apps catalog.

## Script Deployment
Create a Custom App or Custom Script item. Kandji runs scripts as root.

## Variables & Secrets
Set variables directly in the script editor or use Kandji global variables.

## Best Practices
1. **Idempotency:** All scripts in `mdm-installers` are idempotent. You can run them repeatedly without causing issues.
2. **Execution Context:** Always ensure scripts run as **System** (Windows) or **Root** (macOS/Linux).
3. **Profiles First:** Deploy any required `.mobileconfig` profiles *before* executing the installation scripts to avoid user prompts.
