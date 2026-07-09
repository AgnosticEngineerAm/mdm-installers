# SentinelOne Linux Deployment Guide

The SentinelOne Linux deployment script automatically detects the host's package manager (`apt`, `dnf`, or `yum`) and installs the agent seamlessly.

## 1. Configure the Installation Script

1. Locate the script at [`scripts/linux/sentinelone/install.sh`](../../scripts/linux/sentinelone/install.sh).
2. Open the script and modify the `CONFIG` block:

```bash
### ====== CONFIG ==============================================================
S1_PKG_URL="https://your-internal-repo.com/sentinelone-linux.deb" # OR .rpm
S1_SITE_TOKEN="YOUR_SENTINELONE_SITE_TOKEN"

EXPECTED_SHA256="optional_sha256_hash_here"
FORCE_REINSTALL="false"
### ===========================================================================
```

*   **`S1_PKG_URL`**: A direct download link to the Linux package (`.deb` for Ubuntu/Debian, `.rpm` for RHEL/Rocky/CentOS). Ensure the package architecture matches your fleet.
*   **`S1_SITE_TOKEN`**: Your SentinelOne Site Token.
*   **`EXPECTED_SHA256`** *(Optional)*: The SHA256 hash of the package.

## 2. Deploy the Script

Run this script as `root` using your configuration management tool (Ansible, Chef, Puppet, JumpCloud Commands, etc.).

### Script Behavior
- **Package Manager Detection:** Determines whether to use `dpkg`/`apt`, `dnf`, or `yum` based on available commands.
- **Idempotent:** Checks for the presence of `/opt/sentinelone/bin/sentinelctl` and verifies the package is registered with the OS package manager.
- **Registration:** After installation, the script automatically runs `/opt/sentinelone/bin/sentinelctl management token set <token>` and starts the agent.
- **Logging:** Output is directed to `/var/log/mdm-sentinelone-install.log`.
