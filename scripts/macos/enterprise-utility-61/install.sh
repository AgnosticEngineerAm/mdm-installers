#!/bin/bash
set -euo pipefail
# Enterprise Utility 61 Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_ENTERPRISE_UTILITY_61_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Enterprise Utility 61..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Enterprise Utility 61 installed."
