#!/bin/bash
set -euo pipefail
# Zoho CRM Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_ZOHO_CRM_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Zoho CRM..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Zoho CRM installed."
