#!/bin/bash
set -euo pipefail
# 1Password Extension Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_1PASSWORD_EXTENSION_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing 1Password Extension..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: 1Password Extension installed."
