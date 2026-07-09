#!/bin/bash
set -euo pipefail
# AS SSD Benchmark Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_AS_SSD_BENCHMARK_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing AS SSD Benchmark..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: AS SSD Benchmark installed."
