#!/bin/bash
set -euo pipefail
# Mosyle Business Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_MOSYLE_BUSINESS_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Mosyle Business..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Mosyle Business installed."
