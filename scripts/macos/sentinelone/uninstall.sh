#!/bin/bash
set -euo pipefail

###############################################################################
# SentinelOne macOS UNINSTALL (MDM Script)
# Version: 1.0
# Tested on: macOS 13 Ventura, 14 Sonoma, 15 Sequoia
#
# IMPORTANT: SentinelOne Singularity requires an uninstall passphrase if
# agent self-protection is enabled. Set S1_PASSPHRASE below or via your
# MDM's secret management (never hardcode real values in production).
###############################################################################

### ====== CONFIG ==============================================================
S1_PASSPHRASE=""   # Uninstall passphrase — required if self-protection is ON
LOG_FILE="/var/log/mdm-sentinelone-uninstall.log"
### ===========================================================================

umask 077
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

log()  { echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] [SentinelOne-Uninstall] $*"; }
fail() { log "ERROR: $*"; exit 1; }

[[ "$(id -u)" -eq 0 ]] || fail "Must run as root/admin."

log "Starting SentinelOne uninstall."
log "macOS $(sw_vers -productVersion) | $(uname -m)"

SENTINELCTL="/usr/local/bin/sentinelctl"

is_s1_installed() {
  if [[ -x "$SENTINELCTL" ]]; then return 0; fi
  if [[ -d "/Applications/SentinelOne" ]]; then return 0; fi
  if pkgutil --pkgs 2>/dev/null | grep -Ei 'sentinelone|sentinel' > /dev/null 2>&1; then return 0; fi
  return 1
}

if ! is_s1_installed; then
  log "SKIP: SentinelOne is not installed. No action taken."
  exit 0
fi

if [[ ! -x "$SENTINELCTL" ]]; then
  fail "sentinelctl not found at ${SENTINELCTL}. Cannot proceed with standard uninstall."
fi

if [[ -n "$S1_PASSPHRASE" ]]; then
  log "Providing uninstall passphrase (passphrase not logged)..."
  echo "$S1_PASSPHRASE" | "$SENTINELCTL" uninstall --passphrase - \
    || fail "Uninstall with passphrase failed. Verify the passphrase in your S1 console."
else
  log "S1_PASSPHRASE not set — attempting uninstall without passphrase."
  log "This will fail if agent self-protection is enabled."
  "$SENTINELCTL" uninstall \
    || fail "Uninstall failed. If self-protection is ON, set S1_PASSPHRASE."
fi

sleep 3

if is_s1_installed; then
  fail "SentinelOne still detected after uninstall attempt. Manual cleanup may be required."
fi

log "SUCCESS: SentinelOne has been uninstalled."
exit 0
