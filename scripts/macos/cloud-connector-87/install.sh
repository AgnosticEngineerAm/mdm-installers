#!/bin/bash
set -euo pipefail
# Cloud Connector 87 Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_CLOUD_CONNECTOR_87_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Cloud Connector 87..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Cloud Connector 87 installed."
