#!/bin/bash
set -euo pipefail

###############################################################################
# VLC Media Player Linux install (MDM Script)
# Version: 1.0
###############################################################################

### ====== CONFIG ==============================================================
LOG_FILE="/var/log/mdm-vlc-install.log"
### ===========================================================================

umask 077
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

log()  { echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] [VLC-Linux] $*"; }
fail() { log "ERROR: $*"; exit 1; }

[[ "$(id -u)" -eq 0 ]] || fail "Must run as root."

log "Starting VLC Linux install."

if command -v apt-get &>/dev/null; then
  PKG_MANAGER="apt"
elif command -v dnf &>/dev/null; then
  PKG_MANAGER="dnf"
elif command -v yum &>/dev/null; then
  PKG_MANAGER="yum"
else
  fail "Unsupported Linux distribution."
fi

log "Installing VLC via ${PKG_MANAGER}..."

case "$PKG_MANAGER" in
  apt)
    DEBIAN_FRONTEND=noninteractive apt-get update -y
    DEBIAN_FRONTEND=noninteractive apt-get install -y vlc || fail "apt install failed."
    ;;
  dnf)
    dnf install -y vlc || fail "dnf install failed."
    ;;
  yum)
    yum install -y epel-release || true
    yum install -y vlc || fail "yum install failed."
    ;;
esac

log "SUCCESS: VLC Media Player installed on Linux."
exit 0
