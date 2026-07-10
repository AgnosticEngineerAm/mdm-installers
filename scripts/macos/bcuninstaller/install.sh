#!/bin/bash
set -euo pipefail
# BCUninstaller Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_BCUNINSTALLER_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing BCUninstaller..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: BCUninstaller installed."
