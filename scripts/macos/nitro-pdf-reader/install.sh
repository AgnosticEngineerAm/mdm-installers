#!/bin/bash
set -euo pipefail
# Nitro PDF Reader Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_NITRO_PDF_READER_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Nitro PDF Reader..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Nitro PDF Reader installed."
