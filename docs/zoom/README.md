# Zoom Deployment Guide

Zoom Workplace (formerly Zoom Meetings) is a unified communications platform. Zoom provides IT-specific installer packages for both macOS and Windows that support silent, zero-touch deployment.

## Prerequisites

Before deploying Zoom, ensure you have:
1. **Installer URL:** The latest IT-specific PKG (macOS) or MSI (Windows) from your Zoom download center or internal CDN.
2. **Zoom configuration (optional):** For managed settings (SSO, auto-update behavior, meeting defaults), configure policies in your Zoom Admin Console under **Account → Settings → MDM**.

## Operating System Guides

- [🍎 macOS Deployment Guide](#macos-deployment)
- [🪟 Windows Deployment Guide](#windows-deployment)

## General Principles

- **Idempotency:** All scripts check if Zoom is already installed before attempting installation.
- **Silent Deployment:** Uses vendor-supported flags (`/usr/sbin/installer -pkg` on macOS, `msiexec /quiet` on Windows).
- **Logging:** All installations log to local files (`/var/log/mdm-zoom-install.log` on macOS, `C:\ProgramData\MDM\Logs\zoom-install.log` on Windows) and output to `stdout`.
- **No profiles required:** Zoom does not require configuration profiles (PPPC, System Extension) for basic deployment.

---

## macOS Deployment

### Configure the Installation Script

1. Locate the script at [`scripts/macos/zoom/install.sh`](../../scripts/macos/zoom/install.sh).
2. Open the script and verify the `CONFIG` block:

```bash
### ====== CONFIG ==============================================================
ZOOM_PKG_URL="https://zoom.us/client/latest/ZoomInstallerIT.pkg"

EXPECTED_SHA256=""
EXPECTED_TEAM_ID="BJ4HAAB9B3"  # Zoom Video Communications Team ID

FORCE_REINSTALL="false"
LOG_FILE="/var/log/mdm-zoom-install.log"
### ===========================================================================
```

*   **`ZOOM_PKG_URL`**: Zoom provides an IT-specific PKG at the URL above. You may also host it on your internal CDN.
*   **`EXPECTED_SHA256`** *(Optional but recommended)*: The SHA256 hash of the PKG.
*   **`EXPECTED_TEAM_ID`**: Pre-configured to `BJ4HAAB9B3` (Zoom Video Communications, Inc.).

### Deploy the Script via MDM

Upload the configured script to your MDM and deploy it as a shell script to run as **Root**.

### Script Behavior
- **Idempotent:** Checks if `/Applications/zoom.us.app` exists before running.
- **Silent:** Uses `/usr/sbin/installer -target / -pkg` for zero-touch installation.
- **Logging:** Writes to `/var/log/mdm-zoom-install.log` and `stdout`.

---

## Windows Deployment

### Configure the Installation Script

1. Locate the script at [`scripts/windows/zoom/install.ps1`](../../scripts/windows/zoom/install.ps1).
2. Open the script and modify the `CONFIG` block with your MSI URL.

### Deploy the Script via MDM

Upload to your MDM (Intune, JumpCloud, etc.) and deploy as a PowerShell script running as **System/Administrator**.

---

## Troubleshooting

| Issue | Resolution |
|---|---|
| **Zoom installs but does not auto-update** | Deploy the Zoom IT Admin installer (not the consumer version). The IT PKG/MSI includes auto-update capabilities managed by the admin console. |
| **Users see "Zoom is not optimized for your Mac"** | Ensure you are deploying the universal (Intel + Apple Silicon) PKG from the IT download page. |
| **SSO login not enforced** | Configure SSO policies in the Zoom Admin Console under **Account → Settings → Security**. SSO enforcement is server-side, not installer-side. |

---

## MDM Platform Notes

| MDM | Notes |
|---|---|
| **Jamf Pro** | Upload PKG directly as a policy payload; no profile needed. |
| **Microsoft Intune** | Deploy as a macOS shell script (macOS) or Win32 app (Windows MSI). |
| **Kandji** | Use Custom Script for shell deployment. |
| **Mosyle** | Upload as a custom app under Apps → Custom Apps. |
