<div align="center">

# 🛡️ mdm-installers

**The definitive MDM-agnostic deployment hub for IT engineers worldwide.**

Hardened install scripts, ready-to-deploy configuration profiles, and battle-tested guides — for macOS, Windows, and Linux — that work with *any* MDM.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![ShellCheck](https://img.shields.io/github/actions/workflow/status/CyberEnthusiastAm/mdm-installers/shellcheck.yml?label=ShellCheck&logo=gnubash)](../../actions/workflows/shellcheck.yml)
[![PSScriptAnalyzer](https://img.shields.io/github/actions/workflow/status/CyberEnthusiastAm/mdm-installers/psscriptanalyzer.yml?label=PSScriptAnalyzer&logo=powershell)](../../actions/workflows/psscriptanalyzer.yml)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)
[![Good First Issues](https://img.shields.io/github/issues/CyberEnthusiastAm/mdm-installers/good%20first%20issue)](../../issues?q=label%3A%22good+first+issue%22)
[![macOS](https://img.shields.io/badge/macOS-14%2B-black?logo=apple)](scripts/macos/)
[![Windows](https://img.shields.io/badge/Windows-10%2F11-blue?logo=windows)](scripts/windows/)
[![Linux](https://img.shields.io/badge/Linux-Ubuntu%20%7C%20RHEL%20%7C%20Debian-orange?logo=linux)](scripts/linux/)

</div>

---

## Why This Repo Exists

Every MDM vendor publishes *their own* deployment guides. Every EDR vendor ships *different* profile requirements. Every IT team writes the same boilerplate bash script from scratch — and forgets the checksum.

**This repo changes that.** One place. All the scripts. Real profiles. Production-hardened. MDM-agnostic.

> Scripts are **idempotent** by design — safe to re-run on every MDM check-in. If the app is already installed, they skip silently. If not, they install silently, verifying integrity along the way.

---

## Table of Contents

- [Script Coverage Matrix](#script-coverage-matrix)
- [MDM Compatibility](#mdm-compatibility)
- [Quick Start](#quick-start)
- [Configuration Profiles](#configuration-profiles)
- [Documentation](#documentation)
- [Security Design](#security-design)
- [Repository Structure](#repository-structure)
- [Contributing](#contributing)
- [Community](#community)

---

## Script Coverage Matrix

| Tool | macOS Install | macOS Uninstall | Windows Install | Linux Install | Profiles |
|---|:---:|:---:|:---:|:---:|:---:|
| **SentinelOne** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **CrowdStrike Falcon** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Microsoft Defender** | ✅ | — | ✅ | — | ✅ |
| **Zoom** | ✅ | — | ✅ | — | — |
| **Slack** | ✅ | — | ✅ | — | — |
| **Google Chrome** | ✅ | — | ✅ | — | — |
| **Microsoft 365 Apps** | ✅ | — | ✅ | — | — |
| **1Password** | ✅ | — | — | — | — |
| **Docker Desktop** | ✅ | — | — | — | — |
| **JumpCloud Agent** | ✅ | — | ✅ | ✅ | — |

> ✅ = Available · — = Not applicable or planned · 🚧 = In progress
>
> **Missing something?** [Open a Tool Request →](../../issues/new?template=new_tool_request.yml)

---

## MDM Compatibility

All scripts are written to work with **any MDM that can run scripts as root/admin**. Platform-specific notes are in [`docs/mdm-platforms/`](docs/mdm-platforms/).

| MDM | Scripts | Profiles | Notes |
|---|:---:|:---:|---|
| **Jamf Pro** | ✅ | ✅ | Fully tested; policy + smart group examples in docs |
| **Microsoft Intune** | ✅ | ✅ | Shell scripts (macOS) + Remediation scripts (Windows) |
| **Kandji** | ✅ | ✅ | Custom Scripts + Library profiles |
| **Mosyle** | ✅ | ✅ | Script runner + profile upload |
| **JumpCloud** | ✅ | ✅ | Commands + MDM profiles |
| **Rippling** | ✅ | ✅ | App deployment + profile push |
| **VMware Workspace ONE** | ✅ | ✅ | Intelligent Hub scripts |
| **Addigy** | ✅ | ✅ | Custom Facts + profile deployment |
| **SimpleMDM** | ✅ | ✅ | Script packages |

---

## Quick Start

### Deploy SentinelOne on macOS (60 seconds)

**Step 1 — Deploy profiles first** (prevents user prompts):
```
profiles/macos/sentinelone/system-extension.mobileconfig
profiles/macos/sentinelone/network-extension.mobileconfig
profiles/macos/sentinelone/pppc.mobileconfig
profiles/macos/sentinelone/notifications.mobileconfig
```

**Step 2 — Edit the script config block:**
```bash
# In scripts/macos/sentinelone/install.sh
S1_PKG_URL="https://your-release-url/SentinelOne.pkg"
S1_SITE_TOKEN="PASTE_YOUR_SITE_TOKEN_HERE"
EXPECTED_SHA256="abc123..."   # optional but recommended
EXPECTED_TEAM_ID="4QXE9H42T"  # SentinelOne's Team ID
```

**Step 3 — Upload to your MDM and deploy to scope.**

✅ The script skips gracefully if S1 is already installed. Safe to re-run anytime.

### Deploy CrowdStrike Falcon on macOS

**Step 1 — Deploy profiles first:**
```
profiles/macos/crowdstrike/system-extension.mobileconfig
profiles/macos/crowdstrike/network-extension.mobileconfig
profiles/macos/crowdstrike/pppc.mobileconfig
```

**Step 2 — Edit the script config block:**
```bash
# In scripts/macos/crowdstrike/install.sh
CS_PKG_URL="https://your-release-url/FalconSensor.pkg"
CS_CUSTOMER_ID="PASTE_YOUR_CID_HERE"
EXPECTED_SHA256="abc123..."
```

**Step 3 — Upload to MDM and deploy.**

→ Full guides for every tool are in [`docs/`](docs/)

---

## Configuration Profiles

> **🔑 Key principle**: Deploy profiles **before** installing agent software. Profiles unlock OS-level permissions silently — without them, users see security prompt dialogs.

```
profiles/macos/
├── sentinelone/
│   ├── pppc.mobileconfig            # Full Disk Access + Privacy
│   ├── system-extension.mobileconfig # System Extension allowlist
│   ├── network-extension.mobileconfig # Content filter allowlist
│   └── notifications.mobileconfig   # Notification preferences
├── crowdstrike/
│   ├── pppc.mobileconfig
│   ├── system-extension.mobileconfig
│   └── network-extension.mobileconfig
├── microsoft-defender/
│   ├── pppc.mobileconfig
│   └── system-extension.mobileconfig
└── baseline/
    ├── filevault-escrow.mobileconfig # FileVault key escrow (MDM)
    └── screensaver-lock.mobileconfig # Screen lock / idle timeout policy
```

Each profile directory contains a `README.md` documenting the bundle IDs, payload types, and deploy order.

> **Note on UUIDs**: Profile `PayloadUUID` values must be unique per organization. Before deploying to production, regenerate UUIDs with `uuidgen` or your MDM's profile editor.

---

## Documentation

### Per-Tool Guides
- [SentinelOne](docs/sentinelone/README.md) — macOS · Windows · Linux
- [CrowdStrike Falcon](docs/crowdstrike/README.md) — macOS · Windows · Linux
- [Microsoft Defender](docs/microsoft-defender/README.md) — macOS · Windows
- [Zoom](docs/zoom/README.md) — macOS · Windows

### MDM Platform Guides
| Platform | Guide |
|---|---|
| Jamf Pro | [docs/mdm-platforms/jamf.md](docs/mdm-platforms/jamf.md) |
| Microsoft Intune | [docs/mdm-platforms/intune.md](docs/mdm-platforms/intune.md) |
| Kandji | [docs/mdm-platforms/kandji.md](docs/mdm-platforms/kandji.md) |
| Mosyle | [docs/mdm-platforms/mosyle.md](docs/mdm-platforms/mosyle.md) |
| JumpCloud | [docs/mdm-platforms/jumpcloud.md](docs/mdm-platforms/jumpcloud.md) |
| Rippling | [docs/mdm-platforms/rippling.md](docs/mdm-platforms/rippling.md) |
| Workspace ONE | [docs/mdm-platforms/workspace-one.md](docs/mdm-platforms/workspace-one.md) |

### Decision Guides
- [Choosing an EDR: SentinelOne vs CrowdStrike vs Defender](docs/guides/choosing-an-edr.md)
- [Profile Deploy Order — Why It Matters](docs/guides/profile-deploy-order.md)
- [Secret Management Across MDMs](docs/guides/secret-management.md)

### Migration Guides
- [CrowdStrike → SentinelOne](docs/migrations/crowdstrike-to-sentinelone.md)
- [Jamf → Intune](docs/migrations/jamf-to-intune.md)

---

## Security Design

Every script in this repository is built on the same hardened foundation:

| Feature | Implementation |
|---|---|
| **Fail fast** | `set -euo pipefail` (bash) / `$ErrorActionPreference = "Stop"` (PS) |
| **Root enforcement** | Check `id -u` / `#Requires -RunAsAdministrator` at entry |
| **Idempotency** | Multi-signal detection (binary, receipt, app bundle, LaunchDaemon) |
| **Integrity** | Optional SHA256 checksum + pkg signature Team ID verification |
| **Secret hygiene** | Tokens staged to disk at `chmod 600`, never logged |
| **Temp file cleanup** | `trap 'rm -rf "$TMP_DIR"' EXIT` guarantees cleanup |
| **Resilient downloads** | `curl --retry 3 --connect-timeout 15 --max-time 900` |
| **Audit logging** | UTC-timestamped log to `/var/log/mdm-<tool>-install.log` + stdout |

---

## Repository Structure

```
mdm-installers/
├── scripts/
│   ├── macos/
│   │   ├── _lib/common.sh          # Shared functions (logging, download, verify)
│   │   ├── sentinelone/
│   │   │   ├── install.sh
│   │   │   └── uninstall.sh
│   │   ├── crowdstrike/
│   │   ├── microsoft-defender/
│   │   ├── zoom/
│   │   ├── slack/
│   │   ├── google-chrome/
│   │   ├── microsoft-office/
│   │   ├── 1password/
│   │   ├── docker-desktop/
│   │   └── jumpcloud-agent/
│   ├── windows/
│   │   ├── _lib/common.ps1         # Shared PowerShell functions
│   │   ├── sentinelone/
│   │   ├── crowdstrike/
│   │   ├── zoom/
│   │   ├── slack/
│   │   ├── google-chrome/
│   │   ├── microsoft-365-apps/
│   │   └── jumpcloud-agent/
│   └── linux/
│       ├── sentinelone/
│       ├── crowdstrike/
│       └── jumpcloud-agent/
├── profiles/
│   └── macos/
│       ├── sentinelone/
│       ├── crowdstrike/
│       ├── microsoft-defender/
│       └── baseline/
├── docs/
│   ├── sentinelone/
│   ├── crowdstrike/
│   ├── microsoft-defender/
│   ├── zoom/
│   ├── mdm-platforms/
│   ├── migrations/
│   └── guides/
└── templates/
    └── user-message-sentinelone.md
```

---

## Contributing

We welcome contributions from IT engineers and sysadmins of all skill levels.

- Read [CONTRIBUTING.md](CONTRIBUTING.md) for script standards, profile standards, and the PR process.
- Browse [`good first issue`](../../issues?q=label%3A%22good+first+issue%22) for beginner-friendly tasks.
- Have a new tool to add? [Open a Tool Request](../../issues/new?template=new_tool_request.yml).
- Found a bug? [Open a Bug Report](../../issues/new?template=bug_report.yml).

**Please do not commit secrets, tokens, or credentials.** See [SECURITY.md](SECURITY.md).

---

## Community

| Resource | Link |
|---|---|
| 🍎 MacAdmins Slack | [macadmins.org](https://www.macadmins.org/) — `#mdm-agnostic`, `#jamf`, `#intune` |
| 🤖 r/macsysadmin | [reddit.com/r/macsysadmin](https://reddit.com/r/macsysadmin) |
| 🪟 r/Intune | [reddit.com/r/Intune](https://reddit.com/r/Intune) |
| 🔍 Installomator | [github.com/Installomator/Installomator](https://github.com/Installomator/Installomator) — 300+ app labels |
| 🔒 macOS Security | [github.com/usnistgov/macos_security](https://github.com/usnistgov/macos_security) — NIST baselines |

---

## License

[MIT](LICENSE) — free to use, modify, and distribute. Attribution appreciated but not required.

---

<div align="center">

**Built by IT engineers, for IT engineers. Star ⭐ this repo if it saved you time.**

</div>
