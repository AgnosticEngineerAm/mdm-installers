#!/bin/bash
set -euo pipefail
# iTerm2 Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_ITERM2_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing iTerm2..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: iTerm2 installed."
