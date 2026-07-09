#!/bin/bash
set -euo pipefail
# Ableton Live Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_ABLETON_LIVE_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Ableton Live..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Ableton Live installed."
