#!/bin/bash
set -euo pipefail
# Microsoft Excel Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_MICROSOFT_EXCEL_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Microsoft Excel..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Microsoft Excel installed."
