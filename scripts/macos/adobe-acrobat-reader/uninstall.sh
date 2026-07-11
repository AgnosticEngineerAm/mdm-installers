#!/bin/bash
set -euo pipefail

###############################################################################
# Adobe Acrobat Reader macOS UNINSTALL (MDM Script)
# Version: 1.0
###############################################################################

### ====== CONFIG ==============================================================
LOG_FILE="/var/log/mdm-acrobat-reader-uninstall.log"
### ===========================================================================

umask 077
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

log()  { echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] [AcrobatReader-Uninstall] $*"; }
fail() { log "ERROR: $*"; exit 1; }

[[ "$(id -u)" -eq 0 ]] || fail "Must run as root/admin."

log "Starting Adobe Acrobat Reader uninstall."

is_acrobat_installed() {
  [[ -d "/Applications/Adobe Acrobat Reader.app" ]]
}

if ! is_acrobat_installed; then
  log "SKIP: Adobe Acrobat Reader is not installed."
  exit 0
fi

log "Stopping Acrobat Reader processes..."
pkill -f "Adobe Acrobat Reader" 2>/dev/null || true
pkill -f "Acrobat Reader" 2>/dev/null || true
sleep 2

log "Removing Acrobat Reader application..."
rm -rf "/Applications/Adobe Acrobat Reader.app" 2>/dev/null || true

log "Cleaning up Acrobat Reader support files..."
for USER_HOME in /Users/*; do
  [[ -d "$USER_HOME" ]] || continue
  rm -rf "$USER_HOME/Library/Application Support/Adobe/Acrobat" 2>/dev/null || true
  rm -rf "$USER_HOME/Library/Caches/com.adobe.Reader" 2>/dev/null || true
  rm -rf "$USER_HOME/Library/Preferences/com.adobe.Reader.plist" 2>/dev/null || true
done

for receipt in $(pkgutil --pkgs 2>/dev/null | grep -i "com.adobe.acrobat.reader" || true); do
  pkgutil --forget "$receipt" 2>/dev/null || true
  log "Forgot pkg receipt: $receipt"
done

if is_acrobat_installed; then
  fail "Adobe Acrobat Reader still detected after uninstall."
fi

log "SUCCESS: Adobe Acrobat Reader has been uninstalled."
exit 0
