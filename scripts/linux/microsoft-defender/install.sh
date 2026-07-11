#!/bin/bash
set -euo pipefail

###############################################################################
# Microsoft Defender for Endpoint Linux install (MDM / remote management)
# Version: 1.0
# Tested on: Ubuntu 20.04/22.04/24.04, RHEL/Rocky 8/9, Debian 11/12
#
# Microsoft provides Defender for Endpoint (MDE) via their Linux package
# repository. This script adds the Microsoft repo and installs MDE.
# Supported package managers: apt (Debian/Ubuntu), dnf/yum (RHEL/Rocky/CentOS)
###############################################################################

### ====== CONFIG ==============================================================
# Onboarding JSON blob path — download from the Defender Security Center:
# Settings → Endpoints → Onboarding → Select "Linux Server"
MDE_ONBOARDING_JSON_URL=""   # URL to your mdatp_onboard.json file

FORCE_REINSTALL="false"
LOG_FILE="/var/log/mdm-defender-install.log"
### ===========================================================================

umask 077
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

log()  { echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] [Defender-Linux] $*"; }
fail() { log "ERROR: $*"; exit 1; }
warn() { log "WARNING: $*"; }

[[ "$(id -u)" -eq 0 ]] || fail "Must run as root."

log "Starting Microsoft Defender for Endpoint Linux install."
log "OS: $(grep PRETTY_NAME /etc/os-release 2>/dev/null | cut -d'"' -f2 || uname -a)"
log "Arch: $(uname -m)"

# Detect package manager and distro
if command -v apt-get &>/dev/null; then
  PKG_MANAGER="apt"
elif command -v dnf &>/dev/null; then
  PKG_MANAGER="dnf"
elif command -v yum &>/dev/null; then
  PKG_MANAGER="yum"
else
  fail "Unsupported Linux distribution. apt, dnf, or yum is required."
fi

log "Package manager: ${PKG_MANAGER}"

is_mde_installed() {
  command -v mdatp &>/dev/null
}

if [[ "$FORCE_REINSTALL" != "true" ]] && is_mde_installed; then
  MDE_VERSION=$(mdatp version 2>/dev/null || echo "unknown")
  log "SKIP: Microsoft Defender already installed (${MDE_VERSION})."
  exit 0
fi

# Detect distro details for repo setup
DISTRO_ID="$(grep ^ID= /etc/os-release 2>/dev/null | cut -d'=' -f2 | tr -d '"' || echo "unknown")"
DISTRO_VERSION="$(grep ^VERSION_ID= /etc/os-release 2>/dev/null | cut -d'=' -f2 | tr -d '"' || echo "unknown")"

log "Distro: ${DISTRO_ID} ${DISTRO_VERSION}"

# Add Microsoft repository and install
case "$PKG_MANAGER" in
  apt)
    log "Adding Microsoft APT repository..."
    apt-get install -y curl apt-transport-https gnupg2 2>/dev/null || true

    curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft-archive-keyring.gpg 2>/dev/null \
      || fail "Failed to add Microsoft GPG key."

    # Determine the correct repo URL
    case "$DISTRO_ID" in
      ubuntu)
        REPO_URL="https://packages.microsoft.com/ubuntu/${DISTRO_VERSION}/prod"
        ;;
      debian)
        REPO_URL="https://packages.microsoft.com/debian/${DISTRO_VERSION}/prod"
        ;;
      *)
        REPO_URL="https://packages.microsoft.com/ubuntu/22.04/prod"
        warn "Unknown apt-based distro '${DISTRO_ID}'. Falling back to Ubuntu 22.04 repo."
        ;;
    esac

    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-archive-keyring.gpg] ${REPO_URL} main" \
      > /etc/apt/sources.list.d/microsoft-defender.list

    apt-get update -qq 2>/dev/null || true

    log "Installing mdatp package..."
    DEBIAN_FRONTEND=noninteractive apt-get install -y mdatp \
      || fail "apt-get install mdatp failed."
    ;;

  dnf|yum)
    log "Adding Microsoft YUM/DNF repository..."
    rpm --import https://packages.microsoft.com/keys/microsoft.asc 2>/dev/null \
      || fail "Failed to import Microsoft GPG key."

    # Determine the correct repo URL
    REPO_URL="https://packages.microsoft.com/rhel/${DISTRO_VERSION%%.*}/prod"

    cat > /etc/yum.repos.d/microsoft-defender.repo <<EOF
[microsoft-defender]
name=Microsoft Defender for Endpoint
baseurl=${REPO_URL}
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF

    log "Installing mdatp package..."
    $PKG_MANAGER install -y mdatp || fail "${PKG_MANAGER} install mdatp failed."
    ;;
esac

# Apply onboarding JSON if provided
if [[ -n "$MDE_ONBOARDING_JSON_URL" ]]; then
  ONBOARD_DIR="/etc/opt/microsoft/mdatp"
  mkdir -p "$ONBOARD_DIR"
  ONBOARD_PATH="$ONBOARD_DIR/mdatp_onboard.json"

  log "Downloading MDE onboarding JSON (token not logged)..."
  curl -fLsS --retry 3 --connect-timeout 15 --max-time 60 \
    -o "$ONBOARD_PATH" "$MDE_ONBOARDING_JSON_URL" \
    || fail "Failed to download onboarding JSON."
  chmod 600 "$ONBOARD_PATH"
  chown root:root "$ONBOARD_PATH"
  log "Onboarding JSON staged at ${ONBOARD_PATH}."
else
  warn "MDE_ONBOARDING_JSON_URL not set. Defender installed but NOT onboarded."
  warn "Set MDE_ONBOARDING_JSON_URL to your onboarding JSON for full MDE functionality."
fi

if is_mde_installed; then
  MDE_VERSION=$(mdatp version 2>/dev/null || echo "unknown")
  log "SUCCESS: Microsoft Defender for Endpoint installed on Linux (${MDE_VERSION})."
  exit 0
fi

fail "Installation did not validate. Check ${LOG_FILE}."
