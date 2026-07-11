#!/bin/bash
set -euo pipefail
# Docker Compose macOS install (MDM Script)

ZIP_URL="PASTE_YOUR_DOCKER_COMPOSE_ZIP_URL_HERE"
EXPECTED_SHA256=""
LOG_FILE="/var/log/mdm-docker-compose-install.log"

umask 077
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

if [[ -f "$(dirname "$0")/../_lib/common.sh" ]]; then source "$(dirname "$0")/../_lib/common.sh"; else log() { echo "$*"; }; fail() { echo "ERROR: $*"; exit 1; }; fi
[[ "$(id -u)" -eq 0 ]] || fail "Must run as root."

log "Starting Docker Compose install."
TMP_DIR="$(mktemp -d)"
ZIP_PATH="$TMP_DIR/docker-compose.zip"
trap 'rm -rf "$TMP_DIR" 2>/dev/null || true' EXIT

curl -fLsS -o "$ZIP_PATH" "$ZIP_URL" || fail "Download failed."
unzip -q "$ZIP_PATH" -d "$TMP_DIR" || fail "Unzip failed."
APP_PATH=$(find "$TMP_DIR" -name "*.app" -type d -maxdepth 1 | head -1)
[[ -n "$APP_PATH" ]] || fail "App not found in ZIP."
rm -rf "/Applications/$(basename "$APP_PATH")"
mv "$APP_PATH" "/Applications/" || fail "Move failed."
log "SUCCESS: Docker Compose installed."
