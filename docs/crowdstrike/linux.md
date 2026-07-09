# CrowdStrike Falcon Linux Deployment Guide

The CrowdStrike Falcon Linux deployment script detects your host OS package manager (`apt`, `dnf`, or `yum`) and handles installation and CID assignment automatically.

## 1. Configure the Installation Script

1. Locate the script at [`scripts/linux/crowdstrike/install.sh`](../../scripts/linux/crowdstrike/install.sh).
2. Open the script and modify the `CONFIG` block:

```bash
### ====== CONFIG ==============================================================
CS_INSTALLER_URL="https://your-internal-repo.com/falcon-sensor-linux.deb" # OR .rpm
CS_CUSTOMER_ID="YOUR_CUSTOMER_ID_WITH_CHECKSUM_HERE"

EXPECTED_SHA256="optional_sha256_hash_here"
FORCE_REINSTALL="false"
### ===========================================================================
```

*   **`CS_INSTALLER_URL`**: A direct download link to the Linux package (`.deb` or `.rpm`). Ensure the package architecture matches your target machines.
*   **`CS_CUSTOMER_ID`**: Your CrowdStrike CID.
*   **`EXPECTED_SHA256`** *(Optional)*: The SHA256 hash of the package.

## 2. Deploy the Script

Run this script as `root` using your configuration management tool (Ansible, Chef, Puppet, etc.).

### Script Behavior
- **Package Manager Detection:** Uses `apt-get`, `dnf`, or `yum` appropriately.
- **Idempotent:** Checks for the presence of `/opt/CrowdStrike/falconctl` and checks package registration.
- **Registration:** Runs `/opt/CrowdStrike/falconctl -s --cid=<CID>` and starts the `falcon-sensor` service.
- **Logging:** Output is directed to `/var/log/mdm-crowdstrike-install.log`.
