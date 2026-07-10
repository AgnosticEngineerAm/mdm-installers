#!/bin/bash
set -euo pipefail
# AppDynamics Agent Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_APPDYNAMICS_AGENT_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing AppDynamics Agent..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: AppDynamics Agent installed."
