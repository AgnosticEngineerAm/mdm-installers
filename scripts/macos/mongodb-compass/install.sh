#!/bin/bash
set -euo pipefail
# MongoDB Compass Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_MONGODB_COMPASS_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing MongoDB Compass..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: MongoDB Compass installed."
