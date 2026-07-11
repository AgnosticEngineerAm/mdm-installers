#!/bin/bash
set -euo pipefail
# Dropbox macOS install (MDM Script)

DMG_URL="PASTE_YOUR_DROPBOX_DMG_URL_HERE"
EXPECTED_SHA256=""
LOG_FILE="/var/log/mdm-dropbox-install.log"

umask 077
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

if [[ -f "$(dirname "$0")/../_lib/common.sh" ]]; then source "$(dirname "$0")/../_lib/common.sh"; else log() { echo "$*"; }; fail() { echo "ERROR: $*"; exit 1; }; fi
[[ "$(id -u)" -eq 0 ]] || fail "Must run as root."

log "Starting Dropbox install."
TMP_DIR="$(mktemp -d)"
DMG_PATH="$TMP_DIR/dropbox.dmg"
MOUNT_POINT="$TMP_DIR/mount"
trap 'hdiutil detach "$MOUNT_POINT" -quiet 2>/dev/null || true; rm -rf "$TMP_DIR" 2>/dev/null || true' EXIT

curl -fLsS -o "$DMG_PATH" "$DMG_URL" || fail "Download failed."
mkdir -p "$MOUNT_POINT"
hdiutil attach "$DMG_PATH" -nobrowse -quiet -mountpoint "$MOUNT_POINT" || fail "Failed to mount DMG."
APP_PATH=$(find "$MOUNT_POINT" -maxdepth 2 -name "*.app" -type d | head -1)
[[ -n "$APP_PATH" ]] || fail "App not found in DMG."
cp -R "$APP_PATH" /Applications/ || fail "Copy failed."
log "SUCCESS: Dropbox installed."
