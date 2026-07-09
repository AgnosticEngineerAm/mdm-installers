#!/bin/bash
set -euo pipefail
# Bullzip PDF Printer Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_BULLZIP_PDF_PRINTER_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Bullzip PDF Printer..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Bullzip PDF Printer installed."
