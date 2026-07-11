#!/bin/bash
set -euo pipefail

###############################################################################
# Microsoft Edge macOS install (MDM Script)
# Version: 1.0
# Tested on: macOS 13 Ventura, 14 Sonoma, 15 Sequoia (Intel + Apple Silicon)
###############################################################################

### ====== CONFIG ==============================================================
# Stable universal PKG from Microsoft:
EDGE_PKG_URL="https://go.microsoft.com/fwlink/?linkid=2093504"

EXPECTED_SHA256=""
EXPECTED_TEAM_ID="UBF8T346G9"  # Microsoft Corporation

FORCE_REINSTALL="false"
LOG_FILE="/var/log/mdm-edge-install.log"
### ===========================================================================

umask 077
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

if [[ -f "$(dirname "$0")/../_lib/common.sh" ]]; then
  source "$(dirname "$0")/../_lib/common.sh"
else
  log()  { echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] [Edge] $*"; }
  fail() { log "ERROR: $*"; exit 1; }
  warn() { log "WARNING: $*"; }
fi

[[ "$(id -u)" -eq 0 ]] || fail "Must run as root/admin."

log "Starting Microsoft Edge install."
log "macOS $(sw_vers -productVersion) | $(uname -m)"

is_edge_installed() {
  [[ -d "/Applications/Microsoft Edge.app" ]] || pkgutil --pkgs 2>/dev/null | grep -qi "com.microsoft.edgemac"
}

if [[ "$FORCE_REINSTALL" != "true" ]] && is_edge_installed; then
  INSTALLED_VERSION=$(/usr/bin/defaults read "/Applications/Microsoft Edge.app/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null || echo "unknown")
  log "SKIP: Microsoft Edge already installed (version: ${INSTALLED_VERSION}). No action taken."
  exit 0
fi

TMP_DIR="$(mktemp -d)"
PKG_PATH="$TMP_DIR/Edge.pkg"
trap 'rm -rf "$TMP_DIR" 2>/dev/null || true' EXIT

log "Downloading Microsoft Edge PKG..."
curl -fLsS --retry 3 --retry-delay 2 --connect-timeout 15 --max-time 900 \
  -L -o "$PKG_PATH" "$EDGE_PKG_URL" \
  || fail "Download failed."

if ! file "$PKG_PATH" | grep -qi "xar archive"; then
  fail "Downloaded file is not a valid .pkg."
fi

if [[ -n "$EXPECTED_SHA256" ]]; then
  ACTUAL="$(shasum -a 256 "$PKG_PATH" | awk '{print $1}')"
  [[ "$ACTUAL" == "$EXPECTED_SHA256" ]] || fail "SHA256 mismatch."
fi

if [[ -n "$EXPECTED_TEAM_ID" ]]; then
  SIG_OUT="$(/usr/sbin/pkgutil --check-signature "$PKG_PATH" 2>/dev/null || true)"
  echo "$SIG_OUT" | grep -qi "Status: signed" || fail "PKG is not signed."
  echo "$SIG_OUT" | grep -q "$EXPECTED_TEAM_ID" || fail "Team ID mismatch."
fi

log "Installing Microsoft Edge silently..."
/usr/sbin/installer -pkg "$PKG_PATH" -target / || fail "installer(8) failed."

if is_edge_installed; then
  INSTALLED_VERSION=$(/usr/bin/defaults read "/Applications/Microsoft Edge.app/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null || echo "unknown")
  log "SUCCESS: Microsoft Edge installed (version: ${INSTALLED_VERSION})."
  exit 0
fi

fail "Microsoft Edge installation did not validate."
