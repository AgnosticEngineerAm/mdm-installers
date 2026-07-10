#!/bin/bash
set -euo pipefail
# Cinema 4D Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_CINEMA_4D_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Cinema 4D..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Cinema 4D installed."
