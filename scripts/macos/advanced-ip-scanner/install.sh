#!/bin/bash
set -euo pipefail
# Advanced IP Scanner Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_ADVANCED_IP_SCANNER_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Advanced IP Scanner..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Advanced IP Scanner installed."
