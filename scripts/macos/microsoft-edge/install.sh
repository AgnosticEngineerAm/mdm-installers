#!/bin/bash
set -euo pipefail
# Microsoft Edge Enterprise macOS MDM Install

EDGE_PKG_URL="https://go.microsoft.com/fwlink/?linkid=2093504"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Microsoft Edge..."

if [[ -d "/Applications/Microsoft Edge.app" ]]; then
  log "SKIP: Microsoft Edge is already installed."
  exit 0
fi

download_pkg "$EDGE_PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Microsoft Edge installed."
