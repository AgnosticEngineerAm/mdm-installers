#!/bin/bash
set -euo pipefail

###############################################################################
# Zoom Linux install (MDM / remote management script)
# Version: 1.0
# Tested on: Ubuntu 20.04/22.04/24.04, RHEL/Rocky 8/9, Debian 11/12
#
# Zoom provides platform-specific packages (.deb, .rpm) for Linux.
# Supported package managers: apt (Debian/Ubuntu), dnf/yum (RHEL/Rocky/CentOS)
###############################################################################

### ====== CONFIG ==============================================================
# Set the URL for your platform's package:
# Debian/Ubuntu: https://zoom.us/client/latest/zoom_amd64.deb
# RHEL/CentOS:   https://zoom.us/client/latest/zoom_x86_64.rpm
ZOOM_PKG_URL="PASTE_YOUR_ZOOM_LINUX_PKG_URL_HERE"

# Optional integrity check
EXPECTED_SHA256=""

FORCE_REINSTALL="false"
LOG_FILE="/var/log/mdm-zoom-install.log"
### ===========================================================================

umask 077
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

log()  { echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] [Zoom-Linux] $*"; }
fail() { log "ERROR: $*"; exit 1; }
warn() { log "WARNING: $*"; }

[[ "$(id -u)" -eq 0 ]] || fail "Must run as root."

log "Starting Zoom Linux install."
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

is_zoom_installed() {
  if [[ "$PKG_MANAGER" == "apt" ]]; then
    dpkg -l 2>/dev/null | grep -qi "zoom" && return 0
  else
    rpm -qa 2>/dev/null | grep -qi "zoom" && return 0
  fi
  command -v zoom &>/dev/null && return 0
  return 1
}

if [[ "$FORCE_REINSTALL" != "true" ]] && is_zoom_installed; then
  log "SKIP: Zoom already installed."
  exit 0
fi

# Validate config
if [[ "$ZOOM_PKG_URL" == "PASTE_YOUR_ZOOM_LINUX_PKG_URL_HERE" ]]; then
  fail "ZOOM_PKG_URL has not been set. Edit the CONFIG block before deploying."
fi

TMP_DIR="$(mktemp -d)"
PKG_PATH="$TMP_DIR/zoom.${PKG_EXT}"
trap 'rm -rf "$TMP_DIR" 2>/dev/null || true' EXIT

log "Downloading Zoom Linux package (.${PKG_EXT})..."
curl -fLsS --retry 3 --retry-delay 2 --connect-timeout 15 --max-time 900 \
  -o "$PKG_PATH" "$ZOOM_PKG_URL" \
  || fail "Download failed. Check ZOOM_PKG_URL."

if [[ -n "$EXPECTED_SHA256" ]]; then
  ACTUAL="$(sha256sum "$PKG_PATH" | awk '{print $1}')"
  [[ "$ACTUAL" == "$EXPECTED_SHA256" ]] || fail "SHA256 mismatch. Got: ${ACTUAL}"
  log "SHA256 verified."
else
  warn "EXPECTED_SHA256 not set; skipping checksum verification."
fi

log "Installing Zoom package silently..."
case "$PKG_MANAGER" in
  apt)
    # Install dependencies first
    apt-get update -qq 2>/dev/null || true
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

if is_zoom_installed; then
  log "SUCCESS: Zoom installed on Linux."
  exit 0
fi

fail "Installation did not validate. Check ${LOG_FILE}."
