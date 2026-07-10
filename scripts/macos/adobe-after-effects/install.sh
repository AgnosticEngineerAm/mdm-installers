#!/bin/bash
set -euo pipefail
# Adobe After Effects Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_ADOBE_AFTER_EFFECTS_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Adobe After Effects..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Adobe After Effects installed."
