#!/bin/bash
set -euo pipefail
# CCleaner Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_CCLEANER_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing CCleaner..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: CCleaner installed."
