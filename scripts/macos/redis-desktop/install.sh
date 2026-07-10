#!/bin/bash
set -euo pipefail
# Redis Desktop Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_REDIS_DESKTOP_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Redis Desktop..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Redis Desktop installed."
