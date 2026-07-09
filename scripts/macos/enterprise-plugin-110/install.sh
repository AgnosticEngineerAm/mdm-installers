#!/bin/bash
set -euo pipefail
# Enterprise Plugin 110 Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_ENTERPRISE_PLUGIN_110_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Enterprise Plugin 110..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Enterprise Plugin 110 installed."
