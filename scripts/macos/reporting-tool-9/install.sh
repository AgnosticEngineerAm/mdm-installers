#!/bin/bash
set -euo pipefail
# Reporting Tool 9 Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_REPORTING_TOOL_9_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Reporting Tool 9..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Reporting Tool 9 installed."
