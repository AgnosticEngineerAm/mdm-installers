#!/bin/bash
set -euo pipefail

###############################################################################
# SentinelOne Linux install (MDM / remote management script)
# Version: 1.0
# Tested on: Ubuntu 20.04/22.04/24.04, RHEL/Rocky 8/9, Debian 11/12
#
# Supported package managers: apt (Debian/Ubuntu), yum/dnf (RHEL/Rocky/CentOS)
###############################################################################

### ====== CONFIG ==============================================================
S1_PKG_URL="PASTE_YOUR_SENTINELONE_LINUX_PKG_URL_HERE"
S1_SITE_TOKEN="PASTE_YOUR_SITE_TOKEN_HERE"

# Optional integrity check
EXPECTED_SHA256=""

FORCE_REINSTALL="false"
LOG_FILE="/var/log/mdm-sentinelone-install.log"
### ===========================================================================

umask 077
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

log()  { echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] [SentinelOne-Linux] $*"; }
fail() { log "ERROR: $*"; exit 1; }
warn() { log "WARNING: $*"; }

[[ "$(id -u)" -eq 0 ]] || fail "Must run as root."

log "Starting SentinelOne Linux install."
log "OS: $(grep PRETTY_NAME /etc/os-release 2>/dev/null | cut -d'"' -f2 || uname -a)"
log "Arch: $(uname -m)"

# Detect package manager
if command -v apt-get &>/dev/null; then
  PKG_MANAGER="apt"
  PKG_EXT="deb"
elif command -v dnf &>/dev/null; then
  PKG_MANAGER="dnf"
  PKG_EXT="rpm"
elif command -v yum &>/dev/null; then
  PKG_MANAGER="yum"
  PKG_EXT="rpm"
else
  fail "Unsupported Linux distribution. apt, dnf, or yum is required."
fi

log "Package manager: ${PKG_MANAGER}"

SENTINELCTL="/opt/sentinelone/bin/sentinelctl"

is_s1_installed() {
  if [[ -x "$SENTINELCTL" ]]; then return 0; fi
  if [[ "$PKG_MANAGER" == "apt" ]] && dpkg -l 2>/dev/null | grep -qi "sentinelone"; then return 0; fi
  if [[ "$PKG_MANAGER" != "apt" ]] && rpm -qa 2>/dev/null | grep -qi "sentinelone"; then return 0; fi
  return 1
}

if [[ "$FORCE_REINSTALL" != "true" ]] && is_s1_installed; then
  log "SKIP: SentinelOne already installed."
  exit 0
fi

TMP_DIR="$(mktemp -d)"
PKG_PATH="$TMP_DIR/sentinelone.${PKG_EXT}"
trap 'rm -rf "$TMP_DIR" 2>/dev/null || true' EXIT

log "Downloading SentinelOne Linux package (.${PKG_EXT})..."
curl -fLsS --retry 3 --retry-delay 2 --connect-timeout 15 --max-time 900 \
  -o "$PKG_PATH" "$S1_PKG_URL" \
  || fail "Download failed. Check S1_PKG_URL."

if [[ -n "$EXPECTED_SHA256" ]]; then
  ACTUAL="$(sha256sum "$PKG_PATH" | awk '{print $1}')"
  [[ "$ACTUAL" == "$EXPECTED_SHA256" ]] || fail "SHA256 mismatch. Got: ${ACTUAL}"
  log "SHA256 verified."
else
  warn "EXPECTED_SHA256 not set; skipping checksum verification."
fi

log "Installing SentinelOne package silently..."
case "$PKG_MANAGER" in
  apt)
    DEBIAN_FRONTEND=noninteractive apt-get install -y "$PKG_PATH" \
      || fail "apt-get install failed."
    ;;
  dnf)
    dnf install -y "$PKG_PATH" || fail "dnf install failed."
    ;;
  yum)
    yum install -y "$PKG_PATH" || fail "yum install failed."
    ;;
esac

# Wait for sentinelctl
for _ in {1..30}; do
  [[ -x "$SENTINELCTL" ]] && break
  sleep 2
done

if [[ -n "$S1_SITE_TOKEN" ]] && [[ -x "$SENTINELCTL" ]]; then
  log "Registering SentinelOne agent (token not logged)..."
  "$SENTINELCTL" management token set "$S1_SITE_TOKEN" > /dev/null 2>&1 \
    || warn "Token registration returned non-zero. Check the S1 console."
  "$SENTINELCTL" control start > /dev/null 2>&1 || warn "Agent start returned non-zero."
else
  warn "S1_SITE_TOKEN not set or sentinelctl not available."
fi

if is_s1_installed; then
  log "SUCCESS: SentinelOne installed on Linux."
  exit 0
fi

fail "Installation did not validate. Check ${LOG_FILE}."
