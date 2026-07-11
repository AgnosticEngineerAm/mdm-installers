#!/bin/bash
set -euo pipefail

###############################################################################
# Microsoft Edge macOS UNINSTALL (MDM Script)
# Version: 1.0
###############################################################################

### ====== CONFIG ==============================================================
LOG_FILE="/var/log/mdm-edge-uninstall.log"
### ===========================================================================

umask 077
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

log()  { echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] [Edge-Uninstall] $*"; }
fail() { log "ERROR: $*"; exit 1; }

[[ "$(id -u)" -eq 0 ]] || fail "Must run as root/admin."

log "Starting Microsoft Edge uninstall."

is_edge_installed() {
  [[ -d "/Applications/Microsoft Edge.app" ]]
}

if ! is_edge_installed; then
  log "SKIP: Microsoft Edge is not installed."
  exit 0
fi

log "Stopping Edge processes..."
pkill -f "Microsoft Edge" 2>/dev/null || true
sleep 2

log "Removing Microsoft Edge application..."
rm -rf "/Applications/Microsoft Edge.app" 2>/dev/null || true

log "Cleaning up Edge support files..."
for USER_HOME in /Users/*; do
  [[ -d "$USER_HOME" ]] || continue
  rm -rf "$USER_HOME/Library/Application Support/Microsoft Edge" 2>/dev/null || true
  rm -rf "$USER_HOME/Library/Caches/Microsoft Edge" 2>/dev/null || true
  rm -rf "$USER_HOME/Library/Preferences/com.microsoft.edgemac.plist" 2>/dev/null || true
done

for receipt in $(pkgutil --pkgs 2>/dev/null | grep -i "com.microsoft.edgemac" || true); do
  pkgutil --forget "$receipt" 2>/dev/null || true
  log "Forgot pkg receipt: $receipt"
done

if is_edge_installed; then
  fail "Microsoft Edge still detected after uninstall."
fi

log "SUCCESS: Microsoft Edge has been uninstalled."
exit 0
