#!/bin/bash
set -euo pipefail

###############################################################################
# Slack macOS UNINSTALL (MDM Script)
# Version: 1.0
# Tested on: macOS 13 Ventura, 14 Sonoma, 15 Sequoia
#
# Removes Slack.app, Application Support data, preferences, and caches.
###############################################################################

### ====== CONFIG ==============================================================
LOG_FILE="/var/log/mdm-slack-uninstall.log"
### ===========================================================================

umask 077
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

log()  { echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] [Slack-Uninstall] $*"; }
fail() { log "ERROR: $*"; exit 1; }

[[ "$(id -u)" -eq 0 ]] || fail "Must run as root/admin."

log "Starting Slack uninstall."
log "macOS $(sw_vers -productVersion) | $(uname -m)"

is_slack_installed() {
  [[ -d "/Applications/Slack.app" ]]
}

if ! is_slack_installed; then
  log "SKIP: Slack is not installed. No action taken."
  exit 0
fi

# Kill Slack processes
log "Stopping Slack processes..."
pkill -f "Slack" 2>/dev/null || true
sleep 2

# Remove the application
log "Removing Slack application..."
rm -rf "/Applications/Slack.app" 2>/dev/null || true

# Remove user-level data for all users
log "Cleaning up Slack support files..."
for USER_HOME in /Users/*; do
  [[ -d "$USER_HOME" ]] || continue
  rm -rf "$USER_HOME/Library/Application Support/Slack" 2>/dev/null || true
  rm -rf "$USER_HOME/Library/Preferences/com.tinyspeck.slackmacgap.plist" 2>/dev/null || true
  rm -rf "$USER_HOME/Library/Caches/com.tinyspeck.slackmacgap" 2>/dev/null || true
  rm -rf "$USER_HOME/Library/Caches/com.tinyspeck.slackmacgap.ShipIt" 2>/dev/null || true
  rm -rf "$USER_HOME/Library/Saved Application State/com.tinyspeck.slackmacgap.savedState" 2>/dev/null || true
done

if is_slack_installed; then
  fail "Slack still detected after uninstall. Manual cleanup may be required."
fi

log "SUCCESS: Slack has been uninstalled."
exit 0
