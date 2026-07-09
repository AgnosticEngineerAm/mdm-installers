#!/bin/bash
set -euo pipefail

###############################################################################
# CrowdStrike Falcon Linux install (MDM / remote management script)
# Version: 1.0
# Tested on: Ubuntu 20.04/22.04/24.04, RHEL/Rocky 8/9, Debian 11/12
###############################################################################

### ====== CONFIG ==============================================================
CS_INSTALLER_URL="PASTE_YOUR_CROWDSTRIKE_LINUX_INSTALLER_URL_HERE"
CS_CUSTOMER_ID="PASTE_YOUR_CUSTOMER_ID_HERE"

EXPECTED_SHA256=""

FORCE_REINSTALL="false"
LOG_FILE="/var/log/mdm-crowdstrike-install.log"
### ===========================================================================

umask 077
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

log()  { echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] [CrowdStrike-Linux] $*"; }
fail() { log "ERROR: $*"; exit 1; }
warn() { log "WARNING: $*"; }

[[ "$(id -u)" -eq 0 ]] || fail "Must run as root."

log "Starting CrowdStrike Falcon Linux install."
log "OS: $(grep PRETTY_NAME /etc/os-release 2>/dev/null | cut -d'"' -f2 || uname -a)"

if command -v apt-get &>/dev/null; then
  PKG_MANAGER="apt"; PKG_EXT="deb"
elif command -v dnf &>/dev/null; then
  PKG_MANAGER="dnf"; PKG_EXT="rpm"
elif command -v yum &>/dev/null; then
  PKG_MANAGER="yum"; PKG_EXT="rpm"
else
  fail "Unsupported Linux distribution."
fi

FALCONCTL="/opt/CrowdStrike/falconctl"

is_cs_installed() {
  [[ -x "$FALCONCTL" ]] && return 0
  if [[ "$PKG_MANAGER" == "apt" ]] && dpkg -l 2>/dev/null | grep -qi "falcon-sensor"; then return 0; fi
  if [[ "$PKG_MANAGER" != "apt" ]] && rpm -qa 2>/dev/null | grep -qi "falcon-sensor"; then return 0; fi
  return 1
}

if [[ "$FORCE_REINSTALL" != "true" ]] && is_cs_installed; then
  log "SKIP: CrowdStrike Falcon already installed."
  exit 0
fi

TMP_DIR="$(mktemp -d)"
PKG_PATH="$TMP_DIR/crowdstrike.${PKG_EXT}"
trap 'rm -rf "$TMP_DIR" 2>/dev/null || true' EXIT

log "Downloading CrowdStrike Falcon Linux package..."
curl -fLsS --retry 3 --retry-delay 2 --connect-timeout 15 --max-time 900 \
  -o "$PKG_PATH" "$CS_INSTALLER_URL" \
  || fail "Download failed."

if [[ -n "$EXPECTED_SHA256" ]]; then
  ACTUAL="$(sha256sum "$PKG_PATH" | awk '{print $1}')"
  [[ "$ACTUAL" == "$EXPECTED_SHA256" ]] || fail "SHA256 mismatch. Got: ${ACTUAL}"
  log "SHA256 verified."
fi

log "Installing CrowdStrike Falcon..."
case "$PKG_MANAGER" in
  apt)  DEBIAN_FRONTEND=noninteractive apt-get install -y "$PKG_PATH" || fail "apt install failed." ;;
  dnf)  dnf install -y "$PKG_PATH" || fail "dnf install failed." ;;
  yum)  yum install -y "$PKG_PATH" || fail "yum install failed." ;;
esac

for _ in {1..30}; do
  [[ -x "$FALCONCTL" ]] && break
  sleep 2
done

if [[ -n "$CS_CUSTOMER_ID" ]] && [[ -x "$FALCONCTL" ]]; then
  log "Setting CID (not logged)..."
  "$FALCONCTL" -s --cid="$CS_CUSTOMER_ID" || warn "CID set returned non-zero."
  systemctl start falcon-sensor 2>/dev/null || service falcon-sensor start 2>/dev/null || true
fi

if is_cs_installed; then
  log "SUCCESS: CrowdStrike Falcon installed on Linux."
  exit 0
fi

fail "Installation did not validate. Check ${LOG_FILE}."
