#!/bin/bash
set -euo pipefail
# Azure Data Studio Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_AZURE_DATA_STUDIO_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Azure Data Studio..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Azure Data Studio installed."
