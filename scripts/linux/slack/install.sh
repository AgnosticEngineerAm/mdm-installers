#!/bin/bash
set -euo pipefail

###############################################################################
# Slack Linux install (MDM / remote management script)
# Version: 1.0
# Tested on: Ubuntu 20.04/22.04/24.04, RHEL/Rocky 8/9, Debian 11/12
#
# Slack provides .deb and .rpm packages for Linux. There is also a Snap
# package, but this script uses the native package for MDM compatibility.
# Supported package managers: apt (Debian/Ubuntu), dnf/yum (RHEL/Rocky/CentOS)
###############################################################################

### ====== CONFIG ==============================================================
# Download from: https://slack.com/downloads/linux
# Host the .deb or .rpm on your internal CDN and set the URL below.
SLACK_PKG_URL="PASTE_YOUR_SLACK_LINUX_PKG_URL_HERE"

# Optional integrity check
EXPECTED_SHA256=""

FORCE_REINSTALL="false"
LOG_FILE="/var/log/mdm-slack-install.log"
### ===========================================================================

umask 077
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

log()  { echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] [Slack-Linux] $*"; }
fail() { log "ERROR: $*"; exit 1; }
warn() { log "WARNING: $*"; }

[[ "$(id -u)" -eq 0 ]] || fail "Must run as root."

log "Starting Slack Linux install."
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

is_slack_installed() {
  if [[ "$PKG_MANAGER" == "apt" ]]; then
    dpkg -l 2>/dev/null | grep -qi "slack-desktop" && return 0
  else
    rpm -qa 2>/dev/null | grep -qi "slack" && return 0
  fi
  command -v slack &>/dev/null && return 0
  return 1
}

if [[ "$FORCE_REINSTALL" != "true" ]] && is_slack_installed; then
  log "SKIP: Slack already installed."
  exit 0
fi

# Validate config
if [[ "$SLACK_PKG_URL" == "PASTE_YOUR_SLACK_LINUX_PKG_URL_HERE" ]]; then
  fail "SLACK_PKG_URL has not been set. Edit the CONFIG block before deploying."
fi

TMP_DIR="$(mktemp -d)"
PKG_PATH="$TMP_DIR/slack.${PKG_EXT}"
trap 'rm -rf "$TMP_DIR" 2>/dev/null || true' EXIT

log "Downloading Slack Linux package (.${PKG_EXT})..."
curl -fLsS --retry 3 --retry-delay 2 --connect-timeout 15 --max-time 900 \
  -o "$PKG_PATH" "$SLACK_PKG_URL" \
  || fail "Download failed. Check SLACK_PKG_URL."

if [[ -n "$EXPECTED_SHA256" ]]; then
  ACTUAL="$(sha256sum "$PKG_PATH" | awk '{print $1}')"
  [[ "$ACTUAL" == "$EXPECTED_SHA256" ]] || fail "SHA256 mismatch. Got: ${ACTUAL}"
  log "SHA256 verified."
else
  warn "EXPECTED_SHA256 not set; skipping checksum verification."
fi

log "Installing Slack package silently..."
case "$PKG_MANAGER" in
  apt)
    DEBIAN_FRONTEND=noninteractive apt-get install -y -f "$PKG_PATH" \
      || fail "apt-get install failed."
    ;;
  dnf)
    dnf install -y "$PKG_PATH" || fail "dnf install failed."
    ;;
  yum)
    yum install -y "$PKG_PATH" || fail "yum install failed."
    ;;
esac

if is_slack_installed; then
  log "SUCCESS: Slack installed on Linux."
  exit 0
fi

fail "Installation did not validate. Check ${LOG_FILE}."
