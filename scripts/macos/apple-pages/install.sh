#!/bin/bash
set -euo pipefail
# Apple Pages Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_APPLE_PAGES_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Apple Pages..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Apple Pages installed."
