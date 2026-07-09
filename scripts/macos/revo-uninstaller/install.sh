#!/bin/bash
set -euo pipefail
# Revo Uninstaller Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_REVO_UNINSTALLER_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Revo Uninstaller..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Revo Uninstaller installed."
