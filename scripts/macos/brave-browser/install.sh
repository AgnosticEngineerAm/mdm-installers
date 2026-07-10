#!/bin/bash
set -euo pipefail
# Brave Browser Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_BRAVE_BROWSER_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Brave Browser..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Brave Browser installed."
