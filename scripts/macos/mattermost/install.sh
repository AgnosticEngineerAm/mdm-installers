#!/bin/bash
set -euo pipefail
# Mattermost Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_MATTERMOST_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Mattermost..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Mattermost installed."
