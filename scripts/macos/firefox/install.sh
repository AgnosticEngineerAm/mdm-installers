#!/bin/bash
set -euo pipefail
# Firefox Enterprise macOS MDM Install

FIREFOX_PKG_URL="https://download.mozilla.org/?product=firefox-pkg-latest-ssl&os=osx&lang=en-US"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Mozilla Firefox..."

if [[ -d "/Applications/Firefox.app" ]]; then
  log "SKIP: Firefox is already installed."
  exit 0
fi

download_pkg "$FIREFOX_PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Firefox installed."
