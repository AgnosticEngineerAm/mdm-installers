#!/bin/bash
set -euo pipefail
# ClickUp Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_CLICKUP_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing ClickUp..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: ClickUp installed."
