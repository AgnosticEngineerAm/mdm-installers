#!/bin/bash
set -euo pipefail
# Monitoring Agent 119 Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_MONITORING_AGENT_119_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Monitoring Agent 119..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Monitoring Agent 119 installed."
