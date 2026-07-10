#!/bin/bash
set -euo pipefail
# New Relic Agent Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_NEW_RELIC_AGENT_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing New Relic Agent..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: New Relic Agent installed."
