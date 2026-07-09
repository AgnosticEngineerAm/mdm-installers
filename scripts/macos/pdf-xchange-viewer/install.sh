#!/bin/bash
set -euo pipefail
# PDF-XChange Viewer Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_PDF_XCHANGE_VIEWER_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing PDF-XChange Viewer..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: PDF-XChange Viewer installed."
