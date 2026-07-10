#!/bin/bash
set -euo pipefail
# pgAdmin Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_PGADMIN_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing pgAdmin..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: pgAdmin installed."
