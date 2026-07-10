#!/bin/bash
set -euo pipefail
# Rollbar Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_ROLLBAR_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Rollbar..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Rollbar installed."
