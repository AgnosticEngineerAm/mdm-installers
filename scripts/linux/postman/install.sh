#!/bin/bash
set -euo pipefail

###############################################################################
# Postman Linux install (MDM Script)
# Version: 1.0
###############################################################################

### ====== CONFIG ==============================================================
POSTMAN_TAR_URL="https://dl.pstmn.io/download/latest/linux_64"
EXPECTED_SHA256=""
LOG_FILE="/var/log/mdm-postman-install.log"
### ===========================================================================

umask 077
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

log()  { echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] [Postman-Linux] $*"; }
fail() { log "ERROR: $*"; exit 1; }

[[ "$(id -u)" -eq 0 ]] || fail "Must run as root."

log "Starting Postman Linux install."

if [[ -d "/opt/Postman" ]]; then
  log "SKIP: Postman already installed."
  exit 0
fi

TMP_DIR="$(mktemp -d)"
TAR_PATH="$TMP_DIR/Postman.tar.gz"
trap 'rm -rf "$TMP_DIR" 2>/dev/null || true' EXIT

log "Downloading Postman tarball..."
curl -fLsS --retry 3 --retry-delay 2 --connect-timeout 15 --max-time 900 \
  -L -o "$TAR_PATH" "$POSTMAN_TAR_URL" \
  || fail "Download failed."

if [[ -n "$EXPECTED_SHA256" ]]; then
  ACTUAL="$(sha256sum "$TAR_PATH" | awk '{print $1}')"
  [[ "$ACTUAL" == "$EXPECTED_SHA256" ]] || fail "SHA256 mismatch."
fi

log "Extracting to /opt/..."
tar -xzf "$TAR_PATH" -C /opt/ || fail "Extraction failed."

if [[ -d "/opt/Postman" ]]; then
  # Create a symlink in /usr/bin
  ln -sf /opt/Postman/Postman /usr/bin/postman
  log "SUCCESS: Postman installed to /opt/Postman."
  exit 0
fi

fail "Postman directory not found after extraction."
