#!/bin/bash
set -euo pipefail
# Reporting Tool 117 Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_REPORTING_TOOL_117_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Reporting Tool 117..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Reporting Tool 117 installed."
