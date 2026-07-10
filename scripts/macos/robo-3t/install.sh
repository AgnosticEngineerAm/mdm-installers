#!/bin/bash
set -euo pipefail
# Robo 3T Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_ROBO_3T_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Robo 3T..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Robo 3T installed."
