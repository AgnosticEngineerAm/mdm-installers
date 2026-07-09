#!/bin/bash
set -euo pipefail
# 8x8 Work Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_8X8_WORK_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing 8x8 Work..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: 8x8 Work installed."
