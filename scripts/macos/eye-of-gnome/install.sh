#!/bin/bash
set -euo pipefail
# Eye of GNOME Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_EYE_OF_GNOME_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Eye of GNOME..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Eye of GNOME installed."
