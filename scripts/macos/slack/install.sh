#!/bin/bash
set -euo pipefail

###############################################################################
# Slack macOS install (MDM Script)
# Version: 1.0
# Tested on: macOS 13 Ventura, 14 Sonoma, 15 Sequoia (Intel + Apple Silicon)
###############################################################################

### ====== CONFIG ==============================================================
# IT / enterprise DMG download — always fetches the latest version
# NOTE: Slack distributes as a .dmg for direct download.
# For MDM deployment, the recommended approach is:
#   1. Download the .dmg from https://slack.com/downloads/mac
#   2. Host it as a GitHub Release asset or on your internal CDN
#   3. Replace the URL below with your direct-download .dmg URL
SLACK_DMG_URL="PASTE_YOUR_SLACK_DMG_URL_HERE"

EXPECTED_SHA256=""
FORCE_REINSTALL="false"
LOG_FILE="/var/log/mdm-slack-install.log"
### ===========================================================================

umask 077
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

log()  { echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] [Slack] $*"; }
fail() { log "ERROR: $*"; exit 1; }
warn() { log "WARNING: $*"; }

[[ "$(id -u)" -eq 0 ]] || fail "Must run as root/admin."

log "Starting Slack install."
log "macOS $(sw_vers -productVersion) | $(uname -m)"

is_slack_installed() {
  [[ -d "/Applications/Slack.app" ]]
}

if [[ "$FORCE_REINSTALL" != "true" ]] && is_slack_installed; then
  INSTALLED_VERSION=$(/usr/bin/defaults read /Applications/Slack.app/Contents/Info.plist CFBundleShortVersionString 2>/dev/null || echo "unknown")
  log "SKIP: Slack already installed (version: ${INSTALLED_VERSION}). No action taken."
  exit 0
fi

TMP_DIR="$(mktemp -d)"
DMG_PATH="$TMP_DIR/Slack.dmg"
MOUNT_POINT="$TMP_DIR/slack_mount"
trap 'hdiutil detach "$MOUNT_POINT" 2>/dev/null || true; rm -rf "$TMP_DIR" 2>/dev/null || true' EXIT

log "Downloading Slack DMG..."
curl -fLsS --retry 3 --retry-delay 2 --connect-timeout 15 --max-time 900 \
  -o "$DMG_PATH" "$SLACK_DMG_URL" \
  || fail "Download failed. Check SLACK_DMG_URL."

if ! file "$DMG_PATH" | grep -qi "Apple disk image"; then
  log "File type: $(file "$DMG_PATH")"
  fail "Downloaded file is not a valid .dmg."
fi

if [[ -n "$EXPECTED_SHA256" ]]; then
  ACTUAL="$(shasum -a 256 "$DMG_PATH" | awk '{print $1}')"
  [[ "$ACTUAL" == "$EXPECTED_SHA256" ]] || fail "SHA256 mismatch. Got: ${ACTUAL}"
  log "SHA256 verified."
else
  warn "EXPECTED_SHA256 not set; skipping checksum verification."
fi

log "Mounting Slack DMG..."
mkdir -p "$MOUNT_POINT"
hdiutil attach "$DMG_PATH" -nobrowse -quiet -mountpoint "$MOUNT_POINT" \
  || fail "Failed to mount DMG."

# Find Slack.app inside the DMG
SLACK_APP="$(find "$MOUNT_POINT" -maxdepth 2 -name "Slack.app" -type d | head -1)"
[[ -n "$SLACK_APP" ]] || fail "Slack.app not found in mounted DMG."

log "Copying Slack.app to /Applications/..."
cp -R "$SLACK_APP" /Applications/ \
  || fail "Failed to copy Slack.app to /Applications/."

hdiutil detach "$MOUNT_POINT" -quiet 2>/dev/null || true

if is_slack_installed; then
  INSTALLED_VERSION=$(/usr/bin/defaults read /Applications/Slack.app/Contents/Info.plist CFBundleShortVersionString 2>/dev/null || echo "unknown")
  log "SUCCESS: Slack installed (version: ${INSTALLED_VERSION})."
  exit 0
fi

fail "Slack installation did not validate. Check ${LOG_FILE}."
