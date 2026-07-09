#!/bin/bash
set -euo pipefail
# Argus Monitor Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_ARGUS_MONITOR_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Argus Monitor..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Argus Monitor installed."
