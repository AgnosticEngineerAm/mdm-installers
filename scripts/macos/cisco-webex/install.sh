#!/bin/bash
set -euo pipefail
# Cisco Webex Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_CISCO_WEBEX_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Cisco Webex..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Cisco Webex installed."
