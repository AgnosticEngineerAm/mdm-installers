#!/bin/bash
set -euo pipefail
# Network Probe 192 Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_NETWORK_PROBE_192_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Network Probe 192..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Network Probe 192 installed."
