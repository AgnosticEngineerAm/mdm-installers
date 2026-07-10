#!/bin/bash
set -euo pipefail
# IObit Uninstaller Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_IOBIT_UNINSTALLER_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing IObit Uninstaller..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: IObit Uninstaller installed."
