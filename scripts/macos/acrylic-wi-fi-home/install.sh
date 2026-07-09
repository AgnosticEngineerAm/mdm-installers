#!/bin/bash
set -euo pipefail
# Acrylic Wi-Fi Home Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_ACRYLIC_WI_FI_HOME_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Acrylic Wi-Fi Home..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Acrylic Wi-Fi Home installed."
