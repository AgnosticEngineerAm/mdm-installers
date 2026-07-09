## Pull Request Checklist

Thank you for contributing! Please fill out this checklist before requesting review.

---

### Description

<!-- Briefly describe what this PR does and why. Link any related issues. -->

**Related issue(s):** Closes #

---

### Type of Change

- [ ] 🐛 Bug fix (non-breaking change that fixes an issue)
- [ ] 📦 New script (new install/uninstall script for a tool)
- [ ] 📋 New profile (new `.mobileconfig` configuration profile)
- [ ] 📚 Documentation update
- [ ] 🔧 Improvement / refactor (no new functionality)
- [ ] 🤖 CI / workflow change
- [ ] 🏗️ Repo structure / housekeeping

---

### Script Checklist (if adding/modifying a shell script)

- [ ] Script begins with `#!/bin/bash` and `set -euo pipefail`
- [ ] Script has root check at the top (`[[ "$(id -u)" -eq 0 ]] || fail "..."`)
- [ ] Script is **idempotent** — tested that running it twice does not double-install or error
- [ ] Script has a `log()` function with UTC timestamp
- [ ] Temp files use `mktemp -d` and are cleaned up via `trap ... EXIT`
- [ ] `curl` uses `--retry 3 --connect-timeout 15 --max-time 900`
- [ ] `EXPECTED_SHA256` and `EXPECTED_TEAM_ID` variables are present (even if empty)
- [ ] `FORCE_REINSTALL` flag is present
- [ ] `LOG_FILE` is set to `/var/log/mdm-<toolname>-install.log`
- [ ] **No real secrets, tokens, or credentials** are hardcoded — only `PASTE_YOUR_VALUE_HERE` placeholders
- [ ] ShellCheck passes locally (run: `shellcheck scripts/macos/<tool>/install.sh`)

### PowerShell Script Checklist (if adding/modifying a `.ps1` script)

- [ ] Script has `#Requires -RunAsAdministrator`
- [ ] Script has `Set-StrictMode -Version Latest` and `$ErrorActionPreference = "Stop"`
- [ ] Script is idempotent — tested that running it twice does not error
- [ ] Hash verified with `Get-FileHash -Algorithm SHA256`
- [ ] **No real secrets or credentials** hardcoded
- [ ] PSScriptAnalyzer passes locally

### Profile Checklist (if adding/modifying a `.mobileconfig`)

- [ ] Profile is valid XML (run: `plutil -lint profile.mobileconfig`)
- [ ] Each payload has a **unique** `PayloadUUID`
- [ ] `PayloadDisplayName` and `PayloadDescription` are descriptive
- [ ] Profile grants minimum required permissions only
- [ ] A `README.md` in the same directory explains what the profile does and its deploy order

---

### Testing

**Tested on:**

| Platform | Version | MDM | Result |
|---|---|---|---|
| macOS | | | ✅ / ❌ |
| Windows | | | ✅ / ❌ |
| Linux | | | ✅ / ❌ |

**MDM tested with:** (e.g., Jamf Pro 11.x, Intune, Kandji, tested manually as root)

**Test scenario:** (fresh install / already installed skip / force reinstall)

---

### Screenshots / Log Output (optional but appreciated)

<!-- Paste relevant log output or a screenshot of successful MDM deployment -->

---

### Additional Notes

<!-- Anything else reviewers should know? Version pins? Known limitations? -->
