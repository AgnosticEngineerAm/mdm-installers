#!/bin/bash
set -euo pipefail

###############################################################################
# CrowdStrike Falcon macOS UNINSTALL (MDM Script)
# Version: 1.0
# Tested on: macOS 13 Ventura, 14 Sonoma, 15 Sequoia
#
# IMPORTANT: Uninstalling CrowdStrike Falcon requires the maintenance token
# if "Uninstall Protection" is enabled in your Falcon console policy.
# Set CS_MAINTENANCE_TOKEN below or via your MDM's secret management.
###############################################################################

### ====== CONFIG ==============================================================
CS_MAINTENANCE_TOKEN=""   # Required if Uninstall Protection is ON in Falcon policy
LOG_FILE="/var/log/mdm-crowdstrike-uninstall.log"
### ===========================================================================

umask 077
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

log()  { echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] [CrowdStrike-Uninstall] $*"; }
fail() { log "ERROR: $*"; exit 1; }

[[ "$(id -u)" -eq 0 ]] || fail "Must run as root/admin."

log "Starting CrowdStrike Falcon uninstall."
log "macOS $(sw_vers -productVersion) | $(uname -m)"

FALCONCTL="/Applications/Falcon.app/Contents/Resources/falconctl"

is_cs_installed() {
  [[ -d "/Applications/Falcon.app" ]] || pkgutil --pkgs 2>/dev/null | grep -qi "crowdstrike"
}

if ! is_cs_installed; then
  log "SKIP: CrowdStrike Falcon is not installed. No action taken."
  exit 0
fi

if [[ ! -x "$FALCONCTL" ]]; then
  fail "falconctl not found at ${FALCONCTL}. Cannot uninstall. Manual removal may be required."
fi

if [[ -n "$CS_MAINTENANCE_TOKEN" ]]; then
  log "Providing maintenance token for uninstall (token not logged)..."
  "$FALCONCTL" uninstall --maintenance-token "$CS_MAINTENANCE_TOKEN" \
    || fail "Uninstall with maintenance token failed."
else
  log "CS_MAINTENANCE_TOKEN not set — attempting uninstall without token."
  log "This will fail if 'Uninstall Protection' is enabled in your Falcon policy."
  "$FALCONCTL" uninstall \
    || fail "Uninstall failed. If Uninstall Protection is ON, set CS_MAINTENANCE_TOKEN."
fi

# Allow a few seconds for cleanup
sleep 3

if is_cs_installed; then
  fail "CrowdStrike Falcon still detected after uninstall. Manual cleanup may be needed."
fi

log "SUCCESS: CrowdStrike Falcon has been uninstalled."
exit 0
