#!/bin/bash
set -euo pipefail
# Paloalto Globalprotect Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_PALOALTO_GLOBALPROTECT_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Paloalto Globalprotect..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Paloalto Globalprotect installed."
