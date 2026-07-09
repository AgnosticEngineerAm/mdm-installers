#!/bin/bash
set -euo pipefail
# PassMark PerformanceTest Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_PASSMARK_PERFORMANCETEST_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing PassMark PerformanceTest..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: PassMark PerformanceTest installed."
