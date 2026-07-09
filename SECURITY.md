# Security Policy

## Supported Versions

All scripts and profiles in this repository target the current and previous major versions of each supported platform:

| Platform | Supported Versions |
|---|---|
| macOS | Latest 2 major releases (e.g., Sequoia 15, Sonoma 14) |
| Windows | Windows 10 (22H2+), Windows 11 |
| Linux | Ubuntu 20.04+, RHEL/Rocky 8+, Debian 11+ |

## Reporting a Vulnerability

**Please do NOT open a public GitHub issue for security vulnerabilities.**

If you discover a security vulnerability in any script, profile, workflow, or documentation in this repository, please report it responsibly:

1. **GitHub Private Vulnerability Reporting** (preferred): Use the [Security tab → Report a vulnerability](../../security/advisories/new) feature on this repository.
2. **Alternatively**: Contact the maintainers directly via GitHub by opening a private discussion.

We will acknowledge your report within **48 hours** and aim to provide a fix or workaround within **7 days** for critical issues.

## Security Principles

This repository enforces the following security standards for all contributions:

### 🔐 Secrets & Credentials
- **NEVER** commit tokens, API keys, passwords, site tokens, or customer IDs to this repository.
- All scripts use placeholder values (e.g., `PASTE_YOUR_SITE_TOKEN_HERE`) that must be replaced at deploy time via your MDM's secret management.
- Tokens are always staged to disk with `chmod 600` and ownership `root:wheel` — never logged.
- Recommended pattern: inject secrets as MDM environment variables, not hardcoded values.

### 🛡️ Script Hardening Standards
All shell scripts in this repo adhere to:
- `set -euo pipefail` — fail fast on errors, unset variables, and pipe failures
- `umask 077` — restrictive file creation mask for temp files
- `trap 'rm -rf "$TMP_DIR"' EXIT` — guaranteed cleanup of temporary files
- `curl --retry 3 --connect-timeout 15 --max-time 900` — safe download parameters
- Optional SHA256 + Team ID verification for all downloaded packages
- Root check at script entry (`[[ "$(id -u)" -eq 0 ]]`)

### 🧾 PowerShell Script Standards
All `.ps1` scripts adhere to:
- `#Requires -RunAsAdministrator`
- `Set-StrictMode -Version Latest`
- `$ErrorActionPreference = "Stop"`
- Hash verification via `Get-FileHash` before installation
- No plain-text credentials in script bodies

### 📋 Configuration Profiles
- All `.mobileconfig` files use unique `PayloadUUID` values (generate fresh ones with `uuidgen` for production).
- Profiles are scoped to the minimum required permissions.
- PPPC/TCC profiles grant only the specific entitlements documented by the vendor.

## Dependency & Supply Chain Security
- GitHub Actions workflows are pinned to specific SHA commits (not floating tags) to prevent supply chain attacks.
- Dependabot is enabled on this repository to surface outdated action dependencies.
- GitHub secret scanning is enabled — any accidentally committed secrets will trigger an alert.

## Responsible Disclosure

We follow a **90-day responsible disclosure** timeline. If a fix cannot be provided within that window, we will publish a mitigation advisory explaining the risk and workarounds.

Thank you for helping keep this community resource secure. 🙏
