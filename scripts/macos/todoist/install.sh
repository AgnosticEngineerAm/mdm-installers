#!/bin/bash
set -euo pipefail
# Todoist Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_TODOIST_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Todoist..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Todoist installed."
