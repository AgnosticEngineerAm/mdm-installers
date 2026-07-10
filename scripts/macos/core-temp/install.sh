#!/bin/bash
set -euo pipefail
# Core Temp Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_CORE_TEMP_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Core Temp..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Core Temp installed."
