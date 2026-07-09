#!/bin/bash
set -euo pipefail
# Integration Hub 226 Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_INTEGRATION_HUB_226_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Integration Hub 226..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Integration Hub 226 installed."
