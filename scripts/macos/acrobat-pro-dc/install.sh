#!/bin/bash
set -euo pipefail
# Acrobat Pro DC Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_ACROBAT_PRO_DC_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Acrobat Pro DC..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Acrobat Pro DC installed."
