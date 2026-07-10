# Workspace ONE (VMware) Deployment Guide

## Overview
Cross-platform unified endpoint management.

## Script Deployment
Upload .sh or .ps1 files in the Resources > Scripts section. Set execution context to System.

## Variables & Secrets
Use Workspace ONE lookup values to inject variables.

## Best Practices
1. **Idempotency:** All scripts in `mdm-installers` are idempotent. You can run them repeatedly without causing issues.
2. **Execution Context:** Always ensure scripts run as **System** (Windows) or **Root** (macOS/Linux).
3. **Profiles First:** Deploy any required `.mobileconfig` profiles *before* executing the installation scripts to avoid user prompts.
