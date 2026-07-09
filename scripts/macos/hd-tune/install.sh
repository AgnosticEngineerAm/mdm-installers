#!/bin/bash
set -euo pipefail
# HD Tune Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_HD_TUNE_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing HD Tune..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: HD Tune installed."
