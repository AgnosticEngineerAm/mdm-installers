#!/bin/bash
set -euo pipefail

###############################################################################
# Google Chrome Linux install (MDM / remote management script)
# Version: 1.0
# Tested on: Ubuntu 20.04/22.04/24.04, RHEL/Rocky 8/9, Debian 11/12
#
# Google provides a stable .deb and .rpm repository for Chrome. This script
# downloads the package directly. Alternatively, you can add the Google
# repository for automatic updates.
###############################################################################

### ====== CONFIG ==============================================================
# Google's direct download URLs:
# Debian/Ubuntu: https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
# RHEL/CentOS:   https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
CHROME_PKG_URL=""   # Auto-detected below if left empty

EXPECTED_SHA256=""

FORCE_REINSTALL="false"
LOG_FILE="/var/log/mdm-chrome-install.log"
### ===========================================================================

umask 077
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

log()  { echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] [Chrome-Linux] $*"; }
fail() { log "ERROR: $*"; exit 1; }
warn() { log "WARNING: $*"; }

[[ "$(id -u)" -eq 0 ]] || fail "Must run as root."

log "Starting Google Chrome Linux install."
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

# Auto-detect URL if not set
if [[ -z "$CHROME_PKG_URL" ]]; then
  if [[ "$PKG_EXT" == "deb" ]]; then
    CHROME_PKG_URL="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
  else
    CHROME_PKG_URL="https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm"
  fi
  log "Auto-detected Chrome URL for ${PKG_EXT}: ${CHROME_PKG_URL}"
fi

is_chrome_installed() {
  command -v google-chrome &>/dev/null || command -v google-chrome-stable &>/dev/null
}

if [[ "$FORCE_REINSTALL" != "true" ]] && is_chrome_installed; then
  INSTALLED_VERSION=$(google-chrome --version 2>/dev/null || google-chrome-stable --version 2>/dev/null || echo "unknown")
  log "SKIP: Google Chrome already installed (${INSTALLED_VERSION})."
  exit 0
fi

TMP_DIR="$(mktemp -d)"
PKG_PATH="$TMP_DIR/google-chrome.${PKG_EXT}"
trap 'rm -rf "$TMP_DIR" 2>/dev/null || true' EXIT

log "Downloading Google Chrome Linux package (.${PKG_EXT})..."
curl -fLsS --retry 3 --retry-delay 2 --connect-timeout 15 --max-time 900 \
  -o "$PKG_PATH" "$CHROME_PKG_URL" \
  || fail "Download failed. Check CHROME_PKG_URL."

if [[ -n "$EXPECTED_SHA256" ]]; then
  ACTUAL="$(sha256sum "$PKG_PATH" | awk '{print $1}')"
  [[ "$ACTUAL" == "$EXPECTED_SHA256" ]] || fail "SHA256 mismatch. Got: ${ACTUAL}"
  log "SHA256 verified."
else
  warn "EXPECTED_SHA256 not set; skipping checksum verification."
fi

log "Installing Google Chrome package silently..."
case "$PKG_MANAGER" in
  apt)
    # Install dependencies automatically
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

if is_chrome_installed; then
  INSTALLED_VERSION=$(google-chrome --version 2>/dev/null || google-chrome-stable --version 2>/dev/null || echo "unknown")
  log "SUCCESS: Google Chrome installed on Linux (${INSTALLED_VERSION})."
  exit 0
fi

fail "Installation did not validate. Check ${LOG_FILE}."
