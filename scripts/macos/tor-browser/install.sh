#!/bin/bash
set -euo pipefail
# Tor Browser Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_TOR_BROWSER_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Tor Browser..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Tor Browser installed."
