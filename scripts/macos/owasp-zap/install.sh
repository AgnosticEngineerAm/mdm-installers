#!/bin/bash
set -euo pipefail
# OWASP ZAP Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_OWASP_ZAP_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing OWASP ZAP..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: OWASP ZAP installed."
