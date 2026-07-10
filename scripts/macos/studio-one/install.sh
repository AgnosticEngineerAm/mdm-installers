#!/bin/bash
set -euo pipefail
# Studio One Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_STUDIO_ONE_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Studio One..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Studio One installed."
