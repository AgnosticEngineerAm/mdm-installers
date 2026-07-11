#!/bin/bash
set -euo pipefail

###############################################################################
# 1Password macOS UNINSTALL (MDM Script)
# Version: 1.0
# Tested on: macOS 13 Ventura, 14 Sonoma, 15 Sequoia
#
# Removes 1Password 8 (or 7) app, browser extension helper, and support files.
# Vault data synced to 1Password.com is NOT affected by local uninstall.
###############################################################################

### ====== CONFIG ==============================================================
LOG_FILE="/var/log/mdm-1password-uninstall.log"
### ===========================================================================

umask 077
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

log()  { echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] [1Password-Uninstall] $*"; }
fail() { log "ERROR: $*"; exit 1; }

[[ "$(id -u)" -eq 0 ]] || fail "Must run as root/admin."

log "Starting 1Password uninstall."
log "macOS $(sw_vers -productVersion) | $(uname -m)"

is_1password_installed() {
  [[ -d "/Applications/1Password.app" ]] \
    || [[ -d "/Applications/1Password 7.app" ]]
}

if ! is_1password_installed; then
  log "SKIP: 1Password is not installed. No action taken."
  exit 0
fi

# Kill 1Password processes
log "Stopping 1Password processes..."
pkill -f "1Password" 2>/dev/null || true
sleep 2

# Remove the application(s)
log "Removing 1Password application..."
rm -rf "/Applications/1Password.app" 2>/dev/null || true
rm -rf "/Applications/1Password 7.app" 2>/dev/null || true

# Remove user-level data for all users
log "Cleaning up 1Password support files..."
for USER_HOME in /Users/*; do
  [[ -d "$USER_HOME" ]] || continue
  rm -rf "$USER_HOME/Library/Application Support/1Password" 2>/dev/null || true
  rm -rf "$USER_HOME/Library/Application Support/com.agilebits.onepassword" 2>/dev/null || true
  rm -rf "$USER_HOME/Library/Containers/com.agilebits.onepassword7" 2>/dev/null || true
  rm -rf "$USER_HOME/Library/Group Containers/2BUA8C4S2C.com.agilebits" 2>/dev/null || true
  rm -rf "$USER_HOME/Library/Preferences/com.agilebits.onepassword7.plist" 2>/dev/null || true
  rm -rf "$USER_HOME/Library/Caches/com.agilebits.onepassword" 2>/dev/null || true
done

# Remove pkg receipts
for receipt in $(pkgutil --pkgs 2>/dev/null | grep -i "agilebits\|onepassword\|1password" || true); do
  pkgutil --forget "$receipt" 2>/dev/null || true
  log "Forgot pkg receipt: $receipt"
done

if is_1password_installed; then
  fail "1Password still detected after uninstall. Manual cleanup may be required."
fi

log "SUCCESS: 1Password has been uninstalled."
exit 0
