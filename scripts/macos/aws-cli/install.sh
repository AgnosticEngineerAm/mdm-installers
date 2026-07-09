#!/bin/bash
set -euo pipefail
# Aws Cli Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_AWS_CLI_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Aws Cli..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Aws Cli installed."
