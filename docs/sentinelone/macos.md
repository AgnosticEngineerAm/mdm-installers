# SentinelOne macOS Deployment Guide

Deploying SentinelOne on macOS requires specific configuration profiles to grant the agent the necessary system permissions. **Failing to deploy these profiles before the installation script will result in the user being prompted for permissions.**

## 1. Deploy Configuration Profiles (Crucial)

Before running the installation script, you **must** deploy the following `.mobileconfig` profiles via your MDM to the target macOS devices. These profiles pre-approve the agent's requirements.

> **⚠️ IMPORTANT:** You must generate a new `PayloadUUID` for each profile before deploying them in your production environment. Use the `uuidgen` command in your terminal.

| Profile Name | File | Description |
| :--- | :--- | :--- |
| **PPPC (Privacy Preferences)** | [`pppc.mobileconfig`](../../profiles/macos/sentinelone/pppc.mobileconfig) | Grants Full Disk Access to the SentinelOne agent daemon and GUI app. Required for the agent to scan the entire filesystem. |
| **System Extension** | [`system-extension.mobileconfig`](../../profiles/macos/sentinelone/system-extension.mobileconfig) | Pre-approves the SentinelOne Endpoint Security system extension (Team ID: `4QXE9H42T`). |
| **Network Extension** | [`network-extension.mobileconfig`](../../profiles/macos/sentinelone/network-extension.mobileconfig) | Pre-approves the SentinelOne Content Filter for network traffic inspection. |
| **Notifications** | [`notifications.mobileconfig`](../../profiles/macos/sentinelone/notifications.mobileconfig) | Prevents the macOS "Allow Notifications" prompt from appearing to the user. |

## 2. Configure the Installation Script

Once the profiles are deployed and applied to the devices, configure the installation script.

1. Locate the script at [`scripts/macos/sentinelone/install.sh`](../../scripts/macos/sentinelone/install.sh).
2. Open the script and modify the `CONFIG` block:

```bash
### ====== CONFIG ==============================================================
S1_PKG_URL="https://your-internal-repo.com/sentinelone-macos.pkg"
S1_SITE_TOKEN="YOUR_SENTINELONE_SITE_TOKEN"

EXPECTED_SHA256="optional_sha256_hash_here"
FORCE_REINSTALL="false"
### ===========================================================================
```

*   **`S1_PKG_URL`**: A direct download link to the SentinelOne macOS PKG.
*   **`S1_SITE_TOKEN`**: Your SentinelOne Site Token.
*   **`EXPECTED_SHA256`** *(Optional but recommended)*: The SHA256 hash of the PKG. If provided, the script will verify the download's integrity before installing.

## 3. Deploy the Script via MDM

Upload the configured script to your MDM (Jamf Pro, Kandji, Intune, JumpCloud, etc.) and deploy it as a shell script to run as **Root**.

### Script Behavior
- **Idempotent:** Checks if `/opt/sentinelone/bin/sentinelctl` exists before running. If found, it exits silently.
- **Silent:** Uses `/usr/sbin/installer -target / -pkg` to install without user interaction.
- **Logging:** Writes detailed logs to `/var/log/mdm-sentinelone-install.log` and `stdout`.
