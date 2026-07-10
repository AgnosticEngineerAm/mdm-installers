#!/bin/bash
set -euo pipefail
# Unreal Engine Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_UNREAL_ENGINE_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Unreal Engine..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Unreal Engine installed."
