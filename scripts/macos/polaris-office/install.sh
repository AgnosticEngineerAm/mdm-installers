#!/bin/bash
set -euo pipefail
# Polaris Office Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_POLARIS_OFFICE_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Polaris Office..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Polaris Office installed."
