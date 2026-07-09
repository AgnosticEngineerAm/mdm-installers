#!/bin/bash
set -euo pipefail
# Sequel Pro Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_SEQUEL_PRO_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Sequel Pro..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Sequel Pro installed."
