#!/bin/bash
set -euo pipefail
# Lastpass Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_LASTPASS_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Lastpass..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Lastpass installed."
