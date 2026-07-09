#!/bin/bash
set -euo pipefail
# Studio 3T Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_STUDIO_3T_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Studio 3T..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Studio 3T installed."
