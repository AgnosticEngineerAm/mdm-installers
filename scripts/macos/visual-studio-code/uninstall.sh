#!/bin/bash
set -euo pipefail

###############################################################################
# Visual Studio Code macOS UNINSTALL (MDM Script)
# Version: 1.0
###############################################################################

### ====== CONFIG ==============================================================
LOG_FILE="/var/log/mdm-vscode-uninstall.log"
### ===========================================================================

umask 077
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

log()  { echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] [VSCode-Uninstall] $*"; }
fail() { log "ERROR: $*"; exit 1; }

[[ "$(id -u)" -eq 0 ]] || fail "Must run as root/admin."

log "Starting Visual Studio Code uninstall."

is_vscode_installed() {
  [[ -d "/Applications/Visual Studio Code.app" ]]
}

if ! is_vscode_installed; then
  log "SKIP: VS Code is not installed."
  exit 0
fi

log "Stopping VS Code processes..."
pkill -f "Visual Studio Code" 2>/dev/null || true
sleep 2

log "Removing Visual Studio Code application..."
rm -rf "/Applications/Visual Studio Code.app" 2>/dev/null || true

log "Cleaning up VS Code support files..."
for USER_HOME in /Users/*; do
  [[ -d "$USER_HOME" ]] || continue
  rm -rf "$USER_HOME/Library/Application Support/Code" 2>/dev/null || true
  rm -rf "$USER_HOME/Library/Caches/com.microsoft.VSCode" 2>/dev/null || true
  rm -rf "$USER_HOME/Library/Caches/com.microsoft.VSCode.ShipIt" 2>/dev/null || true
  rm -rf "$USER_HOME/Library/Preferences/com.microsoft.VSCode.plist" 2>/dev/null || true
  rm -rf "$USER_HOME/.vscode" 2>/dev/null || true
done

if is_vscode_installed; then
  fail "VS Code still detected after uninstall."
fi

log "SUCCESS: VS Code has been uninstalled."
exit 0
