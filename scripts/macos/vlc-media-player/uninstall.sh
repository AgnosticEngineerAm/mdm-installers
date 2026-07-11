#!/bin/bash
set -euo pipefail

###############################################################################
# VLC Media Player macOS UNINSTALL (MDM Script)
# Version: 1.0
###############################################################################

### ====== CONFIG ==============================================================
LOG_FILE="/var/log/mdm-vlc-uninstall.log"
### ===========================================================================

umask 077
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

log()  { echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] [VLC-Uninstall] $*"; }
fail() { log "ERROR: $*"; exit 1; }

[[ "$(id -u)" -eq 0 ]] || fail "Must run as root/admin."

log "Starting VLC uninstall."

is_vlc_installed() {
  [[ -d "/Applications/VLC.app" ]]
}

if ! is_vlc_installed; then
  log "SKIP: VLC is not installed."
  exit 0
fi

log "Stopping VLC processes..."
pkill -f "VLC" 2>/dev/null || true
sleep 2

log "Removing VLC application..."
rm -rf "/Applications/VLC.app" 2>/dev/null || true

log "Cleaning up VLC support files..."
for USER_HOME in /Users/*; do
  [[ -d "$USER_HOME" ]] || continue
  rm -rf "$USER_HOME/Library/Application Support/org.videolan.vlc" 2>/dev/null || true
  rm -rf "$USER_HOME/Library/Caches/org.videolan.vlc" 2>/dev/null || true
  rm -rf "$USER_HOME/Library/Preferences/org.videolan.vlc.plist" 2>/dev/null || true
done

if is_vlc_installed; then
  fail "VLC still detected after uninstall."
fi

log "SUCCESS: VLC has been uninstalled."
exit 0
