#!/bin/bash
set -euo pipefail
# Fraps Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_FRAPS_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Fraps..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Fraps installed."
