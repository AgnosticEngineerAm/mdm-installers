# mdm-installers

Central hub for **MDM deployment assets** (installers, scripts, and configuration profiles) across **macOS** and **Windows**.  
Designed to work with *any* MDM (Rippling, Jamf, Intune, Kandji, Mosyle, Workspace ONE, JumpCloud, etc.).

> **Primary hosting method for installers:** GitHub **Releases** (as release assets), because it provides stable direct-download URLs.

---

## What lives where

### ✅ Installers (PKG / MSI / EXE)
- Stored as **GitHub Release assets**
- Referenced by a stable URL from MDM scripts, for example:
  - **Latest release** (recommended when filenames are consistent):
    - `https://github.com/<OWNER>/<REPO>/releases/latest/download/<ASSET_NAME>`
  - **Pinned version** (tag-specific):
    - `https://github.com/<OWNER>/<REPO>/releases/download/<TAG>/<ASSET_NAME>`

### ✅ Scripts
- Stored in the repo under `scripts/` (version-controlled)
- Script templates are written to be **idempotent** (safe to re-run):
  - If the app is already installed → **skip** and log
  - If not installed → download + install silently

### ✅ macOS Configuration Profiles (optional but recommended)
- Stored under `profiles/`
- Includes PPPC/TCC permissions, system extension allowlists, notifications, etc.
- Many security tools (EDR/AV) require these for a fully silent experience.

---

## Repository structure
mdm-installers/
README.md
scripts/
macos/
sentinelone/
chrome/
slack/
windows/
sentinelone/
chrome/
profiles/
macos/
sentinelone/
pppc/
system-extensions/
docs/
rippling/
jamf/
intune/
