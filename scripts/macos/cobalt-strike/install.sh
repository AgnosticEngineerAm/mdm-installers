#!/bin/bash
set -euo pipefail
# Cobalt Strike Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_COBALT_STRIKE_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Cobalt Strike..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Cobalt Strike installed."
