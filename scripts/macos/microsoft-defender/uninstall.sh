#!/bin/bash
set -euo pipefail

###############################################################################
# Microsoft Defender macOS UNINSTALL (MDM Script)
# Version: 1.0
# Tested on: macOS 13 Ventura, 14 Sonoma, 15 Sequoia
#
# Removes Microsoft Defender for Endpoint and associated services.
# This does NOT remove PPPC or System Extension profiles — remove those
# separately via your MDM.
###############################################################################

### ====== CONFIG ==============================================================
LOG_FILE="/var/log/mdm-defender-uninstall.log"
### ===========================================================================

umask 077
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

log()  { echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] [Defender-Uninstall] $*"; }
fail() { log "ERROR: $*"; exit 1; }

[[ "$(id -u)" -eq 0 ]] || fail "Must run as root/admin."

log "Starting Microsoft Defender uninstall."
log "macOS $(sw_vers -productVersion) | $(uname -m)"

is_defender_installed() {
  [[ -d "/Applications/Microsoft Defender.app" ]] \
    || [[ -d "/Library/Application Support/Microsoft/Defender" ]]
}

if ! is_defender_installed; then
  log "SKIP: Microsoft Defender is not installed. No action taken."
  exit 0
fi

# Kill Defender processes
log "Stopping Microsoft Defender processes..."
pkill -f "Microsoft Defender" 2>/dev/null || true
sleep 2

# Unload LaunchDaemons
for plist in /Library/LaunchDaemons/com.microsoft.wdav*; do
  [[ -f "$plist" ]] || continue
  launchctl unload "$plist" 2>/dev/null || true
  log "Unloaded $plist"
done

# Remove the application
log "Removing Microsoft Defender application..."
rm -rf "/Applications/Microsoft Defender.app" 2>/dev/null || true

# Remove Defender system support files
rm -rf "/Library/Application Support/Microsoft/Defender" 2>/dev/null || true
rm -f /Library/LaunchDaemons/com.microsoft.wdav* 2>/dev/null || true

# Remove user-level data for all users
log "Cleaning up Defender support files..."
for USER_HOME in /Users/*; do
  [[ -d "$USER_HOME" ]] || continue
  rm -rf "$USER_HOME/Library/Application Support/com.microsoft.wdav" 2>/dev/null || true
  rm -rf "$USER_HOME/Library/Preferences/com.microsoft.wdav.plist" 2>/dev/null || true
  rm -f  "$USER_HOME/Library/LaunchAgents/com.microsoft.wdav."* 2>/dev/null || true
done

# Forget pkg receipts
for receipt in $(pkgutil --pkgs 2>/dev/null | grep -i "com.microsoft.wdav\|com.microsoft.defender" || true); do
  pkgutil --forget "$receipt" 2>/dev/null || true
  log "Forgot pkg receipt: $receipt"
done

if is_defender_installed; then
  fail "Microsoft Defender still detected after uninstall. Manual cleanup may be required."
fi

log "SUCCESS: Microsoft Defender has been uninstalled."
log "NOTE: Remove the PPPC and System Extension profiles from your MDM separately."
exit 0
