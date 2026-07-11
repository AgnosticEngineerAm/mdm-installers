#!/bin/bash
set -euo pipefail

###############################################################################
# Docker Desktop Linux install (MDM / remote management script)
# Version: 1.0
# Tested on: Ubuntu 22.04/24.04, Debian 12, Fedora 38/39/40
#
# Docker Desktop for Linux is distributed as a .deb or .rpm package.
# NOTE: Docker Desktop on Linux requires a GUI/desktop environment.
# For headless servers, use Docker Engine (docker-ce) instead.
###############################################################################

### ====== CONFIG ==============================================================
# Download from: https://docs.docker.com/desktop/install/linux/
# Debian/Ubuntu: https://desktop.docker.com/linux/main/amd64/docker-desktop-amd64.deb
# Fedora/RHEL:   https://desktop.docker.com/linux/main/amd64/docker-desktop-x86_64.rpm
DOCKER_PKG_URL=""   # Auto-detected below if left empty

EXPECTED_SHA256=""

FORCE_REINSTALL="false"
LOG_FILE="/var/log/mdm-docker-install.log"
### ===========================================================================

umask 077
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

log()  { echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] [DockerDesktop-Linux] $*"; }
fail() { log "ERROR: $*"; exit 1; }
warn() { log "WARNING: $*"; }

[[ "$(id -u)" -eq 0 ]] || fail "Must run as root."

log "Starting Docker Desktop Linux install."
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
if [[ -z "$DOCKER_PKG_URL" ]]; then
  if [[ "$PKG_EXT" == "deb" ]]; then
    DOCKER_PKG_URL="https://desktop.docker.com/linux/main/amd64/docker-desktop-amd64.deb"
  else
    DOCKER_PKG_URL="https://desktop.docker.com/linux/main/amd64/docker-desktop-x86_64.rpm"
  fi
  log "Auto-detected Docker URL for ${PKG_EXT}: ${DOCKER_PKG_URL}"
fi

is_docker_installed() {
  command -v docker &>/dev/null || [[ -d "/opt/docker-desktop" ]]
}

if [[ "$FORCE_REINSTALL" != "true" ]] && is_docker_installed; then
  DOCKER_VERSION=$(docker --version 2>/dev/null || echo "unknown")
  log "SKIP: Docker already installed (${DOCKER_VERSION})."
  exit 0
fi

# Install prerequisites
log "Installing prerequisites..."
case "$PKG_MANAGER" in
  apt)
    apt-get update -qq 2>/dev/null || true
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
      ca-certificates curl gnupg pass uidmap 2>/dev/null || true
    ;;
  dnf|yum)
    $PKG_MANAGER install -y ca-certificates curl gnupg2 pass 2>/dev/null || true
    ;;
esac

TMP_DIR="$(mktemp -d)"
PKG_PATH="$TMP_DIR/docker-desktop.${PKG_EXT}"
trap 'rm -rf "$TMP_DIR" 2>/dev/null || true' EXIT

log "Downloading Docker Desktop Linux package (.${PKG_EXT})..."
curl -fLsS --retry 3 --retry-delay 2 --connect-timeout 30 --max-time 1800 \
  -o "$PKG_PATH" "$DOCKER_PKG_URL" \
  || fail "Download failed. Check DOCKER_PKG_URL."

if [[ -n "$EXPECTED_SHA256" ]]; then
  ACTUAL="$(sha256sum "$PKG_PATH" | awk '{print $1}')"
  [[ "$ACTUAL" == "$EXPECTED_SHA256" ]] || fail "SHA256 mismatch. Got: ${ACTUAL}"
  log "SHA256 verified."
else
  warn "EXPECTED_SHA256 not set; skipping checksum verification."
fi

log "Installing Docker Desktop package silently..."
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

if is_docker_installed; then
  DOCKER_VERSION=$(docker --version 2>/dev/null || echo "unknown")
  log "SUCCESS: Docker Desktop installed on Linux (${DOCKER_VERSION})."
  log "NOTE: Docker Desktop requires a desktop environment. Users must launch it once to complete setup."
  exit 0
fi

fail "Installation did not validate. Check ${LOG_FILE}."
