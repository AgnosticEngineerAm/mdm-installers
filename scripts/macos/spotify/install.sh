#!/bin/bash
set -euo pipefail
# Spotify Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_SPOTIFY_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Spotify..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Spotify installed."
