#!/bin/bash
set -euo pipefail
# DaVinci Resolve Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_DAVINCI_RESOLVE_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing DaVinci Resolve..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: DaVinci Resolve installed."
