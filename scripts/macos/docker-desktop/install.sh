#!/bin/bash
set -euo pipefail

###############################################################################
# Docker Desktop macOS install (MDM Script)
# Version: 1.0
# Tested on: macOS 13 Ventura, 14 Sonoma, 15 Sequoia (Intel + Apple Silicon)
#
# Docker Desktop distributes as a .dmg. This script handles mount/copy/unmount.
# ARM (Apple Silicon) and Intel use different package URLs — set the appropriate
# one below or detect architecture automatically.
###############################################################################

### ====== CONFIG ==============================================================
# Auto-detect architecture and set the URL accordingly
ARCH="$(uname -m)"
if [[ "$ARCH" == "arm64" ]]; then
  DOCKER_DMG_URL="https://desktop.docker.com/mac/main/arm64/Docker.dmg"
else
  DOCKER_DMG_URL="https://desktop.docker.com/mac/main/amd64/Docker.dmg"
fi

EXPECTED_SHA256=""

FORCE_REINSTALL="false"
LOG_FILE="/var/log/mdm-docker-install.log"
### ===========================================================================

umask 077
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

log()  { echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] [DockerDesktop] $*"; }
fail() { log "ERROR: $*"; exit 1; }
warn() { log "WARNING: $*"; }

[[ "$(id -u)" -eq 0 ]] || fail "Must run as root/admin."

log "Starting Docker Desktop install."
log "macOS $(sw_vers -productVersion) | ${ARCH}"

is_docker_installed() {
  [[ -d "/Applications/Docker.app" ]]
}

if [[ "$FORCE_REINSTALL" != "true" ]] && is_docker_installed; then
  INSTALLED_VERSION=$(/usr/bin/defaults read "/Applications/Docker.app/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null || echo "unknown")
  log "SKIP: Docker Desktop already installed (version: ${INSTALLED_VERSION}). No action taken."
  exit 0
fi

TMP_DIR="$(mktemp -d)"
DMG_PATH="$TMP_DIR/Docker.dmg"
MOUNT_POINT="$TMP_DIR/docker_mount"
trap 'hdiutil detach "$MOUNT_POINT" -quiet 2>/dev/null || true; rm -rf "$TMP_DIR" 2>/dev/null || true' EXIT

log "Downloading Docker Desktop DMG (${ARCH})..."
curl -fLsS --retry 3 --retry-delay 2 --connect-timeout 30 --max-time 1800 \
  -o "$DMG_PATH" "$DOCKER_DMG_URL" \
  || fail "Download failed. Check DOCKER_DMG_URL."

if ! file "$DMG_PATH" | grep -qi "Apple disk image"; then
  fail "Downloaded file is not a valid .dmg."
fi

if [[ -n "$EXPECTED_SHA256" ]]; then
  ACTUAL="$(shasum -a 256 "$DMG_PATH" | awk '{print $1}')"
  [[ "$ACTUAL" == "$EXPECTED_SHA256" ]] || fail "SHA256 mismatch. Got: ${ACTUAL}"
  log "SHA256 verified."
else
  warn "EXPECTED_SHA256 not set; skipping checksum verification."
fi

log "Mounting Docker DMG..."
mkdir -p "$MOUNT_POINT"
hdiutil attach "$DMG_PATH" -nobrowse -quiet -mountpoint "$MOUNT_POINT" \
  || fail "Failed to mount DMG."

DOCKER_APP="$(find "$MOUNT_POINT" -maxdepth 2 -name "Docker.app" -type d | head -1)"
[[ -n "$DOCKER_APP" ]] || fail "Docker.app not found in mounted DMG."

log "Copying Docker.app to /Applications/..."
cp -R "$DOCKER_APP" /Applications/ || fail "Failed to copy Docker.app."

hdiutil detach "$MOUNT_POINT" -quiet 2>/dev/null || true

if is_docker_installed; then
  INSTALLED_VERSION=$(/usr/bin/defaults read "/Applications/Docker.app/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null || echo "unknown")
  log "SUCCESS: Docker Desktop installed (version: ${INSTALLED_VERSION})."
  log "NOTE: Docker Desktop requires the user to launch it once to complete setup and accept the license."
  exit 0
fi

fail "Docker Desktop installation did not validate. Check ${LOG_FILE}."
