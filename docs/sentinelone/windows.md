# SentinelOne Windows Deployment Guide

Deploying SentinelOne on Windows is straightforward and relies on the standard MSI installer combined with silent installation flags and the Site Token.

## 1. Configure the Installation Script

The Windows installation script uses PowerShell to download the MSI, verify its hash, and install it silently using `msiexec.exe`.

1. Locate the script at [`scripts/windows/sentinelone/install.ps1`](../../scripts/windows/sentinelone/install.ps1).
2. Open the script and modify the `CONFIG` block:

```powershell
# ====== CONFIG ================================================================
$S1MsiUrl      = 'https://your-internal-repo.com/sentinelone-windows.msi'
$S1SiteToken   = 'YOUR_SENTINELONE_SITE_TOKEN'
$ExpectedSHA256 = 'optional_sha256_hash_here'
$ForceReinstall = $false
# =============================================================================
```

*   **`$S1MsiUrl`**: A direct download link to the SentinelOne Windows MSI.
*   **`$S1SiteToken`**: Your SentinelOne Site Token. The script passes this to the MSI via the `SITE_TOKEN="..."` argument.
*   **`$ExpectedSHA256`** *(Optional)*: If provided, the script will verify the MSI before installing.

## 2. Deploy via MDM or RMM

Deploy the `install.ps1` script via your management tool (e.g., Microsoft Intune Proactive Remediations, JumpCloud Commands, or PDQ Deploy).

- **Execution Context:** The script **must** run as `SYSTEM` or `Administrator`.
- **PowerShell Execution Policy:** Ensure the script runs with `-ExecutionPolicy Bypass`.

### Script Behavior
- **Idempotent:** Checks if the `SentinelAgent` service exists or if the app is registered in WMI before attempting installation.
- **Silent Install:** Uses `msiexec.exe /i <path> /quiet /norestart SITE_TOKEN="<token>"`.
- **Logging:** 
  - Standard logs are written to `C:\ProgramData\MDM\Logs\sentinelone-install.log`.
  - Verbose MSI logs are written to `C:\ProgramData\MDM\Logs\sentinelone-msi.log`.
