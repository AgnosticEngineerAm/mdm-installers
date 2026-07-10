#!/bin/bash
set -euo pipefail
# Cain and Abel Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_CAIN_AND_ABEL_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Cain and Abel..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Cain and Abel installed."
