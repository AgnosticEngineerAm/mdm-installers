#!/bin/bash
set -euo pipefail
# Egnyte Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_EGNYTE_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Egnyte..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Egnyte installed."
