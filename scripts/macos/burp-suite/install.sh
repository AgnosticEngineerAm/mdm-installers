#!/bin/bash
set -euo pipefail
# Burp Suite Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_BURP_SUITE_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Burp Suite..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Burp Suite installed."
