#!/bin/bash
set -euo pipefail
# GPU-Z Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_GPU_Z_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing GPU-Z..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: GPU-Z installed."
