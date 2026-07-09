#!/bin/bash
set -euo pipefail
# Cloudflare Warp Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_CLOUDFLARE_WARP_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Cloudflare Warp..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Cloudflare Warp installed."
