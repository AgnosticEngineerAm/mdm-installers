#!/bin/bash
set -euo pipefail
# CPU-Z Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_CPU_Z_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing CPU-Z..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: CPU-Z installed."
