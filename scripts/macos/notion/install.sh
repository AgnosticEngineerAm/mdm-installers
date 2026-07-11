#!/bin/bash
set -euo pipefail

###############################################################################
# Notion macOS install (MDM Script)
# Version: 1.0
###############################################################################

### ====== CONFIG ==============================================================
# Universal DMG URL
NOTION_DMG_URL="https://desktop-release.notion-static.com/Notion.dmg"
EXPECTED_SHA256=""
FORCE_REINSTALL="false"
LOG_FILE="/var/log/mdm-notion-install.log"
### ===========================================================================

umask 077
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

if [[ -f "$(dirname "$0")/../_lib/common.sh" ]]; then
  source "$(dirname "$0")/../_lib/common.sh"
else
  log()  { echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] [Notion] $*"; }
  fail() { log "ERROR: $*"; exit 1; }
  warn() { log "WARNING: $*"; }
fi

[[ "$(id -u)" -eq 0 ]] || fail "Must run as root/admin."

log "Starting Notion install."

is_notion_installed() {
  [[ -d "/Applications/Notion.app" ]]
}

if [[ "$FORCE_REINSTALL" != "true" ]] && is_notion_installed; then
  log "SKIP: Notion already installed. No action taken."
  exit 0
fi

TMP_DIR="$(mktemp -d)"
DMG_PATH="$TMP_DIR/Notion.dmg"
MOUNT_POINT="$TMP_DIR/notion_mount"
trap 'hdiutil detach "$MOUNT_POINT" -quiet 2>/dev/null || true; rm -rf "$TMP_DIR" 2>/dev/null || true' EXIT

log "Downloading Notion DMG..."
curl -fLsS --retry 3 --retry-delay 2 --connect-timeout 15 --max-time 900 \
  -L -o "$DMG_PATH" "$NOTION_DMG_URL" \
  || fail "Download failed."

if ! file "$DMG_PATH" | grep -qi "Apple disk image"; then
  fail "Downloaded file is not a valid .dmg."
fi

if [[ -n "$EXPECTED_SHA256" ]]; then
  ACTUAL="$(shasum -a 256 "$DMG_PATH" | awk '{print $1}')"
  [[ "$ACTUAL" == "$EXPECTED_SHA256" ]] || fail "SHA256 mismatch."
fi

log "Mounting Notion DMG..."
mkdir -p "$MOUNT_POINT"
hdiutil attach "$DMG_PATH" -nobrowse -quiet -mountpoint "$MOUNT_POINT" \
  || fail "Failed to mount DMG."

NOTION_APP="$(find "$MOUNT_POINT" -maxdepth 2 -name "Notion.app" -type d | head -1)"
[[ -n "$NOTION_APP" ]] || fail "Notion.app not found in mounted DMG."

log "Copying Notion.app to /Applications/..."
cp -R "$NOTION_APP" /Applications/ || fail "Failed to copy Notion.app."
chown -R root:wheel "/Applications/Notion.app"

hdiutil detach "$MOUNT_POINT" -quiet 2>/dev/null || true

if is_notion_installed; then
  log "SUCCESS: Notion installed."
  exit 0
fi

fail "Notion installation did not validate."
