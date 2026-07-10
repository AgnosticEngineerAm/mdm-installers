#!/bin/bash
set -euo pipefail
# Rancher Desktop Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_RANCHER_DESKTOP_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Rancher Desktop..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Rancher Desktop installed."
