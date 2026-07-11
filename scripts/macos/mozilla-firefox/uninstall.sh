#!/bin/bash
set -euo pipefail

###############################################################################
# Mozilla Firefox macOS UNINSTALL (MDM Script)
# Version: 1.0
# Tested on: macOS 13 Ventura, 14 Sonoma, 15 Sequoia
###############################################################################

### ====== CONFIG ==============================================================
LOG_FILE="/var/log/mdm-firefox-uninstall.log"
### ===========================================================================

umask 077
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

log()  { echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] [Firefox-Uninstall] $*"; }
fail() { log "ERROR: $*"; exit 1; }

[[ "$(id -u)" -eq 0 ]] || fail "Must run as root/admin."

log "Starting Mozilla Firefox uninstall."

is_firefox_installed() {
  [[ -d "/Applications/Firefox.app" ]]
}

if ! is_firefox_installed; then
  log "SKIP: Firefox is not installed."
  exit 0
fi

log "Stopping Firefox processes..."
pkill -f "Firefox" 2>/dev/null || true
sleep 2

log "Removing Firefox application..."
rm -rf "/Applications/Firefox.app" 2>/dev/null || true

log "Cleaning up Firefox support files..."
for USER_HOME in /Users/*; do
  [[ -d "$USER_HOME" ]] || continue
  rm -rf "$USER_HOME/Library/Application Support/Firefox" 2>/dev/null || true
  rm -rf "$USER_HOME/Library/Caches/Firefox" 2>/dev/null || true
  rm -rf "$USER_HOME/Library/Caches/org.mozilla.firefox" 2>/dev/null || true
  rm -rf "$USER_HOME/Library/Preferences/org.mozilla.firefox.plist" 2>/dev/null || true
done

for receipt in $(pkgutil --pkgs 2>/dev/null | grep -i "org.mozilla.firefox" || true); do
  pkgutil --forget "$receipt" 2>/dev/null || true
  log "Forgot pkg receipt: $receipt"
done

if is_firefox_installed; then
  fail "Firefox still detected after uninstall."
fi

log "SUCCESS: Firefox has been uninstalled."
exit 0
