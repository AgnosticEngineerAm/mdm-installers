#!/bin/bash
set -euo pipefail

###############################################################################
# JumpCloud Agent Linux install (MDM / remote management script)
# Version: 1.0
# Tested on: Ubuntu 20.04/22.04/24.04, RHEL/Rocky 8/9, Debian 11/12
###############################################################################

### ====== CONFIG ==============================================================
JC_CONNECT_KEY="PASTE_YOUR_JUMPCLOUD_CONNECT_KEY_HERE"
LOG_FILE="/var/log/mdm-jumpcloud-install.log"
### ===========================================================================

umask 077
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

log()  { echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] [JumpCloudAgent-Linux] $*"; }
fail() { log "ERROR: $*"; exit 1; }

[[ "$(id -u)" -eq 0 ]] || fail "Must run as root."

log "Starting JumpCloud Agent Linux install."
log "OS: $(grep PRETTY_NAME /etc/os-release 2>/dev/null | cut -d'"' -f2 || uname -a)"

[[ -n "$JC_CONNECT_KEY" ]] || fail "JC_CONNECT_KEY is required."
[[ "$JC_CONNECT_KEY" != "PASTE_YOUR_JUMPCLOUD_CONNECT_KEY_HERE" ]] \
  || fail "JC_CONNECT_KEY has not been replaced. Edit the config block."

JC_AGENT="/opt/jc/bin/jcagent"

if [[ -x "$JC_AGENT" ]]; then
  log "SKIP: JumpCloud Agent already installed."
  exit 0
fi

log "Downloading and running JumpCloud install script (key not logged)..."
# JumpCloud's official kickstart install script
curl -fLsS --retry 3 --connect-timeout 15 --max-time 300 \
  "https://kickstart.jumpcloud.com/Kickstart" \
  | bash -s -- --key "$JC_CONNECT_KEY" \
  || fail "JumpCloud install script failed."

if [[ -x "$JC_AGENT" ]]; then
  log "SUCCESS: JumpCloud Agent installed on Linux."
  exit 0
fi

fail "JumpCloud Agent installation did not validate. Check ${LOG_FILE}."
