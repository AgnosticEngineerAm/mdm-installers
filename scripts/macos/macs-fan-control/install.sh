#!/bin/bash
set -euo pipefail
# Macs Fan Control Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_MACS_FAN_CONTROL_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Macs Fan Control..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Macs Fan Control installed."
