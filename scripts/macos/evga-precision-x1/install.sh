#!/bin/bash
set -euo pipefail
# EVGA Precision X1 Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_EVGA_PRECISION_X1_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing EVGA Precision X1..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: EVGA Precision X1 installed."
