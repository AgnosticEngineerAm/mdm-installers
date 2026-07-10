#!/bin/bash
set -euo pipefail
# Cobian Backup Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_COBIAN_BACKUP_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Cobian Backup..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Cobian Backup installed."
