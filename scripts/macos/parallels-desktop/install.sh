#!/bin/bash
set -euo pipefail
# Parallels Desktop Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_PARALLELS_DESKTOP_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Parallels Desktop..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Parallels Desktop installed."
