#!/bin/bash
set -euo pipefail
# Process Hacker Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_PROCESS_HACKER_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Process Hacker..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Process Hacker installed."
