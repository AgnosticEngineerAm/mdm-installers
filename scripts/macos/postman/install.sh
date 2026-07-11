#!/bin/bash
set -euo pipefail

###############################################################################
# Postman macOS install (MDM Script)
# Version: 1.0
###############################################################################

### ====== CONFIG ==============================================================
POSTMAN_ZIP_URL="https://dl.pstmn.io/download/latest/osx_64"
EXPECTED_SHA256=""
FORCE_REINSTALL="false"
LOG_FILE="/var/log/mdm-postman-install.log"
### ===========================================================================

umask 077
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

if [[ -f "$(dirname "$0")/../_lib/common.sh" ]]; then
  source "$(dirname "$0")/../_lib/common.sh"
else
  log()  { echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] [Postman] $*"; }
  fail() { log "ERROR: $*"; exit 1; }
  warn() { log "WARNING: $*"; }
fi

[[ "$(id -u)" -eq 0 ]] || fail "Must run as root/admin."

log "Starting Postman install."

is_postman_installed() {
  [[ -d "/Applications/Postman.app" ]]
}

if [[ "$FORCE_REINSTALL" != "true" ]] && is_postman_installed; then
  log "SKIP: Postman already installed. No action taken."
  exit 0
fi

TMP_DIR="$(mktemp -d)"
ZIP_PATH="$TMP_DIR/Postman.zip"
trap 'rm -rf "$TMP_DIR" 2>/dev/null || true' EXIT

log "Downloading Postman ZIP..."
curl -fLsS --retry 3 --retry-delay 2 --connect-timeout 15 --max-time 900 \
  -L -o "$ZIP_PATH" "$POSTMAN_ZIP_URL" \
  || fail "Download failed."

if [[ -n "$EXPECTED_SHA256" ]]; then
  ACTUAL="$(shasum -a 256 "$ZIP_PATH" | awk '{print $1}')"
  [[ "$ACTUAL" == "$EXPECTED_SHA256" ]] || fail "SHA256 mismatch."
fi

log "Unzipping Postman..."
unzip -q "$ZIP_PATH" -d "$TMP_DIR" || fail "Unzip failed."

APP_PATH="$(find "$TMP_DIR" -name "Postman.app" -type d -maxdepth 1)"
if [[ -z "$APP_PATH" ]]; then
  fail "Could not find Postman.app in extracted zip."
fi

log "Moving to /Applications..."
rm -rf "/Applications/Postman.app"
mv "$APP_PATH" "/Applications/" || fail "Failed to move app to /Applications."
chown -R root:wheel "/Applications/Postman.app"

if is_postman_installed; then
  log "SUCCESS: Postman installed."
  exit 0
fi

fail "Postman installation did not validate."
