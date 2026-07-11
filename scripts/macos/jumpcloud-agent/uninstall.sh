#!/bin/bash
set -euo pipefail

###############################################################################
# JumpCloud Agent macOS UNINSTALL (MDM Script)
# Version: 1.0
# Tested on: macOS 13 Ventura, 14 Sonoma, 15 Sequoia
#
# Removes the JumpCloud Agent and associated services.
# NOTE: Removing the agent will de-register the device from JumpCloud.
###############################################################################

### ====== CONFIG ==============================================================
LOG_FILE="/var/log/mdm-jumpcloud-uninstall.log"
### ===========================================================================

umask 077
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

log()  { echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] [JumpCloud-Uninstall] $*"; }
fail() { log "ERROR: $*"; exit 1; }

[[ "$(id -u)" -eq 0 ]] || fail "Must run as root/admin."

log "Starting JumpCloud Agent uninstall."
log "macOS $(sw_vers -productVersion) | $(uname -m)"

is_jc_installed() {
  [[ -d "/opt/jc" ]] || [[ -f "/opt/jc/bin/jcagent" ]]
}

if ! is_jc_installed; then
  log "SKIP: JumpCloud Agent is not installed. No action taken."
  exit 0
fi

# Stop the JumpCloud Agent service
log "Stopping JumpCloud Agent..."
launchctl unload /Library/LaunchDaemons/com.jumpcloud.darwin-agent.plist 2>/dev/null || true

# Remove LaunchDaemons
rm -f /Library/LaunchDaemons/com.jumpcloud.darwin-agent.plist 2>/dev/null || true

# Remove the JumpCloud directory
log "Removing JumpCloud Agent files..."
rm -rf /opt/jc 2>/dev/null || true

# Remove additional JumpCloud files
rm -f /var/run/jcagent.pid 2>/dev/null || true
rm -rf /var/log/jcagent.log 2>/dev/null || true

if is_jc_installed; then
  fail "JumpCloud Agent still detected after uninstall."
fi

log "SUCCESS: JumpCloud Agent has been uninstalled."
log "NOTE: The device will no longer be managed by JumpCloud. Remove it from the JumpCloud console."
exit 0
