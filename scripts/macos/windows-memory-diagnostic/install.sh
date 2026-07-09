#!/bin/bash
set -euo pipefail
# Windows Memory Diagnostic Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_WINDOWS_MEMORY_DIAGNOSTIC_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Windows Memory Diagnostic..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Windows Memory Diagnostic installed."
