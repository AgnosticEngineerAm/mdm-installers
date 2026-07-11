# Slack Deployment Guide

Slack is a business communication platform. Slack distributes as a DMG (macOS) and MSI/EXE (Windows) for enterprise deployment.

## Prerequisites

Before deploying Slack, ensure you have:
1. **Installer URL:** The latest DMG (macOS) or MSI (Windows) hosted on your internal CDN or GitHub Releases. Slack does not provide a stable direct-download URL for IT admins — you must download and re-host.
2. **Workspace configuration (optional):** Pre-configure workspace sign-in via Slack's admin dashboard.

## Operating System Guides

- [🍎 macOS Deployment Guide](#macos-deployment)
- [🪟 Windows Deployment Guide](#windows-deployment)

## General Principles

- **Idempotency:** All scripts check if Slack is already installed before attempting installation.
- **Silent Deployment:** macOS uses DMG mount-and-copy; Windows uses MSI silent install.
- **Logging:** All installations log to local files and `stdout`.
- **No profiles required:** Slack does not require configuration profiles for deployment.

---

## macOS Deployment

### Important: DMG Hosting

Slack for macOS is distributed as a `.dmg` file. Unlike tools that provide a stable enterprise URL, Slack requires you to:
1. Download the latest DMG from [slack.com/downloads/mac](https://slack.com/downloads/mac).
2. Host it on your internal CDN, S3 bucket, or as a GitHub Release asset.
3. Set `SLACK_DMG_URL` in the install script to your hosted URL.

### Configure the Installation Script

1. Locate the script at [`scripts/macos/slack/install.sh`](../../scripts/macos/slack/install.sh).
2. Open the script and modify the `CONFIG` block:

```bash
### ====== CONFIG ==============================================================
SLACK_DMG_URL="PASTE_YOUR_SLACK_DMG_URL_HERE"

EXPECTED_SHA256=""

FORCE_REINSTALL="false"
LOG_FILE="/var/log/mdm-slack-install.log"
### ===========================================================================
```

*   **`SLACK_DMG_URL`**: Your hosted DMG URL.
*   **`EXPECTED_SHA256`** *(Optional but recommended)*: SHA256 hash of the DMG.

### Deploy the Script via MDM

Upload the configured script to your MDM and deploy it as a shell script to run as **Root**.

### Script Behavior
- **Idempotent:** Checks if `/Applications/Slack.app` exists.
- **DMG Install:** Mounts the DMG, copies `Slack.app` to `/Applications/`, and unmounts.
- **Logging:** Writes to `/var/log/mdm-slack-install.log` and `stdout`.

---

## Windows Deployment

### Configure the Installation Script

1. Locate the script at [`scripts/windows/slack/install.ps1`](../../scripts/windows/slack/install.ps1).
2. Modify the `CONFIG` block with your MSI/EXE URL.

### Deploy the Script via MDM

Upload to your MDM and deploy as a PowerShell script running as **System/Administrator**.

---

## Troubleshooting

| Issue | Resolution |
|---|---|
| **Slack installs as user-scoped (per-user) instead of system-wide** | Ensure you are using the enterprise MSI (not the `.exe` from the website). The per-user EXE installs to `%LOCALAPPDATA%`, which is not visible to other users. |
| **DMG download returns HTML instead of the binary** | The URL you are using may be a redirect page. Download the DMG manually and re-host it with a direct-download link. |
| **Slack auto-updates override the deployed version** | This is expected behavior. Slack's built-in updater will update to the latest version after first launch. To control versions, disable auto-update via Slack admin policies. |

---

## MDM Platform Notes

| MDM | Notes |
|---|---|
| **Jamf Pro** | Package the DMG as a `.pkg` using `productbuild` or upload as a policy script. |
| **Microsoft Intune** | Deploy the MSI as a Line-of-business app (Windows) or shell script (macOS). |
| **Kandji** | Use Custom Script for shell deployment. |
| **Mosyle** | Upload the DMG under Custom Apps. |
