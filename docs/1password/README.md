# 1Password Deployment Guide

1Password is an enterprise password manager. AgileBits provides a universal PKG (macOS) and MSI (Windows) for managed deployment. 1Password 8 is the current enterprise version.

## Prerequisites

Before deploying 1Password, ensure you have:
1. **1Password Business account:** Required for enterprise deployment and policy management.
2. **Installer URL:** AgileBits provides a stable download URL for the macOS PKG. For Windows, download the MSI from the 1Password downloads page.
3. **Team sign-in (optional):** Pre-configure team sign-in via the 1Password Business admin console.

## Operating System Guides

- [🍎 macOS Deployment Guide](#macos-deployment)
- [🪟 Windows Deployment Guide](#windows-deployment)

## General Principles

- **Idempotency:** All scripts check if 1Password is already installed before attempting installation.
- **Silent Deployment:** Uses enterprise PKG (macOS) and MSI (Windows) with silent flags.
- **Logging:** All installations log to local files and `stdout`.
- **No profiles required:** 1Password does not require PPPC or System Extension profiles for basic deployment.

---

## macOS Deployment

### Configure the Installation Script

1. Locate the script at [`scripts/macos/1password/install.sh`](../../scripts/macos/1password/install.sh).
2. Open the script and verify the `CONFIG` block:

```bash
### ====== CONFIG ==============================================================
ONEPASSWORD_PKG_URL="https://downloads.1password.com/mac/1Password-latest.pkg"

EXPECTED_SHA256=""
EXPECTED_TEAM_ID="2BUA8C4S2C"  # AgileBits Inc. (1Password) Team ID

FORCE_REINSTALL="false"
LOG_FILE="/var/log/mdm-1password-install.log"
### ===========================================================================
```

*   **`ONEPASSWORD_PKG_URL`**: AgileBits provides a stable "latest" URL. You may also pin to a specific version.
*   **`EXPECTED_TEAM_ID`**: Pre-configured to `2BUA8C4S2C` (AgileBits Inc.).

### Deploy the Script via MDM

Upload the configured script to your MDM and deploy it as a shell script to run as **Root**.

### Script Behavior
- **Idempotent:** Checks if `/Applications/1Password.app` or `/Applications/1Password 7.app` exists.
- **Silent:** Uses `/usr/sbin/installer -target / -pkg`.
- **Logging:** Writes to `/var/log/mdm-1password-install.log` and `stdout`.

---

## Windows Deployment

### Configure the Installation Script

1. Locate the script at [`scripts/windows/1password/install.ps1`](../../scripts/windows/1password/install.ps1).
2. Modify the `CONFIG` block with your MSI URL.

### Deploy the Script via MDM

Upload to your MDM and deploy as a PowerShell script running as **System/Administrator**.

---

## Troubleshooting

| Issue | Resolution |
|---|---|
| **1Password installs but users cannot find their team vault** | Users must sign in to their 1Password Business account after launch. Pre-configure team sign-in URL via the 1Password admin console. |
| **Browser extension does not connect to the desktop app** | 1Password 8 uses a native messaging bridge. Ensure the desktop app is launched at least once before the browser extension is installed. |
| **macOS prompts for Accessibility permission** | 1Password may request Accessibility access for auto-fill. Deploy a PPPC profile granting `com.1password.1password` the `Accessibility` payload if you want to suppress this prompt. |

---

## MDM Platform Notes

| MDM | Notes |
|---|---|
| **Jamf Pro** | Upload the PKG as a policy payload. Use the 1Password SCIM bridge for automated user provisioning. |
| **Microsoft Intune** | Deploy the MSI as a Line-of-business app (Windows) or the PKG as a macOS LOB app. |
| **Kandji** | 1Password is available as a pre-built Library Item. |
| **Mosyle** | Upload the PKG under Custom Apps. |
