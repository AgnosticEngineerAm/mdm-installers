#!/bin/bash
set -euo pipefail
# Snowflake SnowSQL Enterprise macOS MDM Install

PKG_URL="PASTE_YOUR_MAC_URL_FOR_SNOWFLAKE_SNOWSQL_HERE"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing Snowflake SnowSQL..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: Snowflake SnowSQL installed."
