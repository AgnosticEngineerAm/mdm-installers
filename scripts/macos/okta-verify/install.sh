#!/bin/bash
set -euo pipefail
# Okta Verify Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_OKTA_VERIFY_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Okta Verify..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Okta Verify installed."
