#!/bin/bash
set -euo pipefail

###############################################################################
# Google Chrome macOS install (MDM Script)
# Version: 1.0
# Tested on: macOS 13 Ventura, 14 Sonoma, 15 Sequoia (Intel + Apple Silicon)
#
# Chrome provides a universal PKG for enterprise deployment.
# For managed Chrome preferences (policies), deploy a configuration profile
# or use the Google Admin console MDM integration.
###############################################################################

### ====== CONFIG ==============================================================
# Google's enterprise PKG — universal (Intel + ARM)
CHROME_PKG_URL="https://dl.google.com/dl/chrome/mac/universal/stable/gcea/googlechrome.pkg"

EXPECTED_SHA256=""
EXPECTED_TEAM_ID="EQHXZ8M8AV"  # Google LLC Apple Developer Team ID

FORCE_REINSTALL="false"
LOG_FILE="/var/log/mdm-chrome-install.log"
### ===========================================================================

umask 077
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

log()  { echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] [GoogleChrome] $*"; }
fail() { log "ERROR: $*"; exit 1; }
warn() { log "WARNING: $*"; }

[[ "$(id -u)" -eq 0 ]] || fail "Must run as root/admin."

log "Starting Google Chrome install."
log "macOS $(sw_vers -productVersion) | $(uname -m)"

is_chrome_installed() {
  [[ -d "/Applications/Google Chrome.app" ]]
}

if [[ "$FORCE_REINSTALL" != "true" ]] && is_chrome_installed; then
  INSTALLED_VERSION=$(/usr/bin/defaults read "/Applications/Google Chrome.app/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null || echo "unknown")
  log "SKIP: Google Chrome already installed (version: ${INSTALLED_VERSION}). No action taken."
  exit 0
fi

TMP_DIR="$(mktemp -d)"
PKG_PATH="$TMP_DIR/GoogleChrome.pkg"
trap 'rm -rf "$TMP_DIR" 2>/dev/null || true' EXIT

log "Downloading Google Chrome enterprise PKG..."
curl -fLsS --retry 3 --retry-delay 2 --connect-timeout 15 --max-time 900 \
  -o "$PKG_PATH" "$CHROME_PKG_URL" \
  || fail "Download failed. Check CHROME_PKG_URL."

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

log "Installing Google Chrome silently..."
/usr/sbin/installer -pkg "$PKG_PATH" -target / || fail "installer(8) failed."

if is_chrome_installed; then
  INSTALLED_VERSION=$(/usr/bin/defaults read "/Applications/Google Chrome.app/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null || echo "unknown")
  log "SUCCESS: Google Chrome installed (version: ${INSTALLED_VERSION})."
  exit 0
fi

fail "Google Chrome installation did not validate. Check ${LOG_FILE}."
