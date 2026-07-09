#!/bin/bash
set -euo pipefail
# Cisco Anyconnect Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_CISCO_ANYCONNECT_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Cisco Anyconnect..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Cisco Anyconnect installed."
