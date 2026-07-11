#!/bin/bash
set -euo pipefail

###############################################################################
# Microsoft Teams macOS UNINSTALL (MDM Script)
# Version: 1.0
###############################################################################

### ====== CONFIG ==============================================================
LOG_FILE="/var/log/mdm-teams-uninstall.log"
### ===========================================================================

umask 077
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

log()  { echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] [Teams-Uninstall] $*"; }
fail() { log "ERROR: $*"; exit 1; }

[[ "$(id -u)" -eq 0 ]] || fail "Must run as root/admin."

log "Starting Microsoft Teams uninstall."

is_teams_installed() {
  [[ -d "/Applications/Microsoft Teams.app" ]] || [[ -d "/Applications/Microsoft Teams (work or school).app" ]]
}

if ! is_teams_installed; then
  log "SKIP: Microsoft Teams is not installed."
  exit 0
fi

log "Stopping Teams processes..."
pkill -f "Microsoft Teams" 2>/dev/null || true
pkill -f "Teams" 2>/dev/null || true
sleep 2

log "Removing Teams applications..."
rm -rf "/Applications/Microsoft Teams.app" 2>/dev/null || true
rm -rf "/Applications/Microsoft Teams (work or school).app" 2>/dev/null || true

log "Cleaning up Teams support files..."
for USER_HOME in /Users/*; do
  [[ -d "$USER_HOME" ]] || continue
  rm -rf "$USER_HOME/Library/Application Support/Microsoft/Teams" 2>/dev/null || true
  rm -rf "$USER_HOME/Library/Application Support/com.microsoft.teams" 2>/dev/null || true
  rm -rf "$USER_HOME/Library/Caches/com.microsoft.teams" 2>/dev/null || true
  rm -rf "$USER_HOME/Library/Preferences/com.microsoft.teams.plist" 2>/dev/null || true
  rm -rf "$USER_HOME/Library/Containers/com.microsoft.teams2" 2>/dev/null || true
  rm -rf "$USER_HOME/Library/Group Containers/UBF8T346G9.com.microsoft.teams" 2>/dev/null || true
done

for receipt in $(pkgutil --pkgs 2>/dev/null | grep -i "com.microsoft.teams" || true); do
  pkgutil --forget "$receipt" 2>/dev/null || true
  log "Forgot pkg receipt: $receipt"
done

if is_teams_installed; then
  fail "Teams still detected after uninstall."
fi

log "SUCCESS: Microsoft Teams has been uninstalled."
exit 0
