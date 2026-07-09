#!/bin/bash
set -euo pipefail
# Magix Vegas Pro Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_MAGIX_VEGAS_PRO_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Magix Vegas Pro..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Magix Vegas Pro installed."
