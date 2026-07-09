#!/bin/bash
set -euo pipefail
# 3ds Max Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_3DS_MAX_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing 3ds Max..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: 3ds Max installed."
