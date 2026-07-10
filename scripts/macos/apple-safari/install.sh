#!/bin/bash
set -euo pipefail
# Apple Safari Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_APPLE_SAFARI_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Apple Safari..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Apple Safari installed."
