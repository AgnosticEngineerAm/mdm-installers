#!/bin/bash
set -euo pipefail
# Pro Tools Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_PRO_TOOLS_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Pro Tools..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Pro Tools installed."
