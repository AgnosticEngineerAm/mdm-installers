#!/bin/bash
set -euo pipefail
# VLC Media Player Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_VLC_MEDIA_PLAYER_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing VLC Media Player..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: VLC Media Player installed."
