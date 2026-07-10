#!/bin/bash
set -euo pipefail
# Datadog Agent Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_DATADOG_AGENT_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Datadog Agent..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Datadog Agent installed."
