#!/bin/bash
set -euo pipefail
# VMware Workstation Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_VMWARE_WORKSTATION_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing VMware Workstation..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: VMware Workstation installed."
