#!/bin/bash
set -euo pipefail
# MySQL Workbench Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_MYSQL_WORKBENCH_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing MySQL Workbench..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: MySQL Workbench installed."
