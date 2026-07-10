#!/bin/bash
set -euo pipefail
# Sumatra PDF Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_SUMATRA_PDF_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Sumatra PDF..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Sumatra PDF installed."
