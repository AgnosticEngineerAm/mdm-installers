# JumpCloud Deployment Guide

## Overview
Cloud directory platform with built-in cross-platform MDM capabilities.

## Script Deployment
Commands > Add Command. Choose OS (Linux, Mac, Windows) and run as Root/System.

## Variables & Secrets
JumpCloud handles secret passing securely via their UI.

## Best Practices
1. **Idempotency:** All scripts in `mdm-installers` are idempotent. You can run them repeatedly without causing issues.
2. **Execution Context:** Always ensure scripts run as **System** (Windows) or **Root** (macOS/Linux).
3. **Profiles First:** Deploy any required `.mobileconfig` profiles *before* executing the installation scripts to avoid user prompts.
