#!/bin/bash
set -euo pipefail
# Audit Agent 7 Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_AUDIT_AGENT_7_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Audit Agent 7..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Audit Agent 7 installed."
