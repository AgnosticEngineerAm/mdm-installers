#!/bin/bash
set -euo pipefail
# Hexnode MDM Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_HEXNODE_MDM_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Hexnode MDM..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Hexnode MDM installed."
