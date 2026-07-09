#!/bin/bash
set -euo pipefail
# Fusion360 Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_FUSION360_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Fusion360..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Fusion360 installed."
