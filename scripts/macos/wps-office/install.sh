#!/bin/bash
set -euo pipefail
# WPS Office Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_WPS_OFFICE_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing WPS Office..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: WPS Office installed."
