#!/bin/bash
set -euo pipefail

###############################################################################
# Notion macOS UNINSTALL (MDM Script)
# Version: 1.0
###############################################################################

### ====== CONFIG ==============================================================
LOG_FILE="/var/log/mdm-notion-uninstall.log"
### ===========================================================================

umask 077
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

log()  { echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] [Notion-Uninstall] $*"; }
fail() { log "ERROR: $*"; exit 1; }

[[ "$(id -u)" -eq 0 ]] || fail "Must run as root/admin."

log "Starting Notion uninstall."

is_notion_installed() {
  [[ -d "/Applications/Notion.app" ]]
}

if ! is_notion_installed; then
  log "SKIP: Notion is not installed."
  exit 0
fi

log "Stopping Notion processes..."
pkill -f "Notion" 2>/dev/null || true
sleep 2

log "Removing Notion application..."
rm -rf "/Applications/Notion.app" 2>/dev/null || true

log "Cleaning up Notion support files..."
for USER_HOME in /Users/*; do
  [[ -d "$USER_HOME" ]] || continue
  rm -rf "$USER_HOME/Library/Application Support/Notion" 2>/dev/null || true
  rm -rf "$USER_HOME/Library/Caches/notion.id" 2>/dev/null || true
  rm -rf "$USER_HOME/Library/Preferences/notion.id.plist" 2>/dev/null || true
  rm -rf "$USER_HOME/Library/Saved Application State/notion.id.savedState" 2>/dev/null || true
done

if is_notion_installed; then
  fail "Notion still detected after uninstall."
fi

log "SUCCESS: Notion has been uninstalled."
exit 0
