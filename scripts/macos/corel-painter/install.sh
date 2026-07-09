#!/bin/bash
set -euo pipefail
# Corel Painter Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_COREL_PAINTER_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Corel Painter..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Corel Painter installed."
