#!/bin/bash
set -euo pipefail
# FastStone Image Viewer Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_FASTSTONE_IMAGE_VIEWER_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing FastStone Image Viewer..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: FastStone Image Viewer installed."
