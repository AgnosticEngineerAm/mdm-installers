#!/bin/bash
set -euo pipefail
# Data Sync 221 Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_DATA_SYNC_221_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Data Sync 221..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Data Sync 221 installed."
