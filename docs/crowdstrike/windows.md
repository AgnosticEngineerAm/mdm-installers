# CrowdStrike Falcon Windows Deployment Guide

Deploying CrowdStrike Falcon on Windows uses the EXE installer. The PowerShell script automates the download, verification, and silent installation while injecting your CID.

## 1. Configure the Installation Script

1. Locate the script at [`scripts/windows/crowdstrike/install.ps1`](../../scripts/windows/crowdstrike/install.ps1).
2. Open the script and modify the `CONFIG` block:

```powershell
# ====== CONFIG ================================================================
$CSInstallerUrl  = 'https://your-internal-repo.com/WindowsSensor.exe'
$CSCustomerId    = 'YOUR_CUSTOMER_ID_WITH_CHECKSUM_HERE'
$ExpectedSHA256  = 'optional_sha256_hash_here'
$ForceReinstall  = $false
# =============================================================================
```

*   **`$CSInstallerUrl`**: A direct download link to the CrowdStrike Windows EXE.
*   **`$CSCustomerId`**: Your CrowdStrike CID. The script passes this to the EXE via `CID="..."`.
*   **`$ExpectedSHA256`** *(Optional)*: If provided, the script will verify the EXE before installing.

## 2. Deploy via MDM or RMM

Deploy the `install.ps1` script via your management tool.

- **Execution Context:** The script **must** run as `SYSTEM` or `Administrator`.
- **PowerShell Execution Policy:** Ensure the script runs with `-ExecutionPolicy Bypass`.

### Script Behavior
- **Idempotent:** Checks if the `CSFalconService` is running or if the executable exists in `C:\Program Files\CrowdStrike\`.
- **Silent Install:** Uses `/install /quiet /norestart CID=<CID>`.
- **Logging:** Logs are written to `C:\ProgramData\MDM\Logs\crowdstrike-install.log`.
