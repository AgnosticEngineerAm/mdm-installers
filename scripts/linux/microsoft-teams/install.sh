#!/bin/bash
set -euo pipefail

###############################################################################
# Microsoft Teams Linux install (MDM Script)
# Version: 1.0
###############################################################################

### ====== CONFIG ==============================================================
LOG_FILE="/var/log/mdm-teams-install.log"
### ===========================================================================

umask 077
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

log()  { echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] [Teams-Linux] $*"; }
fail() { log "ERROR: $*"; exit 1; }

[[ "$(id -u)" -eq 0 ]] || fail "Must run as root."

log "Starting Microsoft Teams Linux install."

if command -v apt-get &>/dev/null; then
  PKG_MANAGER="apt"
elif command -v dnf &>/dev/null; then
  PKG_MANAGER="dnf"
elif command -v yum &>/dev/null; then
  PKG_MANAGER="yum"
else
  fail "Unsupported Linux distribution."
fi

log "Adding Microsoft Repo and installing Teams via ${PKG_MANAGER}..."

case "$PKG_MANAGER" in
  apt)
    curl -fLsS https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/microsoft.gpg
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/ms-teams stable main" > /etc/apt/sources.list.d/teams.list
    DEBIAN_FRONTEND=noninteractive apt-get update -y
    DEBIAN_FRONTEND=noninteractive apt-get install -y teams || fail "apt install failed. Note: MS deprecated the Teams Linux client."
    ;;
  dnf|yum)
    rpm --import https://packages.microsoft.com/keys/microsoft.asc
    cat <<EOF > /etc/yum.repos.d/teams.repo
[teams]
name=teams
baseurl=https://packages.microsoft.com/yumrepos/ms-teams
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF
    if [[ "$PKG_MANAGER" == "dnf" ]]; then
      dnf install -y teams || fail "dnf install failed."
    else
      yum install -y teams || fail "yum install failed."
    fi
    ;;
esac

log "SUCCESS: Microsoft Teams installed on Linux."
exit 0
