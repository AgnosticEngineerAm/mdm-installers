#!/bin/bash
set -euo pipefail

###############################################################################
# 1Password macOS install (MDM Script)
# Version: 1.0
# Tested on: macOS 13 Ventura, 14 Sonoma, 15 Sequoia (Intel + Apple Silicon)
#
# 1Password 8 uses a universal PKG for enterprise deployment.
# For managed settings (SSO, team sign-in), configure 1Password Business
# policies in your 1Password admin console.
###############################################################################

### ====== CONFIG ==============================================================
# 1Password enterprise PKG download
# Get your pinned URL from: https://1password.com/downloads/mac/
# Or use the latest: https://downloads.1password.com/mac/1Password-latest.pkg
ONEPASSWORD_PKG_URL="https://downloads.1password.com/mac/1Password-latest.pkg"

EXPECTED_SHA256=""
EXPECTED_TEAM_ID="2BUA8C4S2C"  # AgileBits Inc. (1Password) Team ID

FORCE_REINSTALL="false"
LOG_FILE="/var/log/mdm-1password-install.log"
### ===========================================================================

umask 077
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

log()  { echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] [1Password] $*"; }
fail() { log "ERROR: $*"; exit 1; }
warn() { log "WARNING: $*"; }

[[ "$(id -u)" -eq 0 ]] || fail "Must run as root/admin."

log "Starting 1Password install."
log "macOS $(sw_vers -productVersion) | $(uname -m)"

is_1password_installed() {
  [[ -d "/Applications/1Password.app" ]] \
    || [[ -d "/Applications/1Password 7.app" ]] \
    || pkgutil --pkgs 2>/dev/null | grep -qi "agilebits.onepassword"
}

if [[ "$FORCE_REINSTALL" != "true" ]] && is_1password_installed; then
  # Detect which version
  if [[ -d "/Applications/1Password.app" ]]; then
    INSTALLED_VERSION=$(/usr/bin/defaults read "/Applications/1Password.app/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null || echo "unknown")
    log "SKIP: 1Password already installed (version: ${INSTALLED_VERSION}). No action taken."
  else
    log "SKIP: 1Password already installed. No action taken."
  fi
  exit 0
fi

TMP_DIR="$(mktemp -d)"
PKG_PATH="$TMP_DIR/1Password.pkg"
trap 'rm -rf "$TMP_DIR" 2>/dev/null || true' EXIT

log "Downloading 1Password PKG..."
curl -fLsS --retry 3 --retry-delay 2 --connect-timeout 15 --max-time 900 \
  -o "$PKG_PATH" "$ONEPASSWORD_PKG_URL" \
  || fail "Download failed. Check ONEPASSWORD_PKG_URL."

if ! file "$PKG_PATH" | grep -qi "xar archive"; then
  fail "Downloaded file is not a valid .pkg."
fi

if [[ -n "$EXPECTED_SHA256" ]]; then
  ACTUAL="$(shasum -a 256 "$PKG_PATH" | awk '{print $1}')"
  [[ "$ACTUAL" == "$EXPECTED_SHA256" ]] || fail "SHA256 mismatch. Got: ${ACTUAL}"
  log "SHA256 verified."
else
  warn "EXPECTED_SHA256 not set; skipping checksum verification."
fi

if [[ -n "$EXPECTED_TEAM_ID" ]]; then
  SIG_OUT="$(/usr/sbin/pkgutil --check-signature "$PKG_PATH" 2>/dev/null || true)"
  echo "$SIG_OUT" | grep -qi "Status: signed" || fail "PKG is not signed."
  echo "$SIG_OUT" | grep -q "$EXPECTED_TEAM_ID" || fail "Team ID mismatch (expected ${EXPECTED_TEAM_ID})."
  log "PKG signature verified."
fi

log "Installing 1Password silently..."
/usr/sbin/installer -pkg "$PKG_PATH" -target / || fail "installer(8) failed."

if is_1password_installed; then
  INSTALLED_VERSION=$(/usr/bin/defaults read "/Applications/1Password.app/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null || echo "unknown")
  log "SUCCESS: 1Password installed (version: ${INSTALLED_VERSION})."
  exit 0
fi

fail "1Password installation did not validate. Check ${LOG_FILE}."
