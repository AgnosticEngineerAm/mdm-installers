#!/bin/bash
set -euo pipefail
# TeamViewer Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_TEAMVIEWER_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing TeamViewer..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: TeamViewer installed."
