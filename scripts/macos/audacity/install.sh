#!/bin/bash
set -euo pipefail
# Audacity Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_AUDACITY_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Audacity..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Audacity installed."
