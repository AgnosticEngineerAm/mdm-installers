#!/bin/bash
set -euo pipefail
# Enterprise Plugin 218 Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_ENTERPRISE_PLUGIN_218_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Enterprise Plugin 218..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Enterprise Plugin 218 installed."
