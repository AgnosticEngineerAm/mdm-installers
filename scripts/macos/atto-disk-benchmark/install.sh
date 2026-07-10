#!/bin/bash
set -euo pipefail
# ATTO Disk Benchmark Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_ATTO_DISK_BENCHMARK_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing ATTO Disk Benchmark..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: ATTO Disk Benchmark installed."
