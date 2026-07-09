#!/bin/bash
set -euo pipefail
# Splunk Universal Forwarder Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_SPLUNK_UNIVERSAL_FORWARDER_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Splunk Universal Forwarder..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Splunk Universal Forwarder installed."
