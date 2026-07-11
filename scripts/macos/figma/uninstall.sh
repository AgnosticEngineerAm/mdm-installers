#!/bin/bash
set -euo pipefail

###############################################################################
# Figma macOS UNINSTALL (MDM Script)
# Version: 1.0
###############################################################################

### ====== CONFIG ==============================================================
LOG_FILE="/var/log/mdm-figma-uninstall.log"
### ===========================================================================

umask 077
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

log()  { echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] [Figma-Uninstall] $*"; }
fail() { log "ERROR: $*"; exit 1; }

[[ "$(id -u)" -eq 0 ]] || fail "Must run as root/admin."

log "Starting Figma uninstall."

is_figma_installed() {
  [[ -d "/Applications/Figma.app" ]]
}

if ! is_figma_installed; then
  log "SKIP: Figma is not installed."
  exit 0
fi

log "Stopping Figma processes..."
pkill -f "Figma" 2>/dev/null || true
sleep 2

log "Removing Figma application..."
rm -rf "/Applications/Figma.app" 2>/dev/null || true

log "Cleaning up Figma support files..."
for USER_HOME in /Users/*; do
  [[ -d "$USER_HOME" ]] || continue
  rm -rf "$USER_HOME/Library/Application Support/Figma" 2>/dev/null || true
  rm -rf "$USER_HOME/Library/Caches/com.figma.Desktop" 2>/dev/null || true
  rm -rf "$USER_HOME/Library/Preferences/com.figma.Desktop.plist" 2>/dev/null || true
  rm -rf "$USER_HOME/Library/Saved Application State/com.figma.Desktop.savedState" 2>/dev/null || true
done

if is_figma_installed; then
  fail "Figma still detected after uninstall."
fi

log "SUCCESS: Figma has been uninstalled."
exit 0
