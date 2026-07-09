#!/bin/bash
set -euo pipefail
# Citrix Workspace Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_CITRIX_WORKSPACE_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Citrix Workspace..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Citrix Workspace installed."
