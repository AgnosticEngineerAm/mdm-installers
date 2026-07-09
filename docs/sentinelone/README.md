# SentinelOne Deployment Guide

Welcome to the SentinelOne deployment guide. SentinelOne Singularity requires a layered deployment approach to achieve silent, zero-touch installation across operating systems.

## Prerequisites

Before deploying SentinelOne, ensure you have:
1. **Site Token:** You can find your Site Token in the SentinelOne Management Console under **Settings -> Site -> Site Info**.
2. **Installers:** The relevant PKG, MSI, or DEB/RPM files hosted securely or the direct download URLs.

## Operating System Guides

Select the operating system for specific deployment instructions and configuration profiles:

- [🍎 macOS Deployment Guide](macos.md) (Includes PPPC and System Extension profiles)
- [🪟 Windows Deployment Guide](windows.md) (Includes MSI silent install parameters)
- [🐧 Linux Deployment Guide](linux.md) (Includes apt/dnf/yum package manager instructions)

## General Principles

- **Idempotency:** All scripts in this repository check if the SentinelOne agent is already installed (and the service is running) before attempting to download or install the package again.
- **Silent Deployment:** We use vendor-supported flags (e.g., `msiexec /q`, `/usr/sbin/installer -pkg`, `apt-get -y`) to ensure the user is not prompted.
- **Logging:** All installations log to local files (`/var/log/` on Unix, `C:\ProgramData\MDM\Logs\` on Windows) and output to `stdout` so your MDM can capture the success/failure state.
