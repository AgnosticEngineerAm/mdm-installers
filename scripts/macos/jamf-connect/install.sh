#!/bin/bash
set -euo pipefail
# Jamf Connect Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_JAMF_CONNECT_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Jamf Connect..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Jamf Connect installed."
