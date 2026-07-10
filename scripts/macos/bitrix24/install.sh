#!/bin/bash
set -euo pipefail
# Bitrix24 Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_BITRIX24_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Bitrix24..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Bitrix24 installed."
