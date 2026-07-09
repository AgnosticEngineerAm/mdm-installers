#!/bin/bash
set -euo pipefail
# Sejda PDF Desktop Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_SEJDA_PDF_DESKTOP_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Sejda PDF Desktop..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Sejda PDF Desktop installed."
