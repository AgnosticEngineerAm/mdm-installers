#!/bin/bash
set -euo pipefail
# Ekahau HeatMapper Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_EKAHAU_HEATMAPPER_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Ekahau HeatMapper..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Ekahau HeatMapper installed."
