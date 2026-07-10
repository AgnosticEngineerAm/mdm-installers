#!/bin/bash
set -euo pipefail
# BloodHound Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_BLOODHOUND_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing BloodHound..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: BloodHound installed."
