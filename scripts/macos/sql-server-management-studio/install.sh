#!/bin/bash
set -euo pipefail
# SQL Server Management Studio Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_SQL_SERVER_MANAGEMENT_STUDIO_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing SQL Server Management Studio..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: SQL Server Management Studio installed."
