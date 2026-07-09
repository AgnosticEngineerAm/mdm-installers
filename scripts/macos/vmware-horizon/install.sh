#!/bin/bash
set -euo pipefail
# VMware Horizon Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_VMWARE_HORIZON_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing VMware Horizon..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: VMware Horizon installed."
