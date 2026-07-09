# Addigy Deployment Guide

## Overview
Multi-tenant Apple device management for MSPs.

## Script Deployment
Policies > Custom Software > Installation Script.

## Variables & Secrets
Use Addigy Facts and variables.

## Best Practices
1. **Idempotency:** All scripts in `mdm-installers` are idempotent. You can run them repeatedly without causing issues.
2. **Execution Context:** Always ensure scripts run as **System** (Windows) or **Root** (macOS/Linux).
3. **Profiles First:** Deploy any required `.mobileconfig` profiles *before* executing the installation scripts to avoid user prompts.
