#!/bin/bash
set -euo pipefail
# Clip Studio Paint Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_CLIP_STUDIO_PAINT_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Clip Studio Paint..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Clip Studio Paint installed."
