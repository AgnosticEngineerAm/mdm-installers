#!/bin/bash
set -euo pipefail
# Gnumeric Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_GNUMERIC_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Gnumeric..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Gnumeric installed."
