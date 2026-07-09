#!/bin/bash
set -euo pipefail
# YubiKey Manager Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_YUBIKEY_MANAGER_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing YubiKey Manager..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: YubiKey Manager installed."
