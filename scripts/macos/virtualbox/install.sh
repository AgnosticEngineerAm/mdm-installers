#!/bin/bash
set -euo pipefail
# VirtualBox Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_VIRTUALBOX_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing VirtualBox..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: VirtualBox installed."
