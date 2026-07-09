#!/bin/bash
set -euo pipefail
# Prime95 Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_PRIME95_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Prime95..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Prime95 installed."
