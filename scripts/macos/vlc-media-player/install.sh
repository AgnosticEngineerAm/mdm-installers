#!/bin/bash
set -euo pipefail

###############################################################################
# VLC Media Player macOS install (MDM Script)
# Version: 1.0
###############################################################################

### ====== CONFIG ==============================================================
VLC_DMG_URL="https://get.videolan.org/vlc/3.0.21/macosx/vlc-3.0.21-universal.dmg"
EXPECTED_SHA256=""
FORCE_REINSTALL="false"
LOG_FILE="/var/log/mdm-vlc-install.log"
### ===========================================================================

umask 077
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

if [[ -f "$(dirname "$0")/../_lib/common.sh" ]]; then
  source "$(dirname "$0")/../_lib/common.sh"
else
  log()  { echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] [VLC] $*"; }
  fail() { log "ERROR: $*"; exit 1; }
  warn() { log "WARNING: $*"; }
fi

[[ "$(id -u)" -eq 0 ]] || fail "Must run as root/admin."

log "Starting VLC Media Player install."

is_vlc_installed() {
  [[ -d "/Applications/VLC.app" ]]
}

if [[ "$FORCE_REINSTALL" != "true" ]] && is_vlc_installed; then
  log "SKIP: VLC already installed. No action taken."
  exit 0
fi

TMP_DIR="$(mktemp -d)"
DMG_PATH="$TMP_DIR/VLC.dmg"
MOUNT_POINT="$TMP_DIR/vlc_mount"
trap 'hdiutil detach "$MOUNT_POINT" -quiet 2>/dev/null || true; rm -rf "$TMP_DIR" 2>/dev/null || true' EXIT

log "Downloading VLC DMG..."
curl -fLsS --retry 3 --retry-delay 2 --connect-timeout 15 --max-time 900 \
  -L -o "$DMG_PATH" "$VLC_DMG_URL" \
  || fail "Download failed."

if ! file "$DMG_PATH" | grep -qi "Apple disk image"; then
  fail "Downloaded file is not a valid .dmg."
fi

if [[ -n "$EXPECTED_SHA256" ]]; then
  ACTUAL="$(shasum -a 256 "$DMG_PATH" | awk '{print $1}')"
  [[ "$ACTUAL" == "$EXPECTED_SHA256" ]] || fail "SHA256 mismatch."
fi

log "Mounting VLC DMG..."
mkdir -p "$MOUNT_POINT"
hdiutil attach "$DMG_PATH" -nobrowse -quiet -mountpoint "$MOUNT_POINT" \
  || fail "Failed to mount DMG."

VLC_APP="$(find "$MOUNT_POINT" -maxdepth 2 -name "VLC.app" -type d | head -1)"
[[ -n "$VLC_APP" ]] || fail "VLC.app not found in mounted DMG."

log "Copying VLC.app to /Applications/..."
cp -R "$VLC_APP" /Applications/ || fail "Failed to copy VLC.app."
chown -R root:wheel "/Applications/VLC.app"

hdiutil detach "$MOUNT_POINT" -quiet 2>/dev/null || true

if is_vlc_installed; then
  log "SUCCESS: VLC installed."
  exit 0
fi

fail "VLC installation did not validate."
