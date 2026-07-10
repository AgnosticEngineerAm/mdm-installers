#!/bin/bash
set -euo pipefail
# Postman Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_POSTMAN_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Postman..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Postman installed."
