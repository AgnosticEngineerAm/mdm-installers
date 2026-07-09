#!/bin/bash
set -euo pipefail
# MSI Afterburner Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_MSI_AFTERBURNER_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing MSI Afterburner..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: MSI Afterburner installed."
