#!/bin/bash
set -euo pipefail
# Airtable Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_AIRTABLE_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Airtable..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Airtable installed."
