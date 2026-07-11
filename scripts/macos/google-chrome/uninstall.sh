#!/bin/bash
set -euo pipefail

###############################################################################
# Google Chrome macOS UNINSTALL (MDM Script)
# Version: 1.0
# Tested on: macOS 13 Ventura, 14 Sonoma, 15 Sequoia
#
# Removes Google Chrome, Google Software Update, user profiles, and caches.
# WARNING: This will delete all Chrome user profiles and browsing data.
###############################################################################

### ====== CONFIG ==============================================================
LOG_FILE="/var/log/mdm-chrome-uninstall.log"
### ===========================================================================

umask 077
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

log()  { echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] [Chrome-Uninstall] $*"; }
fail() { log "ERROR: $*"; exit 1; }

[[ "$(id -u)" -eq 0 ]] || fail "Must run as root/admin."

log "Starting Google Chrome uninstall."
log "macOS $(sw_vers -productVersion) | $(uname -m)"

is_chrome_installed() {
  [[ -d "/Applications/Google Chrome.app" ]]
}

if ! is_chrome_installed; then
  log "SKIP: Google Chrome is not installed. No action taken."
  exit 0
fi

# Kill Chrome processes
log "Stopping Chrome processes..."
pkill -f "Google Chrome" 2>/dev/null || true
sleep 2

# Remove the application
log "Removing Google Chrome application..."
rm -rf "/Applications/Google Chrome.app" 2>/dev/null || true

# Remove user-level data for all users
log "Cleaning up Chrome support files..."
for USER_HOME in /Users/*; do
  [[ -d "$USER_HOME" ]] || continue
  rm -rf "$USER_HOME/Library/Application Support/Google/Chrome" 2>/dev/null || true
  rm -rf "$USER_HOME/Library/Caches/Google/Chrome" 2>/dev/null || true
  rm -rf "$USER_HOME/Library/Caches/com.google.Chrome" 2>/dev/null || true
  rm -rf "$USER_HOME/Library/Preferences/com.google.Chrome.plist" 2>/dev/null || true
  rm -rf "$USER_HOME/Library/Saved Application State/com.google.Chrome.savedState" 2>/dev/null || true
  rm -rf "$USER_HOME/Library/Google/GoogleSoftwareUpdate" 2>/dev/null || true
done

# Remove Google Software Update (Keystone) if no other Google apps remain
if [[ ! -d "/Applications/Google Drive.app" ]] && [[ ! -d "/Applications/Google Earth Pro.app" ]]; then
  rm -rf "/Library/Google/GoogleSoftwareUpdate" 2>/dev/null || true
  log "Removed Google Software Update (no other Google apps detected)."
else
  log "Other Google apps detected — leaving Google Software Update in place."
fi

# Forget pkg receipts
for receipt in $(pkgutil --pkgs 2>/dev/null | grep -i "com.google.Chrome" || true); do
  pkgutil --forget "$receipt" 2>/dev/null || true
  log "Forgot pkg receipt: $receipt"
done

if is_chrome_installed; then
  fail "Google Chrome still detected after uninstall. Manual cleanup may be required."
fi

log "SUCCESS: Google Chrome has been uninstalled."
exit 0
