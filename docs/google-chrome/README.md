# Google Chrome Deployment Guide

Google Chrome is the most widely deployed enterprise browser. Google provides a dedicated enterprise PKG (macOS) and MSI (Windows) with built-in update management and policy support.

## Prerequisites

Before deploying Google Chrome, ensure you have:
1. **Enterprise installer:** Google provides stable enterprise download URLs — no re-hosting required.
2. **Chrome policies (optional):** Manage Chrome policies via [Chrome Enterprise](https://chromeenterprise.google/) or deploy a managed preferences profile.

## Operating System Guides

- [🍎 macOS Deployment Guide](#macos-deployment)
- [🪟 Windows Deployment Guide](#windows-deployment)

## General Principles

- **Idempotency:** All scripts check if Chrome is already installed before attempting installation.
- **Silent Deployment:** Uses enterprise PKG (macOS) and MSI (Windows) with silent flags.
- **Logging:** All installations log to local files and `stdout`.
- **No profiles required for basic install:** Chrome does not need PPPC or System Extension profiles. For managed Chrome policies, deploy a separate configuration profile.

---

## macOS Deployment

### Configure the Installation Script

1. Locate the script at [`scripts/macos/google-chrome/install.sh`](../../scripts/macos/google-chrome/install.sh).
2. Open the script and verify the `CONFIG` block:

```bash
### ====== CONFIG ==============================================================
CHROME_PKG_URL="https://dl.google.com/dl/chrome/mac/universal/stable/gcea/googlechrome.pkg"

EXPECTED_SHA256=""
EXPECTED_TEAM_ID="EQHXZ8M8AV"  # Google LLC Apple Developer Team ID

FORCE_REINSTALL="false"
LOG_FILE="/var/log/mdm-chrome-install.log"
### ===========================================================================
```

*   **`CHROME_PKG_URL`**: Google's official universal enterprise PKG. Works on both Intel and Apple Silicon.
*   **`EXPECTED_TEAM_ID`**: Pre-configured to `EQHXZ8M8AV` (Google LLC).

### Deploy the Script via MDM

Upload the configured script to your MDM and deploy it as a shell script to run as **Root**.

### Script Behavior
- **Idempotent:** Checks if `/Applications/Google Chrome.app` exists.
- **Silent:** Uses `/usr/sbin/installer -target / -pkg`.
- **Logging:** Writes to `/var/log/mdm-chrome-install.log` and `stdout`.

---

## Windows Deployment

### Configure the Installation Script

1. Locate the script at [`scripts/windows/google-chrome/install.ps1`](../../scripts/windows/google-chrome/install.ps1).
2. Modify the `CONFIG` block. Google provides a stable enterprise MSI at:
   - **64-bit:** `https://dl.google.com/dl/chrome/install/googlechromestandaloneenterprise64.msi`

### Deploy the Script via MDM

Upload to your MDM and deploy as a PowerShell script running as **System/Administrator**.

---

## Chrome Enterprise Policies

To manage Chrome settings (homepage, extensions, update behavior), you can:

| Platform | Method |
|---|---|
| **macOS** | Deploy a `.mobileconfig` with `com.google.Chrome` preferences |
| **Windows** | Use Group Policy (ADMX templates) or Intune Settings Catalog |
| **Both** | Use [Chrome Enterprise](https://chromeenterprise.google/) cloud-based policy management |

---

## Troubleshooting

| Issue | Resolution |
|---|---|
| **Chrome installs but does not auto-update** | Ensure the enterprise PKG/MSI was used (not the consumer download). The enterprise installer includes Google Software Update. |
| **Users cannot install extensions** | Chrome extensions are controlled by enterprise policies. Check your Chrome management console for blocklists or allowlists. |
| **"Chrome is being managed by your organization" banner** | This is expected when enterprise policies are deployed. It is informational and cannot be suppressed. |

---

## MDM Platform Notes

| MDM | Notes |
|---|---|
| **Jamf Pro** | Upload the PKG as a policy payload. For Chrome policies, deploy a `com.google.Chrome` configuration profile. |
| **Microsoft Intune** | Deploy the MSI as a Line-of-business app. Use Settings Catalog for Chrome policies. |
| **Kandji** | Chrome is available as a pre-built Library Item in Kandji. |
| **Mosyle** | Upload the PKG under Custom Apps. |
