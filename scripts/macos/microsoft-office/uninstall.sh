#!/bin/bash
set -euo pipefail

###############################################################################
# Microsoft Office macOS UNINSTALL (MDM Script)
# Version: 1.0
# Tested on: macOS 13 Ventura, 14 Sonoma, 15 Sequoia
#
# Removes all Microsoft Office apps (Word, Excel, PowerPoint, Outlook, OneNote,
# Teams, OneDrive), Microsoft AutoUpdate, and related support files.
# WARNING: This will remove locally cached data. Cloud-synced data is safe.
###############################################################################

### ====== CONFIG ==============================================================
LOG_FILE="/var/log/mdm-office-uninstall.log"
### ===========================================================================

umask 077
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

log()  { echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] [Office-Uninstall] $*"; }
fail() { log "ERROR: $*"; exit 1; }

[[ "$(id -u)" -eq 0 ]] || fail "Must run as root/admin."

log "Starting Microsoft Office uninstall."
log "macOS $(sw_vers -productVersion) | $(uname -m)"

OFFICE_APPS=(
  "Microsoft Word.app"
  "Microsoft Excel.app"
  "Microsoft PowerPoint.app"
  "Microsoft Outlook.app"
  "Microsoft OneNote.app"
  "Microsoft Teams.app"
  "Microsoft Teams classic.app"
  "OneDrive.app"
)

is_office_installed() {
  for app in "${OFFICE_APPS[@]}"; do
    [[ -d "/Applications/$app" ]] && return 0
  done
  return 1
}

if ! is_office_installed; then
  log "SKIP: No Microsoft Office apps detected. No action taken."
  exit 0
fi

# Kill Office processes
log "Stopping Microsoft Office processes..."
pkill -f "Microsoft Word" 2>/dev/null || true
pkill -f "Microsoft Excel" 2>/dev/null || true
pkill -f "Microsoft PowerPoint" 2>/dev/null || true
pkill -f "Microsoft Outlook" 2>/dev/null || true
pkill -f "Microsoft OneNote" 2>/dev/null || true
pkill -f "Microsoft Teams" 2>/dev/null || true
pkill -f "OneDrive" 2>/dev/null || true
pkill -f "Microsoft AutoUpdate" 2>/dev/null || true
sleep 2

# Remove Office applications
log "Removing Microsoft Office applications..."
for app in "${OFFICE_APPS[@]}"; do
  if [[ -d "/Applications/$app" ]]; then
    rm -rf "/Applications/$app"
    log "Removed /Applications/$app"
  fi
done

# Remove Microsoft AutoUpdate
rm -rf "/Library/Application Support/Microsoft/MAU2.0" 2>/dev/null || true

# Remove user-level data for all users
log "Cleaning up Office support files..."
for USER_HOME in /Users/*; do
  [[ -d "$USER_HOME" ]] || continue
  rm -rf "$USER_HOME/Library/Containers/com.microsoft.Word" 2>/dev/null || true
  rm -rf "$USER_HOME/Library/Containers/com.microsoft.Excel" 2>/dev/null || true
  rm -rf "$USER_HOME/Library/Containers/com.microsoft.Powerpoint" 2>/dev/null || true
  rm -rf "$USER_HOME/Library/Containers/com.microsoft.Outlook" 2>/dev/null || true
  rm -rf "$USER_HOME/Library/Containers/com.microsoft.onenote.mac" 2>/dev/null || true
  rm -rf "$USER_HOME/Library/Group Containers/UBF8T346G9.Office" 2>/dev/null || true
  rm -rf "$USER_HOME/Library/Group Containers/UBF8T346G9.ms" 2>/dev/null || true
done

# Remove LaunchAgents/LaunchDaemons
rm -f /Library/LaunchDaemons/com.microsoft.office.* 2>/dev/null || true
rm -f /Library/LaunchDaemons/com.microsoft.autoupdate.* 2>/dev/null || true
for USER_HOME in /Users/*; do
  rm -f "$USER_HOME/Library/LaunchAgents/com.microsoft."* 2>/dev/null || true
done

# Forget pkg receipts
for receipt in $(pkgutil --pkgs 2>/dev/null | grep -i "com.microsoft.office\|com.microsoft.package" || true); do
  pkgutil --forget "$receipt" 2>/dev/null || true
  log "Forgot pkg receipt: $receipt"
done

if is_office_installed; then
  fail "Some Microsoft Office apps are still present after uninstall."
fi

log "SUCCESS: Microsoft Office has been uninstalled."
exit 0
