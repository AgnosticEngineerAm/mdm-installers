#!/bin/bash
set -euo pipefail
# OneNote Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_ONENOTE_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing OneNote..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: OneNote installed."
