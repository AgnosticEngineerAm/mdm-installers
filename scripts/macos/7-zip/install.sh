#!/bin/bash
set -euo pipefail
# 7 Zip Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_7_ZIP_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing 7 Zip..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: 7 Zip installed."
