# JumpCloud Agent Deployment Guide

JumpCloud is a cloud directory and MDM platform. The JumpCloud Agent is deployed to managed devices to enable directory services, device management, and policy enforcement. JumpCloud provides platform-specific installers with a Connect Key for enrollment.

## Prerequisites

Before deploying the JumpCloud Agent, ensure you have:
1. **JumpCloud Connect Key:** Found in your JumpCloud Admin Console under **Devices → +**.
2. **Installer:** JumpCloud provides platform-specific installers for macOS, Windows, and Linux.

## Operating System Guides

- [🍎 macOS Deployment Guide](#macos-deployment)
- [🪟 Windows Deployment Guide](#windows-deployment)
- [🐧 Linux Deployment Guide](#linux-deployment)

## General Principles

- **Idempotency:** All scripts check if the JumpCloud Agent is already installed and running.
- **Silent Deployment:** Uses vendor-supported silent installation methods on each platform.
- **Logging:** All installations log to local files and `stdout`.
- **No profiles required for basic install:** The JumpCloud Agent does not require configuration profiles on macOS for basic deployment. JumpCloud MDM profiles are deployed from the JumpCloud Admin Console.

---

## macOS Deployment

### Configure the Installation Script

1. Locate the script at [`scripts/macos/jumpcloud-agent/install.sh`](../../scripts/macos/jumpcloud-agent/install.sh).
2. Open the script and modify the `CONFIG` block with your Connect Key.

### Deploy the Script via MDM

Upload the configured script to your MDM and deploy it as a shell script to run as **Root**.

### Script Behavior
- **Idempotent:** Checks if the JumpCloud Agent service is running.
- **Silent:** Uses the JumpCloud kickstart installer script.
- **Logging:** Writes to the configured log file and `stdout`.

---

## Windows Deployment

### Configure the Installation Script

1. Locate the script at [`scripts/windows/jumpcloud-agent/install.ps1`](../../scripts/windows/jumpcloud-agent/install.ps1).
2. Modify the `CONFIG` block with your Connect Key and installer URL.

### Deploy the Script via MDM

Upload to your MDM and deploy as a PowerShell script running as **System/Administrator**.

---

## Linux Deployment

### Configure the Installation Script

1. Locate the script at [`scripts/linux/jumpcloud-agent/install.sh`](../../scripts/linux/jumpcloud-agent/install.sh).
2. Modify the `CONFIG` block with your Connect Key.

### Deploy the Script

Run the script as `root` on target Linux machines via your configuration management tool (Ansible, Puppet, Chef) or remote management platform.

---

## Troubleshooting

| Issue | Resolution |
|---|---|
| **Agent installs but device does not appear in JumpCloud console** | Verify the Connect Key is correct. Check that the device can reach `agent.jumpcloud.com` on port 443. |
| **Agent shows "Pending" status in console** | The agent is waiting for initial sync. Allow 5–10 minutes. If still pending, restart the agent service and check logs at `/opt/jc/jcagent.log` (macOS/Linux) or `C:\Program Files\JumpCloud\Plugins\Contrib\jcagent.log` (Windows). |
| **MDM enrollment fails on macOS** | JumpCloud MDM requires a separate MDM enrollment profile. The agent alone does not enable MDM — you must also deploy the MDM enrollment profile from the JumpCloud Admin Console. |

---

## MDM Platform Notes

| MDM | Notes |
|---|---|
| **Jamf Pro** | Deploy the install script as a policy. JumpCloud Agent and Jamf can coexist on the same device. |
| **Microsoft Intune** | Deploy as a PowerShell script (Windows) or shell script (macOS). |
| **JumpCloud (self-deploy)** | Use JumpCloud Commands to push the agent to devices already enrolled via another MDM. |
