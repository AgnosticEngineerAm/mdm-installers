#!/bin/bash
set -euo pipefail
# RivaTuner Statistics Server Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_RIVATUNER_STATISTICS_SERVER_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing RivaTuner Statistics Server..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: RivaTuner Statistics Server installed."
