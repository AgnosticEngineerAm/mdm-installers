#!/bin/bash
set -euo pipefail
# AIDA64 Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_AIDA64_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing AIDA64..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: AIDA64 installed."
