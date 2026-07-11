#!/bin/bash
set -euo pipefail
# Box Drive macOS install (MDM Script)

PKG_URL="PASTE_YOUR_BOX_DRIVE_PKG_URL_HERE"
EXPECTED_SHA256=""
LOG_FILE="/var/log/mdm-box-drive-install.log"

umask 077
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

if [[ -f "$(dirname "$0")/../_lib/common.sh" ]]; then source "$(dirname "$0")/../_lib/common.sh"; else log() { echo "$*"; }; fail() { echo "ERROR: $*"; exit 1; }; fi
[[ "$(id -u)" -eq 0 ]] || fail "Must run as root."

log "Starting Box Drive install."
TMP_DIR="$(mktemp -d)"
PKG_PATH="$TMP_DIR/box-drive.pkg"
trap 'rm -rf "$TMP_DIR" 2>/dev/null || true' EXIT

curl -fLsS -o "$PKG_PATH" "$PKG_URL" || fail "Download failed."
/usr/sbin/installer -pkg "$PKG_PATH" -target / || fail "installer failed."
log "SUCCESS: Box Drive installed."
