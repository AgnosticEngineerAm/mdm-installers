#!/bin/bash
set -euo pipefail
# Data Sync 209 Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_DATA_SYNC_209_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Data Sync 209..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Data Sync 209 installed."
