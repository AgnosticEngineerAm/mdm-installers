# ManageEngine MDM Plus Deployment Guide

## Overview
Comprehensive IT management software.

## Script Deployment
Use the Custom Script configuration.

## Variables & Secrets
Direct script editing.

## Best Practices
1. **Idempotency:** All scripts in `mdm-installers` are idempotent. You can run them repeatedly without causing issues.
2. **Execution Context:** Always ensure scripts run as **System** (Windows) or **Root** (macOS/Linux).
3. **Profiles First:** Deploy any required `.mobileconfig` profiles *before* executing the installation scripts to avoid user prompts.
