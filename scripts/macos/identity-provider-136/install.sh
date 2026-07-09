#!/bin/bash
set -euo pipefail
# Identity Provider 136 Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_IDENTITY_PROVIDER_136_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Identity Provider 136..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Identity Provider 136 installed."
