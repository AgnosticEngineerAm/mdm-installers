#!/bin/bash
set -euo pipefail
# Addigy Agent Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_ADDIGY_AGENT_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Addigy Agent..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Addigy Agent installed."
