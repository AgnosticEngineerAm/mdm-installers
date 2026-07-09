#!/bin/bash
set -euo pipefail
# Affinity Photo Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_AFFINITY_PHOTO_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Affinity Photo..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Affinity Photo installed."
