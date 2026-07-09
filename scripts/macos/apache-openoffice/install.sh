#!/bin/bash
set -euo pipefail
# Apache OpenOffice Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_APACHE_OPENOFFICE_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Apache OpenOffice..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Apache OpenOffice installed."
