#!/bin/bash
set -euo pipefail
# PCMark Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_PCMARK_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing PCMark..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: PCMark installed."
