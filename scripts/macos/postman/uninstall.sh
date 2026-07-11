#!/bin/bash
set -euo pipefail

###############################################################################
# Postman macOS UNINSTALL (MDM Script)
# Version: 1.0
###############################################################################

### ====== CONFIG ==============================================================
LOG_FILE="/var/log/mdm-postman-uninstall.log"
### ===========================================================================

umask 077
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

log()  { echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] [Postman-Uninstall] $*"; }
fail() { log "ERROR: $*"; exit 1; }

[[ "$(id -u)" -eq 0 ]] || fail "Must run as root/admin."

log "Starting Postman uninstall."

is_postman_installed() {
  [[ -d "/Applications/Postman.app" ]]
}

if ! is_postman_installed; then
  log "SKIP: Postman is not installed."
  exit 0
fi

log "Stopping Postman processes..."
pkill -f "Postman" 2>/dev/null || true
sleep 2

log "Removing Postman application..."
rm -rf "/Applications/Postman.app" 2>/dev/null || true

log "Cleaning up Postman support files..."
for USER_HOME in /Users/*; do
  [[ -d "$USER_HOME" ]] || continue
  rm -rf "$USER_HOME/Library/Application Support/Postman" 2>/dev/null || true
  rm -rf "$USER_HOME/Library/Caches/com.postmanlabs.mac" 2>/dev/null || true
  rm -rf "$USER_HOME/Library/Preferences/com.postmanlabs.mac.plist" 2>/dev/null || true
done

if is_postman_installed; then
  fail "Postman still detected after uninstall."
fi

log "SUCCESS: Postman has been uninstalled."
exit 0
