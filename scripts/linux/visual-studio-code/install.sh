#!/bin/bash
set -euo pipefail

###############################################################################
# Visual Studio Code Linux install (MDM Script)
# Version: 1.0
###############################################################################

### ====== CONFIG ==============================================================
LOG_FILE="/var/log/mdm-vscode-install.log"
### ===========================================================================

umask 077
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

log()  { echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] [VSCode-Linux] $*"; }
fail() { log "ERROR: $*"; exit 1; }

[[ "$(id -u)" -eq 0 ]] || fail "Must run as root."

log "Starting Visual Studio Code Linux install."

if command -v apt-get &>/dev/null; then
  PKG_MANAGER="apt"
elif command -v dnf &>/dev/null; then
  PKG_MANAGER="dnf"
elif command -v yum &>/dev/null; then
  PKG_MANAGER="yum"
else
  fail "Unsupported Linux distribution."
fi

log "Adding Microsoft Repo and installing VS Code via ${PKG_MANAGER}..."

case "$PKG_MANAGER" in
  apt)
    curl -fLsS https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/microsoft.gpg
    echo "deb [arch=amd64,arm64,armhf] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list
    DEBIAN_FRONTEND=noninteractive apt-get update -y
    DEBIAN_FRONTEND=noninteractive apt-get install -y code || fail "apt install failed."
    ;;
  dnf|yum)
    rpm --import https://packages.microsoft.com/keys/microsoft.asc
    cat <<EOF > /etc/yum.repos.d/vscode.repo
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF
    if [[ "$PKG_MANAGER" == "dnf" ]]; then
      dnf check-update || true
      dnf install -y code || fail "dnf install failed."
    else
      yum check-update || true
      yum install -y code || fail "yum install failed."
    fi
    ;;
esac

log "SUCCESS: Visual Studio Code installed on Linux."
exit 0
