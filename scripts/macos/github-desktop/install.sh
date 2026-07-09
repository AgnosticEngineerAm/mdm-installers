#!/bin/bash
set -euo pipefail
# Github Desktop Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_GITHUB_DESKTOP_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Github Desktop..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Github Desktop installed."
