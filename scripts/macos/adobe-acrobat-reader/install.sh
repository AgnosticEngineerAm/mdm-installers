#!/bin/bash
set -euo pipefail

###############################################################################
# Adobe Acrobat Reader macOS install (MDM Script)
# Version: 1.0
###############################################################################

### ====== CONFIG ==============================================================
# Use your internal CDN URL or Adobe's enterprise download link
ACROBAT_PKG_URL="PASTE_YOUR_ACROBAT_READER_PKG_URL_HERE"

EXPECTED_SHA256=""
EXPECTED_TEAM_ID="JQ525L2MZD"  # Adobe Systems, Inc.

FORCE_REINSTALL="false"
LOG_FILE="/var/log/mdm-acrobat-reader-install.log"
### ===========================================================================

umask 077
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

if [[ -f "$(dirname "$0")/../_lib/common.sh" ]]; then
  source "$(dirname "$0")/../_lib/common.sh"
else
  log()  { echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] [AcrobatReader] $*"; }
  fail() { log "ERROR: $*"; exit 1; }
  warn() { log "WARNING: $*"; }
fi

[[ "$(id -u)" -eq 0 ]] || fail "Must run as root/admin."

log "Starting Adobe Acrobat Reader install."
log "macOS $(sw_vers -productVersion) | $(uname -m)"

is_acrobat_installed() {
  [[ -d "/Applications/Adobe Acrobat Reader.app" ]] || pkgutil --pkgs 2>/dev/null | grep -qi "com.adobe.acrobat.reader"
}

if [[ "$FORCE_REINSTALL" != "true" ]] && is_acrobat_installed; then
  INSTALLED_VERSION=$(/usr/bin/defaults read "/Applications/Adobe Acrobat Reader.app/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null || echo "unknown")
  log "SKIP: Adobe Acrobat Reader already installed (version: ${INSTALLED_VERSION}). No action taken."
  exit 0
fi

if [[ "$ACROBAT_PKG_URL" == "PASTE_YOUR_ACROBAT_READER_PKG_URL_HERE" ]]; then
  fail "ACROBAT_PKG_URL has not been set. Edit the CONFIG block before deploying."
fi

TMP_DIR="$(mktemp -d)"
PKG_PATH="$TMP_DIR/AcrobatReader.pkg"
trap 'rm -rf "$TMP_DIR" 2>/dev/null || true' EXIT

log "Downloading Adobe Acrobat Reader PKG..."
curl -fLsS --retry 3 --retry-delay 2 --connect-timeout 15 --max-time 900 \
  -L -o "$PKG_PATH" "$ACROBAT_PKG_URL" \
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

log "Installing Adobe Acrobat Reader silently..."
/usr/sbin/installer -pkg "$PKG_PATH" -target / || fail "installer(8) failed."

if is_acrobat_installed; then
  log "SUCCESS: Adobe Acrobat Reader installed."
  exit 0
fi

fail "Adobe Acrobat Reader installation did not validate."
