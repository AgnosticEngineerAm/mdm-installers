#!/bin/bash
set -euo pipefail
# Identity Provider 232 Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_IDENTITY_PROVIDER_232_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Identity Provider 232..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Identity Provider 232 installed."
