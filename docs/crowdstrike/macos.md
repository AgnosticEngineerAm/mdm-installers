# CrowdStrike Falcon macOS Deployment Guide

Deploying CrowdStrike Falcon on macOS requires specific configuration profiles to grant the sensor the necessary system permissions. **Failing to deploy these profiles before the installation script will result in the user being prompted for permissions and the sensor operating in a degraded state.**

## 1. Deploy Configuration Profiles (Crucial)

Before running the installation script, you **must** deploy the following `.mobileconfig` profiles via your MDM to the target macOS devices.

> **⚠️ IMPORTANT:** You must generate a new `PayloadUUID` for each profile before deploying them in your production environment. Use the `uuidgen` command in your terminal.

| Profile Name | File | Description |
| :--- | :--- | :--- |
| **PPPC (Privacy Preferences)** | [`pppc.mobileconfig`](../../profiles/macos/crowdstrike/pppc.mobileconfig) | Grants Full Disk Access to the CrowdStrike Falcon agent (`com.crowdstrike.falcon.agent`) and App (`com.crowdstrike.falcon.App`). |
| **System Extension** | [`system-extension.mobileconfig`](../../profiles/macos/crowdstrike/system-extension.mobileconfig) | Pre-approves the CrowdStrike Endpoint Security system extension (Team ID: `X9E956P446`). |
| **Network Extension** | [`network-extension.mobileconfig`](../../profiles/macos/crowdstrike/network-extension.mobileconfig) | Pre-approves the CrowdStrike Content Filter for network traffic inspection. |

## 2. Configure the Installation Script

Once the profiles are deployed, configure the installation script.

1. Locate the script at [`scripts/macos/crowdstrike/install.sh`](../../scripts/macos/crowdstrike/install.sh).
2. Open the script and modify the `CONFIG` block:

```bash
### ====== CONFIG ==============================================================
CS_PKG_URL="https://your-internal-repo.com/FalconSensor-macOS.pkg"
CS_CUSTOMER_ID="YOUR_CUSTOMER_ID_WITH_CHECKSUM_HERE"

EXPECTED_SHA256="optional_sha256_hash_here"
FORCE_REINSTALL="false"
### ===========================================================================
```

*   **`CS_PKG_URL`**: A direct download link to the CrowdStrike macOS PKG.
*   **`CS_CUSTOMER_ID`**: Your CrowdStrike CID.
*   **`EXPECTED_SHA256`** *(Optional)*: The SHA256 hash of the PKG.

## 3. Deploy the Script via MDM

Upload the configured script to your MDM and deploy it as a shell script to run as **Root**.

### Script Behavior
- **Idempotent:** Checks if `Falcon` is registered via `pkgutil` and if `/Applications/Falcon.app` exists.
- **Silent:** Uses `/usr/sbin/installer -target / -pkg`.
- **Registration:** Automatically runs `/Applications/Falcon.app/Contents/Resources/falconctl license <CID>` to license the sensor.
