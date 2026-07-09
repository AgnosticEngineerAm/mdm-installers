#!/bin/bash
set -euo pipefail
# The Unarchiver Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_THE_UNARCHIVER_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing The Unarchiver..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: The Unarchiver installed."
