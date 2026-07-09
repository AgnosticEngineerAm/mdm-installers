#!/bin/bash
set -euo pipefail
# Compliance Scanner 186 Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_COMPLIANCE_SCANNER_186_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Compliance Scanner 186..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Compliance Scanner 186 installed."
