#!/bin/bash
set -euo pipefail
# Duplicati Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_DUPLICATI_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Duplicati..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Duplicati installed."
