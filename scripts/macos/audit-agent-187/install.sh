#!/bin/bash
set -euo pipefail
# Audit Agent 187 Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_AUDIT_AGENT_187_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Audit Agent 187..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Audit Agent 187 installed."
