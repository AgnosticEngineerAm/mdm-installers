#!/bin/bash
set -euo pipefail
# Adobe Illustrator Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_ADOBE_ILLUSTRATOR_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Adobe Illustrator..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Adobe Illustrator installed."
