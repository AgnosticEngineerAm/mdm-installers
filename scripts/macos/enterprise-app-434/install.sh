#!/bin/bash
set -euo pipefail
# Enterprise App 434 Enterprise macOS MDM Install

PKG_URL="PASTE_MAC_URL_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Enterprise App 434..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Enterprise App 434 installed."
