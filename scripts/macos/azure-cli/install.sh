#!/bin/bash
set -euo pipefail
# Azure Cli Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_AZURE_CLI_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Azure Cli..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Azure Cli installed."
