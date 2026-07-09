#!/bin/bash
set -euo pipefail
# Backup Agent 212 Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_BACKUP_AGENT_212_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Backup Agent 212..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Backup Agent 212 installed."
