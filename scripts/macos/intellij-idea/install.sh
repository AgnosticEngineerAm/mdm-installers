#!/bin/bash
set -euo pipefail
# Intellij Idea Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_INTELLIJ_IDEA_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Intellij Idea..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Intellij Idea installed."
