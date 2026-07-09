# Contributing to mdm-installers

First off — **thank you** for taking the time to contribute! 🎉

This repository exists to serve IT engineers, sysadmins, and MDM experts worldwide. Every script, profile, and doc you contribute helps thousands of people deploy software more safely and reliably.

---

## Table of Contents

- [How Can I Contribute?](#how-can-i-contribute)
- [Getting Started](#getting-started)
- [Script Standards — Shell (macOS / Linux)](#script-standards--shell-macos--linux)
- [Script Standards — PowerShell (Windows)](#script-standards--powershell-windows)
- [Configuration Profile Standards](#configuration-profile-standards)
- [Documentation Standards](#documentation-standards)
- [Adding a New App or Tool](#adding-a-new-app-or-tool)
- [Pull Request Process](#pull-request-process)
- [Issue Reporting](#issue-reporting)
- [Style Guide](#style-guide)

---

## How Can I Contribute?

| Type | Examples |
|---|---|
| 🐛 **Bug fix** | Fix a broken detection, wrong path, or curl flag |
| 📦 **New app script** | Add a macOS/Windows/Linux install script for a new tool |
| 📋 **New profile** | Add a `.mobileconfig` for a new EDR/security tool |
| 📚 **Documentation** | Add MDM-platform notes, a migration guide, or a troubleshooting FAQ |
| 🔧 **Improvement** | Harden an existing script, add SHA256 check, improve logging |
| 🌐 **Translation** | Translate user-facing templates to other languages |

Look for issues tagged [`good first issue`](../../issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22) if you're just getting started.

---

## Getting Started

1. **Fork** this repository.
2. **Clone** your fork: `git clone https://github.com/YOUR_USERNAME/mdm-installers.git`
3. **Create a branch**: `git checkout -b feat/add-zoom-macos`
4. Make your changes following the standards below.
5. **Test** your script on a real macOS/Windows/Linux machine (or VM).
6. **Open a Pull Request** against `main`.

---

## Script Standards — Shell (macOS / Linux)

All shell scripts **must** follow these standards. PRs that don't will be asked to revise.

### Required header

```bash
#!/bin/bash
set -euo pipefail
```

### Mandatory elements

| Requirement | Why |
|---|---|
| `set -euo pipefail` | Fail fast — catch unset variables and pipe errors |
| Root check at top | `[[ "$(id -u)" -eq 0 ]] \|\| fail "Must run as root"` |
| `log()` function with UTC timestamp | MDM consoles show raw stdout — timestamps are essential |
| `fail()` function that logs and exits 1 | Consistent error handling |
| Idempotency check | Skip gracefully if already installed; do not double-install |
| `umask 077` before temp file creation | Prevent world-readable temp files |
| `trap 'rm -rf "$TMP_DIR"' EXIT` | Always clean up temp files |
| `curl` with `--retry 3 --connect-timeout 15 --max-time 900` | Resilient downloads |
| Optional SHA256 verification | `EXPECTED_SHA256` variable, checked if non-empty |
| Optional Team ID verification (macOS) | `EXPECTED_TEAM_ID` variable, checked if non-empty |
| `LOG_FILE` variable | Write to `/var/log/mdm-<appname>-install.log` |
| `FORCE_REINSTALL` flag | Allow MDM admins to force re-install without editing the script |

### Sourcing the shared library

For macOS scripts, source the common library at the top:

```bash
# Source shared library (adjust path as needed for your MDM's script deployment)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../_lib/common.sh
source "$SCRIPT_DIR/../../_lib/common.sh" 2>/dev/null || true
```

> Note: Many MDMs copy scripts to a temp location. The shared lib is provided for local testing. Embed the functions inline if your MDM cannot deploy the lib separately.

### Secrets

- **NEVER** hardcode real tokens, site tokens, customer IDs, or API keys.
- Use `PASTE_YOUR_VALUE_HERE` as the placeholder.
- Document in the config block which values the MDM admin must set.
- Tokens written to disk: `chmod 600`, `chown root:wheel`.
- **Never log tokens** — not even partially.

### Exit codes

| Code | Meaning |
|---|---|
| `0` | Success (installed or already present) |
| `1` | Fatal error |

### Tested on

Document the macOS versions you tested on in the script header comment.

---

## Script Standards — PowerShell (Windows)

```powershell
#Requires -RunAsAdministrator
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
```

| Requirement | Why |
|---|---|
| `#Requires -RunAsAdministrator` | Enforced by PowerShell runtime |
| `Set-StrictMode -Version Latest` | Catches uninitialized variables |
| `$ErrorActionPreference = "Stop"` | Fail fast on terminating errors |
| `Write-Log` function with timestamps | Consistent MDM logging |
| Idempotency check | Skip if already installed |
| `$TempDir = Join-Path $env:TEMP "mdm-install-*"` + cleanup | Temp file hygiene |
| Hash verification via `Get-FileHash -Algorithm SHA256` | Integrity check |
| `$ForceReinstall = $false` | Admin override flag |
| Log to `C:\ProgramData\MDM\Logs\<appname>-install.log` | Standard Windows log path |
| No plain-text secrets in script body | Use MDM environment variables |

---

## Configuration Profile Standards

All `.mobileconfig` files must:

1. **Use unique PayloadUUIDs** — Generate fresh ones with `uuidgen` for production. Never reuse UUIDs across profiles.
2. **Include a clear PayloadDisplayName** and **PayloadDescription** describing what the profile does.
3. **Scope to minimum required permissions** — Do not grant more than the vendor documents as required.
4. **Include a `README.md`** in the same directory documenting:
   - What the profile grants
   - The vendor documentation source
   - Which MDM platforms it has been tested on
   - Deploy order (profiles before agent install)
5. **Be well-formed XML** — Validate with `plutil -lint profile.mobileconfig`.

---

## Documentation Standards

Every new tool must include a `docs/<toolname>/README.md` with:

- **Overview**: What the tool is and why it needs MDM deployment
- **macOS Deployment** section (if applicable)
- **Windows Deployment** section (if applicable)
- **Linux Deployment** section (if applicable)
- **Configuration Profiles** section: list required profiles + deploy order
- **MDM Platform Notes**: any quirks per MDM (Jamf, Intune, Kandji, etc.)
- **Troubleshooting FAQ**: at least 3 common issues

Use present tense. Use second person ("you"). Keep sentences short.

---

## Adding a New App or Tool

1. **Open a [New Tool Request](../../issues/new?template=new_tool_request.yml)** issue first (unless you're already building it).
2. Create the directory structure:
   ```
   scripts/
   ├── macos/<toolname>/install.sh
   ├── windows/<toolname>/install.ps1   (if applicable)
   └── linux/<toolname>/install.sh      (if applicable)
   profiles/
   └── macos/<toolname>/               (if profiles are needed)
   docs/
   └── <toolname>/README.md
   ```
3. Follow the script standards above.
4. Test on at least one real MDM or manually as root.
5. Open your PR — use the PR template checklist.

---

## Pull Request Process

1. One logical change per PR (e.g., don't add Zoom + fix CrowdStrike in the same PR).
2. Fill out the **PR template** completely — incomplete PRs will be held.
3. CI must pass — ShellCheck, PSScriptAnalyzer, and profile validation run automatically.
4. A maintainer will review within **5 business days**.
5. Squash-merge is the default merge strategy.

---

## Issue Reporting

Use the issue templates:
- **Bug Report** — for broken scripts or profiles
- **New Tool Request** — to request support for a new application

For security vulnerabilities, see [SECURITY.md](SECURITY.md).

---

## Style Guide

| Rule | Example |
|---|---|
| Variable names: `UPPER_SNAKE_CASE` (shell) | `PKG_URL`, `SITE_TOKEN` |
| Function names: `lower_snake_case` (shell) | `is_installed()`, `log()` |
| PowerShell: `PascalCase` functions | `Write-Log`, `Get-InstalledVersion` |
| Log prefix: tool name in brackets | `[CrowdStrike]`, `[Zoom]` |
| Temp dir: use `mktemp -d` | Never use a hardcoded temp path |
| Indent: 2 spaces (shell), 4 spaces (PS) | Be consistent within a file |

---

Thank you for making this the best MDM deployment resource on GitHub. 🚀
