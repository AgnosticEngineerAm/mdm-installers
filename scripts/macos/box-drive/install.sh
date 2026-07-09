#!/bin/bash
set -euo pipefail
# Box Drive Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_BOX_DRIVE_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Box Drive..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Box Drive installed."
