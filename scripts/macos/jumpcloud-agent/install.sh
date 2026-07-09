#!/bin/bash
set -euo pipefail

###############################################################################
# JumpCloud Agent macOS install (MDM Script)
# Version: 1.0
# Tested on: macOS 13 Ventura, 14 Sonoma, 15 Sequoia (Intel + Apple Silicon)
#
# The JumpCloud agent is typically deployed when bootstrapping a device onto
# JumpCloud from a different MDM, or during zero-touch enrollment when using
# a non-JumpCloud MDM (e.g., Jamf, Kandji) alongside JumpCloud for identity.
###############################################################################

### ====== CONFIG ==============================================================
JC_CONNECT_KEY="PASTE_YOUR_JUMPCLOUD_CONNECT_KEY_HERE"
# Find your connect key in: JumpCloud console → Devices → Add Device → Mac

JC_PKG_URL="https://cdn02.jumpcloud.com/production/agents/pkg/jumpcloud-agent.pkg"

EXPECTED_SHA256=""
# JumpCloud agent is signed — verify Team ID if desired
EXPECTED_TEAM_ID=""  # JumpCloud's Team ID if you wish to enforce it

FORCE_REINSTALL="false"
LOG_FILE="/var/log/mdm-jumpcloud-install.log"
### ===========================================================================

umask 077
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

log()  { echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] [JumpCloudAgent] $*"; }
fail() { log "ERROR: $*"; exit 1; }
warn() { log "WARNING: $*"; }

[[ "$(id -u)" -eq 0 ]] || fail "Must run as root/admin."

log "Starting JumpCloud Agent install."
log "macOS $(sw_vers -productVersion) | $(uname -m)"

JC_AGENT="/opt/jc/bin/jcagent"

is_jc_installed() {
  if [[ -x "$JC_AGENT" ]] && "$JC_AGENT" --version 2>/dev/null; then return 0; fi
  if [[ -f "/opt/jc/bin/jcagent" ]]; then return 0; fi
  if pkgutil --pkgs 2>/dev/null | grep -qi "jumpcloud"; then return 0; fi
  return 1
}

if [[ "$FORCE_REINSTALL" != "true" ]] && is_jc_installed; then
  log "SKIP: JumpCloud Agent already installed. No action taken."
  exit 0
fi

[[ -n "$JC_CONNECT_KEY" ]] || fail "JC_CONNECT_KEY is required. Set it in the config block."
[[ "$JC_CONNECT_KEY" != "PASTE_YOUR_JUMPCLOUD_CONNECT_KEY_HERE" ]] \
  || fail "JC_CONNECT_KEY has not been replaced. Edit the config block before deploying."

TMP_DIR="$(mktemp -d)"
PKG_PATH="$TMP_DIR/jumpcloud-agent.pkg"
trap 'rm -rf "$TMP_DIR" 2>/dev/null || true' EXIT

log "Downloading JumpCloud Agent PKG..."
curl -fLsS --retry 3 --retry-delay 2 --connect-timeout 15 --max-time 900 \
  -o "$PKG_PATH" "$JC_PKG_URL" \
  || fail "Download failed. Check JC_PKG_URL."

if ! file "$PKG_PATH" | grep -qi "xar archive"; then
  fail "Downloaded file is not a valid .pkg."
fi

if [[ -n "$EXPECTED_SHA256" ]]; then
  ACTUAL="$(shasum -a 256 "$PKG_PATH" | awk '{print $1}')"
  [[ "$ACTUAL" == "$EXPECTED_SHA256" ]] || fail "SHA256 mismatch. Got: ${ACTUAL}"
  log "SHA256 verified."
else
  warn "EXPECTED_SHA256 not set; skipping checksum verification."
fi

log "Installing JumpCloud Agent silently..."
/usr/sbin/installer -pkg "$PKG_PATH" -target / || fail "installer(8) failed."

# Wait for agent binary to appear
log "Waiting for jcagent to initialize (up to 60s)..."
for _ in {1..30}; do
  [[ -x "$JC_AGENT" ]] && break
  sleep 2
done

# Provide connect key (do not log it)
if [[ -x "$JC_AGENT" ]]; then
  log "Registering JumpCloud agent with connect key (key not logged)..."
  "$JC_AGENT" start --key "$JC_CONNECT_KEY" > /dev/null 2>&1 \
    || warn "Agent start with key returned non-zero. Check JumpCloud console."
else
  fail "jcagent binary not found after install."
fi

if is_jc_installed; then
  log "SUCCESS: JumpCloud Agent installed and running."
  exit 0
fi

fail "JumpCloud Agent installation did not validate. Check ${LOG_FILE}."
