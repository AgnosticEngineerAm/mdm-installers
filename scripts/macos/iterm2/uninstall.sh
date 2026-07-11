#!/bin/bash
set -euo pipefail

###############################################################################
# iTerm2 macOS UNINSTALL (MDM Script)
# Version: 1.0
###############################################################################

### ====== CONFIG ==============================================================
LOG_FILE="/var/log/mdm-iterm2-uninstall.log"
### ===========================================================================

umask 077
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

log()  { echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] [iTerm2-Uninstall] $*"; }
fail() { log "ERROR: $*"; exit 1; }

[[ "$(id -u)" -eq 0 ]] || fail "Must run as root/admin."

log "Starting iTerm2 uninstall."

is_iterm2_installed() {
  [[ -d "/Applications/iTerm.app" ]]
}

if ! is_iterm2_installed; then
  log "SKIP: iTerm2 is not installed."
  exit 0
fi

log "Stopping iTerm2 processes..."
pkill -f "iTerm" 2>/dev/null || true
sleep 2

log "Removing iTerm2 application..."
rm -rf "/Applications/iTerm.app" 2>/dev/null || true

log "Cleaning up iTerm2 support files..."
for USER_HOME in /Users/*; do
  [[ -d "$USER_HOME" ]] || continue
  rm -rf "$USER_HOME/Library/Application Support/iTerm2" 2>/dev/null || true
  rm -rf "$USER_HOME/Library/Caches/com.googlecode.iterm2" 2>/dev/null || true
  rm -rf "$USER_HOME/Library/Preferences/com.googlecode.iterm2.plist" 2>/dev/null || true
done

if is_iterm2_installed; then
  fail "iTerm2 still detected after uninstall."
fi

log "SUCCESS: iTerm2 has been uninstalled."
exit 0
