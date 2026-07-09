#!/bin/bash
set -euo pipefail
# L0phtCrack Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_L0PHTCRACK_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing L0phtCrack..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: L0phtCrack installed."
