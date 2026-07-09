#!/bin/bash
set -euo pipefail
# 3DMark Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_3DMARK_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing 3DMark..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: 3DMark installed."
