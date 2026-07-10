#!/bin/bash
set -euo pipefail
# Medusa Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_MEDUSA_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Medusa..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Medusa installed."
