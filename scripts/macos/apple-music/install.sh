#!/bin/bash
set -euo pipefail
# Apple Music Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_APPLE_MUSIC_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Apple Music..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Apple Music installed."
