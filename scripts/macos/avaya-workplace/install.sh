#!/bin/bash
set -euo pipefail
# Avaya Workplace Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_AVAYA_WORKPLACE_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Avaya Workplace..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Avaya Workplace installed."
