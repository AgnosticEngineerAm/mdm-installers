#!/bin/bash
set -euo pipefail
# Ashampoo WinOptimizer Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_ASHAMPOO_WINOPTIMIZER_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Ashampoo WinOptimizer..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Ashampoo WinOptimizer installed."
