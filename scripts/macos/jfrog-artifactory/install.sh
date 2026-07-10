#!/bin/bash
set -euo pipefail
# JFrog Artifactory Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_JFROG_ARTIFACTORY_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing JFrog Artifactory..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: JFrog Artifactory installed."
