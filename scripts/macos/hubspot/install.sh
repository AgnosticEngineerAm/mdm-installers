#!/bin/bash
set -euo pipefail
# HubSpot Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_HUBSPOT_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing HubSpot..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: HubSpot installed."
