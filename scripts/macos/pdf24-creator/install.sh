#!/bin/bash
set -euo pipefail
# PDF24 Creator Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_PDF24_CREATOR_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing PDF24 Creator..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: PDF24 Creator installed."
