#!/bin/bash
set -euo pipefail
# FL Studio Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_FL_STUDIO_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing FL Studio..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: FL Studio installed."
