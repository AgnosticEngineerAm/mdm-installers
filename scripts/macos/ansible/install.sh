#!/bin/bash
set -euo pipefail
# Ansible Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_ANSIBLE_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Ansible..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Ansible installed."
