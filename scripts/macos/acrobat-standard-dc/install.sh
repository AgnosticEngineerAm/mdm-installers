#!/bin/bash
set -euo pipefail
# Acrobat Standard DC Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_ACROBAT_STANDARD_DC_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Acrobat Standard DC..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Acrobat Standard DC installed."
