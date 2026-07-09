#!/bin/bash
set -euo pipefail
# Cloud Connector 15 Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_CLOUD_CONNECTOR_15_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Cloud Connector 15..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Cloud Connector 15 installed."
