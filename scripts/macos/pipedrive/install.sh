#!/bin/bash
set -euo pipefail
# Pipedrive Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_PIPEDRIVE_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Pipedrive..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Pipedrive installed."
