# CrowdStrike Falcon Deployment Guide

Welcome to the CrowdStrike Falcon deployment guide. CrowdStrike Falcon relies on its unique Customer ID (CID) accompanied by a checksum string for secure enrollment.

## Prerequisites

Before deploying CrowdStrike Falcon, ensure you have:
1. **Customer ID (CID):** You can find your CID (a 32-character alphanumeric string followed by a two-character checksum, e.g., `1234567890ABCDEFGHIJKLMNOPQRSTUV-XX`) in the Falcon Console under **Host setup and management -> Deploy -> Sensor downloads**.
2. **Installers:** The relevant OS-specific installers hosted securely or the direct download URLs.

## Operating System Guides

Select the operating system for specific deployment instructions and configuration profiles:

- [🍎 macOS Deployment Guide](macos.md) (Includes PPPC and System Extension profiles)
- [🪟 Windows Deployment Guide](windows.md)
- [🐧 Linux Deployment Guide](linux.md)

## General Principles

- **Idempotency:** All scripts check if the Falcon sensor is installed and running before attempting installation.
- **Silent Deployment:** We use vendor-supported flags (e.g., `/install /quiet`, `/usr/sbin/installer -pkg`, `apt-get -y`) to ensure silent installation.
- **Logging:** All installations log to local files (`/var/log/mdm-crowdstrike-install.log` on Unix, `C:\ProgramData\MDM\Logs\crowdstrike-install.log` on Windows).
