#!/bin/bash
set -euo pipefail
# GitLab Runner Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_GITLAB_RUNNER_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing GitLab Runner..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: GitLab Runner installed."
