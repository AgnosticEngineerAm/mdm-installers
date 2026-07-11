#!/bin/bash
set -euo pipefail

###############################################################################
# Zoom macOS UNINSTALL (MDM Script)
# Version: 1.0
# Tested on: macOS 13 Ventura, 14 Sonoma, 15 Sequoia
#
# Removes Zoom.us app, LaunchAgents, Application Support, and preferences.
###############################################################################

### ====== CONFIG ==============================================================
LOG_FILE="/var/log/mdm-zoom-uninstall.log"
### ===========================================================================

umask 077
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

log()  { echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] [Zoom-Uninstall] $*"; }
fail() { log "ERROR: $*"; exit 1; }

[[ "$(id -u)" -eq 0 ]] || fail "Must run as root/admin."

log "Starting Zoom uninstall."
log "macOS $(sw_vers -productVersion) | $(uname -m)"

is_zoom_installed() {
  [[ -d "/Applications/zoom.us.app" ]] || pkgutil --pkgs 2>/dev/null | grep -qi "zoom"
}

if ! is_zoom_installed; then
  log "SKIP: Zoom is not installed. No action taken."
  exit 0
fi

# Kill Zoom processes
log "Stopping Zoom processes..."
pkill -f "zoom.us" 2>/dev/null || true
sleep 2

# Remove the application
log "Removing Zoom application..."
rm -rf "/Applications/zoom.us.app" 2>/dev/null || true

# Remove user-level data for all users
log "Cleaning up Zoom support files..."
for USER_HOME in /Users/*; do
  [[ -d "$USER_HOME" ]] || continue
  rm -rf "$USER_HOME/Library/Application Support/zoom.us" 2>/dev/null || true
  rm -rf "$USER_HOME/Library/Preferences/us.zoom.xos.plist" 2>/dev/null || true
  rm -rf "$USER_HOME/Library/Caches/us.zoom.xos" 2>/dev/null || true
  rm -rf "$USER_HOME/Library/Logs/zoom.us" 2>/dev/null || true
  rm -f  "$USER_HOME/Library/LaunchAgents/"*zoom* 2>/dev/null || true
done

# Remove system-level LaunchDaemons if any
rm -f /Library/LaunchDaemons/*zoom* 2>/dev/null || true

# Forget pkg receipts
for receipt in $(pkgutil --pkgs 2>/dev/null | grep -i "zoom" || true); do
  pkgutil --forget "$receipt" 2>/dev/null || true
  log "Forgot pkg receipt: $receipt"
done

if is_zoom_installed; then
  fail "Zoom still detected after uninstall. Manual cleanup may be required."
fi

log "SUCCESS: Zoom has been uninstalled."
exit 0
