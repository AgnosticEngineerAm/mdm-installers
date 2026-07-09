#!/bin/bash
set -euo pipefail
# John the Ripper Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_JOHN_THE_RIPPER_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing John the Ripper..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: John the Ripper installed."
