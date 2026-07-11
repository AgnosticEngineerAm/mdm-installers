#!/bin/bash
set -euo pipefail

###############################################################################
# Mozilla Firefox Linux install (MDM Script)
# Version: 1.0
###############################################################################

### ====== CONFIG ==============================================================
LOG_FILE="/var/log/mdm-firefox-install.log"
### ===========================================================================

umask 077
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

log()  { echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] [Firefox-Linux] $*"; }
fail() { log "ERROR: $*"; exit 1; }

[[ "$(id -u)" -eq 0 ]] || fail "Must run as root."

log "Starting Mozilla Firefox Linux install."

if command -v apt-get &>/dev/null; then
  PKG_MANAGER="apt"
elif command -v dnf &>/dev/null; then
  PKG_MANAGER="dnf"
elif command -v yum &>/dev/null; then
  PKG_MANAGER="yum"
else
  fail "Unsupported Linux distribution."
fi

log "Installing Firefox via ${PKG_MANAGER}..."

case "$PKG_MANAGER" in
  apt)
    # Ubuntu often uses snap for firefox, but apt install firefox works to trigger it
    DEBIAN_FRONTEND=noninteractive apt-get update -y
    DEBIAN_FRONTEND=noninteractive apt-get install -y firefox || fail "apt install failed."
    ;;
  dnf)
    dnf install -y firefox || fail "dnf install failed."
    ;;
  yum)
    yum install -y firefox || fail "yum install failed."
    ;;
esac

log "SUCCESS: Mozilla Firefox installed on Linux."
exit 0
