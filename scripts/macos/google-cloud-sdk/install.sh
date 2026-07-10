#!/bin/bash
set -euo pipefail
# Google Cloud Sdk Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_GOOGLE_CLOUD_SDK_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Google Cloud Sdk..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Google Cloud Sdk installed."
