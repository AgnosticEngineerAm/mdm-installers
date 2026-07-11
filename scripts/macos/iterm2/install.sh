#!/bin/bash
set -euo pipefail

###############################################################################
# iTerm2 macOS install (MDM Script)
# Version: 1.0
###############################################################################

### ====== CONFIG ==============================================================
ITERM2_ZIP_URL="https://iterm2.com/downloads/stable/latest"
EXPECTED_SHA256=""
FORCE_REINSTALL="false"
LOG_FILE="/var/log/mdm-iterm2-install.log"
### ===========================================================================

umask 077
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

if [[ -f "$(dirname "$0")/../_lib/common.sh" ]]; then
  source "$(dirname "$0")/../_lib/common.sh"
else
  log()  { echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] [iTerm2] $*"; }
  fail() { log "ERROR: $*"; exit 1; }
  warn() { log "WARNING: $*"; }
fi

[[ "$(id -u)" -eq 0 ]] || fail "Must run as root/admin."

log "Starting iTerm2 install."

is_iterm2_installed() {
  [[ -d "/Applications/iTerm.app" ]]
}

if [[ "$FORCE_REINSTALL" != "true" ]] && is_iterm2_installed; then
  log "SKIP: iTerm2 already installed. No action taken."
  exit 0
fi

TMP_DIR="$(mktemp -d)"
ZIP_PATH="$TMP_DIR/iTerm2.zip"
trap 'rm -rf "$TMP_DIR" 2>/dev/null || true' EXIT

log "Downloading iTerm2 ZIP..."
curl -fLsS --retry 3 --retry-delay 2 --connect-timeout 15 --max-time 900 \
  -L -o "$ZIP_PATH" "$ITERM2_ZIP_URL" \
  || fail "Download failed."

if [[ -n "$EXPECTED_SHA256" ]]; then
  ACTUAL="$(shasum -a 256 "$ZIP_PATH" | awk '{print $1}')"
  [[ "$ACTUAL" == "$EXPECTED_SHA256" ]] || fail "SHA256 mismatch."
fi

log "Unzipping iTerm2..."
unzip -q "$ZIP_PATH" -d "$TMP_DIR" || fail "Unzip failed."

APP_PATH="$(find "$TMP_DIR" -name "iTerm.app" -type d -maxdepth 1)"
if [[ -z "$APP_PATH" ]]; then
  fail "Could not find iTerm.app in extracted zip."
fi

log "Moving to /Applications..."
rm -rf "/Applications/iTerm.app"
mv "$APP_PATH" "/Applications/" || fail "Failed to move app to /Applications."
chown -R root:wheel "/Applications/iTerm.app"

if is_iterm2_installed; then
  log "SUCCESS: iTerm2 installed."
  exit 0
fi

fail "iTerm2 installation did not validate."
