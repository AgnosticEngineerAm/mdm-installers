#!/bin/bash
set -euo pipefail
# Allway Sync Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_ALLWAY_SYNC_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Allway Sync..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Allway Sync installed."
