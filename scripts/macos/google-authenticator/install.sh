#!/bin/bash
set -euo pipefail
# Google Authenticator Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_GOOGLE_AUTHENTICATOR_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Google Authenticator..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Google Authenticator installed."
