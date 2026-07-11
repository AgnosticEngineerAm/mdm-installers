# Docker Desktop Deployment Guide

Docker Desktop is a container development environment. Docker provides architecture-specific DMGs (macOS) and EXE/MSI installers (Windows) for enterprise deployment.

## Prerequisites

Before deploying Docker Desktop, ensure you have:
1. **Docker Business subscription:** Required for organization-wide deployment (more than 250 employees or $10M+ revenue).
2. **Installer URL:** Docker provides stable download URLs for macOS (ARM64 and AMD64 DMGs) and Windows.
3. **Hardware requirements:** Virtualization must be enabled (VT-x on Intel, Hyper-V on Windows, Virtualization Framework on Apple Silicon).

## Operating System Guides

- [🍎 macOS Deployment Guide](#macos-deployment)
- [🪟 Windows Deployment Guide](#windows-deployment)

## General Principles

- **Idempotency:** All scripts check if Docker Desktop is already installed before attempting installation.
- **Silent Deployment:** macOS uses DMG mount-and-copy; Windows uses `Docker Desktop Installer.exe` with `--quiet` flag.
- **Logging:** All installations log to local files and `stdout`.
- **Post-install step required:** Docker Desktop requires the user to launch it once to complete setup and accept the license agreement (unless pre-configured via `admin-settings.json`).

---

## macOS Deployment

### Configure the Installation Script

1. Locate the script at [`scripts/macos/docker-desktop/install.sh`](../../scripts/macos/docker-desktop/install.sh).
2. The script auto-detects CPU architecture and downloads the correct DMG:

```bash
### ====== CONFIG ==============================================================
ARCH="$(uname -m)"
if [[ "$ARCH" == "arm64" ]]; then
  DOCKER_DMG_URL="https://desktop.docker.com/mac/main/arm64/Docker.dmg"
else
  DOCKER_DMG_URL="https://desktop.docker.com/mac/main/amd64/Docker.dmg"
fi

EXPECTED_SHA256=""

FORCE_REINSTALL="false"
LOG_FILE="/var/log/mdm-docker-install.log"
### ===========================================================================
```

### Deploy the Script via MDM

Upload the configured script to your MDM and deploy it as a shell script to run as **Root**.

### Script Behavior
- **Idempotent:** Checks if `/Applications/Docker.app` exists.
- **DMG Install:** Mounts the DMG, copies `Docker.app` to `/Applications/`, and unmounts.
- **Architecture-aware:** Automatically selects ARM64 or AMD64 package.
- **Logging:** Writes to `/var/log/mdm-docker-install.log` and `stdout`.

---

## Windows Deployment

### Configure the Installation Script

1. Locate the script at [`scripts/windows/docker-desktop/install.ps1`](../../scripts/windows/docker-desktop/install.ps1).
2. Modify the `CONFIG` block with your installer URL.

### Deploy the Script via MDM

Upload to your MDM and deploy as a PowerShell script running as **System/Administrator**.

> **Important:** Docker Desktop on Windows requires Hyper-V or WSL 2. Ensure these features are enabled before deployment.

---

## Troubleshooting

| Issue | Resolution |
|---|---|
| **Docker installs but fails to start with "Hardware assisted virtualization" error** | Enable virtualization in BIOS/UEFI settings (VT-x for Intel, AMD-V for AMD). On Windows, ensure Hyper-V or WSL 2 is enabled. |
| **Users see the Docker Desktop license agreement on first launch** | Deploy an `admin-settings.json` file to suppress the agreement and pre-configure Docker settings. See [Docker Admin Settings](https://docs.docker.com/desktop/hardened-desktop/settings-management/). |
| **Docker Desktop requires a paid subscription** | Docker Desktop is free for small businesses (fewer than 250 employees and less than $10M revenue). Larger organizations require a Docker Business subscription. |
| **macOS prompts for network extension permission** | Docker Desktop may request a network extension for VPN/proxy integration. Deploy a network extension profile if needed. |

---

## MDM Platform Notes

| MDM | Notes |
|---|---|
| **Jamf Pro** | Package the DMG as a `.pkg` using `productbuild` or deploy the script directly. |
| **Microsoft Intune** | Deploy the EXE installer as a Win32 app with `--quiet --accept-license` arguments. |
| **Kandji** | Use Custom Script for shell deployment. |
| **Mosyle** | Upload under Custom Apps. |
