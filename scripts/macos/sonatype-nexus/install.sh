#!/bin/bash
set -euo pipefail
# Sonatype Nexus Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_SONATYPE_NEXUS_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Sonatype Nexus..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Sonatype Nexus installed."
