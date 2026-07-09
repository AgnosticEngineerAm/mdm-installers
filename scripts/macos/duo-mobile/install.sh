#!/bin/bash
set -euo pipefail
# Duo Mobile Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_DUO_MOBILE_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Duo Mobile..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Duo Mobile installed."
