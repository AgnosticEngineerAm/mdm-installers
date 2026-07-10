#!/bin/bash
set -euo pipefail
# LastPass Extension Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_LASTPASS_EXTENSION_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing LastPass Extension..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: LastPass Extension installed."
