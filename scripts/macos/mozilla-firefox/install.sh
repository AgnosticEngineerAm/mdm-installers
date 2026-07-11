#!/bin/bash
set -euo pipefail

###############################################################################
# Mozilla Firefox macOS install (MDM Script)
# Version: 1.0
# Tested on: macOS 13 Ventura, 14 Sonoma, 15 Sequoia (Intel + Apple Silicon)
#
# Downloads and installs the Firefox Enterprise PKG.
###############################################################################

### ====== CONFIG ==============================================================
# Mozilla provides a stable enterprise PKG URL:
FIREFOX_PKG_URL="https://download.mozilla.org/?product=firefox-pkg-latest-ssl&os=osx&lang=en-US"

EXPECTED_SHA256=""
EXPECTED_TEAM_ID="43AQ936H96"  # Mozilla Corporation

FORCE_REINSTALL="false"
LOG_FILE="/var/log/mdm-firefox-install.log"
### ===========================================================================

umask 077
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

# Source common functions if available, else inline them
if [[ -f "$(dirname "$0")/../_lib/common.sh" ]]; then
  # shellcheck source=../_lib/common.sh
  source "$(dirname "$0")/../_lib/common.sh"
else
  log()  { echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] [Firefox] $*"; }
  fail() { log "ERROR: $*"; exit 1; }
  warn() { log "WARNING: $*"; }
fi

[[ "$(id -u)" -eq 0 ]] || fail "Must run as root/admin."

log "Starting Mozilla Firefox install."
log "macOS $(sw_vers -productVersion) | $(uname -m)"

is_firefox_installed() {
  [[ -d "/Applications/Firefox.app" ]] || pkgutil --pkgs 2>/dev/null | grep -qi "org.mozilla.firefox"
}

if [[ "$FORCE_REINSTALL" != "true" ]] && is_firefox_installed; then
  INSTALLED_VERSION=$(/usr/bin/defaults read /Applications/Firefox.app/Contents/Info.plist CFBundleShortVersionString 2>/dev/null || echo "unknown")
  log "SKIP: Firefox already installed (version: ${INSTALLED_VERSION}). No action taken."
  exit 0
fi

TMP_DIR="$(mktemp -d)"
PKG_PATH="$TMP_DIR/Firefox.pkg"
trap 'rm -rf "$TMP_DIR" 2>/dev/null || true' EXIT

log "Downloading Firefox PKG..."
curl -fLsS --retry 3 --retry-delay 2 --connect-timeout 15 --max-time 900 \
  -L -o "$PKG_PATH" "$FIREFOX_PKG_URL" \
  || fail "Download failed."

if ! file "$PKG_PATH" | grep -qi "xar archive"; then
  fail "Downloaded file is not a valid .pkg."
fi

if [[ -n "$EXPECTED_SHA256" ]]; then
  ACTUAL="$(shasum -a 256 "$PKG_PATH" | awk '{print $1}')"
  [[ "$ACTUAL" == "$EXPECTED_SHA256" ]] || fail "SHA256 mismatch. Got: ${ACTUAL}"
  log "SHA256 verified."
fi

if [[ -n "$EXPECTED_TEAM_ID" ]]; then
  SIG_OUT="$(/usr/sbin/pkgutil --check-signature "$PKG_PATH" 2>/dev/null || true)"
  echo "$SIG_OUT" | grep -qi "Status: signed" || fail "PKG is not signed."
  echo "$SIG_OUT" | grep -q "$EXPECTED_TEAM_ID" || fail "Team ID mismatch."
  log "PKG signature verified."
fi

log "Installing Firefox silently..."
/usr/sbin/installer -pkg "$PKG_PATH" -target / || fail "installer(8) failed."

if is_firefox_installed; then
  INSTALLED_VERSION=$(/usr/bin/defaults read /Applications/Firefox.app/Contents/Info.plist CFBundleShortVersionString 2>/dev/null || echo "unknown")
  log "SUCCESS: Firefox installed (version: ${INSTALLED_VERSION})."
  exit 0
fi

fail "Firefox installation did not validate."
