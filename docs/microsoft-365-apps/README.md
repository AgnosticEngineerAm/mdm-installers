# Microsoft 365 Apps Deployment Guide

Microsoft 365 Apps (formerly Office 365 ProPlus) includes Word, Excel, PowerPoint, Outlook, and Teams. Microsoft provides enterprise deployment packages for both macOS and Windows.

## Prerequisites

Before deploying Microsoft 365 Apps, ensure you have:
1. **Microsoft 365 license:** Users must have valid Microsoft 365 Business/Enterprise licenses.
2. **Installer URL (macOS):** The latest Office suite PKG from Microsoft's CDN or your internal mirror.
3. **Office Deployment Tool (Windows):** The ODT with a custom `configuration.xml` for silent deployment.

## Operating System Guides

- [🍎 macOS Deployment Guide](#macos-deployment)
- [🪟 Windows Deployment Guide](#windows-deployment)

## General Principles

- **Idempotency:** All scripts check if Microsoft 365 Apps are already installed before attempting installation.
- **Silent Deployment:** Uses enterprise PKG (macOS) and ODT with `/configure` (Windows).
- **Logging:** All installations log to local files and `stdout`.

---

## macOS Deployment

### Configure the Installation Script

1. Locate the script at [`scripts/macos/microsoft-office/install.sh`](../../scripts/macos/microsoft-office/install.sh).
2. Open the script and modify the `CONFIG` block:

```bash
### ====== CONFIG ==============================================================
OFFICE_PKG_URL="PASTE_YOUR_OFFICE_PKG_URL_HERE"

EXPECTED_SHA256=""
EXPECTED_TEAM_ID="UBF8T346G9"  # Microsoft Corporation Team ID

FORCE_REINSTALL="false"
LOG_FILE="/var/log/mdm-office-install.log"
### ===========================================================================
```

*   **`OFFICE_PKG_URL`**: Microsoft provides the latest Office suite installer at [macadmins.software](https://macadmins.software). Download and re-host, or use the direct CDN link.
*   **`EXPECTED_TEAM_ID`**: Pre-configured to `UBF8T346G9` (Microsoft Corporation).

### Deploy the Script via MDM

Upload the configured script to your MDM and deploy it as a shell script to run as **Root**.

### Script Behavior
- **Idempotent:** Checks if `/Applications/Microsoft Word.app` exists.
- **Silent:** Uses `/usr/sbin/installer -target / -pkg`.
- **Logging:** Writes to `/var/log/mdm-office-install.log` and `stdout`.

---

## Windows Deployment

### Configure the Installation Script

1. Locate the script at [`scripts/windows/microsoft-365-apps/install.ps1`](../../scripts/windows/microsoft-365-apps/install.ps1).
2. The script uses the **Office Deployment Tool (ODT)** with a `configuration.xml` for silent installation.

### Deploy the Script via MDM

Upload to your MDM (Intune, JumpCloud, etc.) and deploy as a PowerShell script running as **System/Administrator**.

> **Intune users:** Microsoft Intune has a built-in Microsoft 365 Apps deployment type under **Apps → Windows → Microsoft 365 Apps**. Consider using this instead of a custom script for Intune-managed devices.

---

## Troubleshooting

| Issue | Resolution |
|---|---|
| **Office installs but apps require activation** | Users must sign in with their Microsoft 365 account. For device-based licensing, configure Shared Computer Activation in your `configuration.xml`. |
| **"Your account doesn't allow editing on a Mac"** | The user's license tier may not include desktop apps. Verify the license in the Microsoft 365 Admin Center. |
| **Office updates are not being installed** | On macOS, Microsoft AutoUpdate (MAU) handles updates. Deploy the MAU configuration profile to manage update channels and behavior. |
| **The ODT fails with "Another installation is in progress"** | Wait for the existing Office installation/update to complete. Check `C:\Windows\Temp` for stuck Click-to-Run processes. |

---

## MDM Platform Notes

| MDM | Notes |
|---|---|
| **Jamf Pro** | Upload the Office suite PKG as a policy payload. Jamf also offers pre-built Microsoft Office definitions in Patch Management. |
| **Microsoft Intune** | Use the built-in Microsoft 365 Apps deployment type for Windows. For macOS, deploy the PKG as a macOS LOB app. |
| **Kandji** | Microsoft Office is available as a pre-built Library Item. |
| **Mosyle** | Upload the PKG under Custom Apps. |
