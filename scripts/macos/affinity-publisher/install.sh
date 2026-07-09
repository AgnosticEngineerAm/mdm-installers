#!/bin/bash
set -euo pipefail
# Affinity Publisher Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_AFFINITY_PUBLISHER_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Affinity Publisher..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Affinity Publisher installed."
