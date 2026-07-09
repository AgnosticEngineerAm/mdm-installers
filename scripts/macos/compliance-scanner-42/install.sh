#!/bin/bash
set -euo pipefail
# Compliance Scanner 42 Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_COMPLIANCE_SCANNER_42_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Compliance Scanner 42..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Compliance Scanner 42 installed."
