#!/bin/bash
set -euo pipefail
# Anaconda Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_ANACONDA_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Anaconda..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Anaconda installed."
