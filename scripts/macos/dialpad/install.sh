#!/bin/bash
set -euo pipefail
# Dialpad Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_DIALPAD_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Dialpad..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Dialpad installed."
