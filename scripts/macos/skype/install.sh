#!/bin/bash
set -euo pipefail
# Skype Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_SKYPE_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Skype..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Skype installed."
