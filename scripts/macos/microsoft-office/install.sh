#!/bin/bash
set -euo pipefail

###############################################################################
# Microsoft 365 Apps (Office) macOS install (MDM Script)
# Version: 1.0
# Tested on: macOS 13 Ventura, 14 Sonoma, 15 Sequoia (Intel + Apple Silicon)
#
# This script installs the Microsoft 365 Business/Enterprise suite PKG.
# The PKG includes: Word, Excel, PowerPoint, Outlook, OneNote, OneDrive, Teams.
#
# Activation requires users to sign in with their Microsoft 365 account,
# OR you can deploy a license profile (volume license) via your MDM.
###############################################################################

### ====== CONFIG ==============================================================
# Microsoft's official suite PKG — hosted on officecdn.microsoft.com
# Latest always: https://go.microsoft.com/fwlink/?linkid=525133
OFFICE_PKG_URL="https://go.microsoft.com/fwlink/?linkid=525133"

# To pin a specific version, get the URL from:
# https://macadmins.software/

EXPECTED_SHA256=""
EXPECTED_TEAM_ID="UBF8T346G9"  # Microsoft Corporation Apple Developer Team ID

FORCE_REINSTALL="false"
LOG_FILE="/var/log/mdm-office365-install.log"
### ===========================================================================

umask 077
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

log()  { echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] [Office365] $*"; }
fail() { log "ERROR: $*"; exit 1; }
warn() { log "WARNING: $*"; }

[[ "$(id -u)" -eq 0 ]] || fail "Must run as root/admin."

log "Starting Microsoft 365 Apps install."
log "macOS $(sw_vers -productVersion) | $(uname -m)"

is_office_installed() {
  # Check for the core Office apps
  [[ -d "/Applications/Microsoft Word.app" ]] \
    || [[ -d "/Applications/Microsoft Excel.app" ]] \
    || pkgutil --pkgs 2>/dev/null | grep -qi "com.microsoft.office"
}

if [[ "$FORCE_REINSTALL" != "true" ]] && is_office_installed; then
  WORD_VERSION=$(/usr/bin/defaults read "/Applications/Microsoft Word.app/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null || echo "unknown")
  log "SKIP: Microsoft Office already installed (Word: ${WORD_VERSION}). No action taken."
  exit 0
fi

TMP_DIR="$(mktemp -d)"
PKG_PATH="$TMP_DIR/Office365.pkg"
trap 'rm -rf "$TMP_DIR" 2>/dev/null || true' EXIT

log "Downloading Microsoft 365 Apps suite PKG (~2 GB — please be patient)..."
curl -fLsS --retry 3 --retry-delay 5 --connect-timeout 30 --max-time 3600 \
  -o "$PKG_PATH" "$OFFICE_PKG_URL" \
  || fail "Download failed. Check OFFICE_PKG_URL or network connectivity."

if ! file "$PKG_PATH" | grep -qi "xar archive"; then
  fail "Downloaded file is not a valid .pkg."
fi

if [[ -n "$EXPECTED_SHA256" ]]; then
  ACTUAL="$(shasum -a 256 "$PKG_PATH" | awk '{print $1}')"
  [[ "$ACTUAL" == "$EXPECTED_SHA256" ]] || fail "SHA256 mismatch. Got: ${ACTUAL}"
  log "SHA256 verified."
else
  warn "EXPECTED_SHA256 not set; skipping checksum verification. Recommend pinning a specific version."
fi

if [[ -n "$EXPECTED_TEAM_ID" ]]; then
  SIG_OUT="$(/usr/sbin/pkgutil --check-signature "$PKG_PATH" 2>/dev/null || true)"
  echo "$SIG_OUT" | grep -qi "Status: signed" || fail "PKG is not signed."
  echo "$SIG_OUT" | grep -q "$EXPECTED_TEAM_ID" || fail "Team ID mismatch (expected ${EXPECTED_TEAM_ID})."
  log "PKG signature verified."
fi

log "Installing Microsoft 365 Apps silently (this may take several minutes)..."
/usr/sbin/installer -pkg "$PKG_PATH" -target / || fail "installer(8) failed."

if is_office_installed; then
  WORD_VERSION=$(/usr/bin/defaults read "/Applications/Microsoft Word.app/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null || echo "unknown")
  log "SUCCESS: Microsoft 365 Apps installed (Word: ${WORD_VERSION})."
  log "Users will need to sign in with their Microsoft 365 account to activate."
  exit 0
fi

fail "Microsoft 365 Apps installation did not validate. Check ${LOG_FILE}."
