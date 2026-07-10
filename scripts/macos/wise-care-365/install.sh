#!/bin/bash
set -euo pipefail
# Wise Care 365 Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_WISE_CARE_365_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Wise Care 365..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Wise Care 365 installed."
