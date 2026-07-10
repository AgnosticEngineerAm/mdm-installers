#!/bin/bash
set -euo pipefail
# Adobe Premiere Rush Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_ADOBE_PREMIERE_RUSH_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Adobe Premiere Rush..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Adobe Premiere Rush installed."
