#!/bin/bash
set -euo pipefail
# Enterprise Plugin 74 Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_ENTERPRISE_PLUGIN_74_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Enterprise Plugin 74..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Enterprise Plugin 74 installed."
