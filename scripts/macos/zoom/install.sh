#!/bin/bash
set -euo pipefail

###############################################################################
# Zoom macOS install (MDM Script)
# Version: 1.0
# Tested on: macOS 13 Ventura, 14 Sonoma, 15 Sequoia (Intel + Apple Silicon)
#
# No profiles required for basic install. For managed Zoom settings (SSO,
# auto-update settings, etc.) see your Zoom Account → Advanced → MDM.
###############################################################################

### ====== CONFIG ==============================================================
# Latest universal PKG — update the version URL as needed or use your internal CDN
ZOOM_PKG_URL="https://zoom.us/client/latest/ZoomInstallerIT.pkg"

EXPECTED_SHA256=""       # Optional: sha256 of the pkg
EXPECTED_TEAM_ID="BJ4HAAB9B3"  # Zoom Video Communications Team ID

FORCE_REINSTALL="false"
LOG_FILE="/var/log/mdm-zoom-install.log"
### ===========================================================================

umask 077
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

log()  { echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] [Zoom] $*"; }
fail() { log "ERROR: $*"; exit 1; }
warn() { log "WARNING: $*"; }

[[ "$(id -u)" -eq 0 ]] || fail "Must run as root/admin."

log "Starting Zoom install."
log "macOS $(sw_vers -productVersion) | $(uname -m)"

is_zoom_installed() {
  [[ -d "/Applications/zoom.us.app" ]] || pkgutil --pkgs 2>/dev/null | grep -qi "zoom"
}

if [[ "$FORCE_REINSTALL" != "true" ]] && is_zoom_installed; then
  INSTALLED_VERSION=$(/usr/bin/defaults read /Applications/zoom.us.app/Contents/Info.plist CFBundleShortVersionString 2>/dev/null || echo "unknown")
  log "SKIP: Zoom already installed (version: ${INSTALLED_VERSION}). No action taken."
  exit 0
fi

TMP_DIR="$(mktemp -d)"
PKG_PATH="$TMP_DIR/Zoom.pkg"
trap 'rm -rf "$TMP_DIR" 2>/dev/null || true' EXIT

log "Downloading Zoom PKG..."
curl -fLsS --retry 3 --retry-delay 2 --connect-timeout 15 --max-time 900 \
  -o "$PKG_PATH" "$ZOOM_PKG_URL" \
  || fail "Download failed. Check ZOOM_PKG_URL."

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

log "Installing Zoom silently..."
/usr/sbin/installer -pkg "$PKG_PATH" -target / || fail "installer(8) failed."

if is_zoom_installed; then
  INSTALLED_VERSION=$(/usr/bin/defaults read /Applications/zoom.us.app/Contents/Info.plist CFBundleShortVersionString 2>/dev/null || echo "unknown")
  log "SUCCESS: Zoom installed (version: ${INSTALLED_VERSION})."
  exit 0
fi

fail "Zoom installation did not validate. Check ${LOG_FILE}."
