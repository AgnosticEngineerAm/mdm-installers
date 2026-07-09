#!/bin/bash
set -euo pipefail
# Backup Agent 20 Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_BACKUP_AGENT_20_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Backup Agent 20..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Backup Agent 20 installed."
