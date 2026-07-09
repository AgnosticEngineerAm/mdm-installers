#!/bin/bash
set -euo pipefail
# Cloud Connector 219 Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_CLOUD_CONNECTOR_219_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Cloud Connector 219..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Cloud Connector 219 installed."
