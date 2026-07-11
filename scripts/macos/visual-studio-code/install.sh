#!/bin/bash
set -euo pipefail

###############################################################################
# Visual Studio Code macOS install (MDM Script)
# Version: 1.0
# Tested on: macOS 13 Ventura, 14 Sonoma, 15 Sequoia (Intel + Apple Silicon)
#
# VS Code is distributed as a ZIP archive. This script downloads, unzips, and
# moves the app to /Applications.
###############################################################################

### ====== CONFIG ==============================================================
# Universal download link:
VSCODE_ZIP_URL="https://code.visualstudio.com/sha/download?build=stable&os=darwin-universal"

EXPECTED_SHA256=""

FORCE_REINSTALL="false"
LOG_FILE="/var/log/mdm-vscode-install.log"
### ===========================================================================

umask 077
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

if [[ -f "$(dirname "$0")/../_lib/common.sh" ]]; then
  source "$(dirname "$0")/../_lib/common.sh"
else
  log()  { echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] [VSCode] $*"; }
  fail() { log "ERROR: $*"; exit 1; }
  warn() { log "WARNING: $*"; }
fi

[[ "$(id -u)" -eq 0 ]] || fail "Must run as root/admin."

log "Starting Visual Studio Code install."
log "macOS $(sw_vers -productVersion) | $(uname -m)"

is_vscode_installed() {
  [[ -d "/Applications/Visual Studio Code.app" ]]
}

if [[ "$FORCE_REINSTALL" != "true" ]] && is_vscode_installed; then
  INSTALLED_VERSION=$(/usr/bin/defaults read "/Applications/Visual Studio Code.app/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null || echo "unknown")
  log "SKIP: VS Code already installed (version: ${INSTALLED_VERSION}). No action taken."
  exit 0
fi

TMP_DIR="$(mktemp -d)"
ZIP_PATH="$TMP_DIR/VSCode.zip"
trap 'rm -rf "$TMP_DIR" 2>/dev/null || true' EXIT

log "Downloading Visual Studio Code ZIP..."
curl -fLsS --retry 3 --retry-delay 2 --connect-timeout 15 --max-time 900 \
  -L -o "$ZIP_PATH" "$VSCODE_ZIP_URL" \
  || fail "Download failed."

if ! file "$ZIP_PATH" | grep -qi "Zip archive data"; then
  fail "Downloaded file is not a valid ZIP archive."
fi

if [[ -n "$EXPECTED_SHA256" ]]; then
  ACTUAL="$(shasum -a 256 "$ZIP_PATH" | awk '{print $1}')"
  [[ "$ACTUAL" == "$EXPECTED_SHA256" ]] || fail "SHA256 mismatch."
fi

log "Unzipping Visual Studio Code..."
unzip -q "$ZIP_PATH" -d "$TMP_DIR" || fail "Unzip failed."

APP_PATH="$(find "$TMP_DIR" -name "Visual Studio Code.app" -type d -maxdepth 1)"
if [[ -z "$APP_PATH" ]]; then
  fail "Could not find Visual Studio Code.app in extracted zip."
fi

log "Moving to /Applications..."
rm -rf "/Applications/Visual Studio Code.app"
mv "$APP_PATH" "/Applications/" || fail "Failed to move app to /Applications."
chown -R root:wheel "/Applications/Visual Studio Code.app"

if is_vscode_installed; then
  INSTALLED_VERSION=$(/usr/bin/defaults read "/Applications/Visual Studio Code.app/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null || echo "unknown")
  log "SUCCESS: VS Code installed (version: ${INSTALLED_VERSION})."
  exit 0
fi

fail "VS Code installation did not validate."
