#!/bin/bash
set -euo pipefail
# Foxit Reader Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_FOXIT_READER_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Foxit Reader..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Foxit Reader installed."
