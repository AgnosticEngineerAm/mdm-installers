#!/bin/bash
set -euo pipefail
# Compliance Scanner 90 Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_COMPLIANCE_SCANNER_90_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Compliance Scanner 90..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Compliance Scanner 90 installed."
