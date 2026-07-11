#!/bin/bash
set -euo pipefail

###############################################################################
# Microsoft Edge Linux install (MDM Script)
# Version: 1.0
###############################################################################

### ====== CONFIG ==============================================================
LOG_FILE="/var/log/mdm-edge-install.log"
### ===========================================================================

umask 077
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

log()  { echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] [Edge-Linux] $*"; }
fail() { log "ERROR: $*"; exit 1; }

[[ "$(id -u)" -eq 0 ]] || fail "Must run as root."

log "Starting Microsoft Edge Linux install."

if command -v apt-get &>/dev/null; then
  PKG_MANAGER="apt"
elif command -v dnf &>/dev/null; then
  PKG_MANAGER="dnf"
elif command -v yum &>/dev/null; then
  PKG_MANAGER="yum"
else
  fail "Unsupported Linux distribution."
fi

log "Adding Microsoft Repo and installing Edge via ${PKG_MANAGER}..."

case "$PKG_MANAGER" in
  apt)
    curl -fLsS https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/microsoft.gpg
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/edge stable main" > /etc/apt/sources.list.d/microsoft-edge-dev.list
    DEBIAN_FRONTEND=noninteractive apt-get update -y
    DEBIAN_FRONTEND=noninteractive apt-get install -y microsoft-edge-stable || fail "apt install failed."
    ;;
  dnf|yum)
    rpm --import https://packages.microsoft.com/keys/microsoft.asc
    cat <<EOF > /etc/yum.repos.d/microsoft-edge.repo
[microsoft-edge]
name=microsoft-edge
baseurl=https://packages.microsoft.com/yumrepos/edge
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF
    if [[ "$PKG_MANAGER" == "dnf" ]]; then
      dnf install -y microsoft-edge-stable || fail "dnf install failed."
    else
      yum install -y microsoft-edge-stable || fail "yum install failed."
    fi
    ;;
esac

log "SUCCESS: Microsoft Edge installed on Linux."
exit 0
