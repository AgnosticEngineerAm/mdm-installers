#!/bin/bash
set -euo pipefail
# Hashcat Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_HASHCAT_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Hashcat..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Hashcat installed."
