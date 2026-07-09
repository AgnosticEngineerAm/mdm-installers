#!/bin/bash
set -euo pipefail

###############################################################################
# CrowdStrike Falcon macOS install (MDM Script)
# Version: 1.0
# Tested on: macOS 13 Ventura, 14 Sonoma, 15 Sequoia (Intel + Apple Silicon)
#
# Prerequisites:
#   Deploy these profiles BEFORE running this script:
#   - profiles/macos/crowdstrike/system-extension.mobileconfig
#   - profiles/macos/crowdstrike/network-extension.mobileconfig
#   - profiles/macos/crowdstrike/pppc.mobileconfig
###############################################################################

### ====== CONFIG ==============================================================
CS_PKG_URL="PASTE_YOUR_CROWDSTRIKE_PKG_URL_HERE"
CS_CUSTOMER_ID="PASTE_YOUR_CUSTOMER_ID_HERE"   # CID (with or without checksum hash)

# Optional integrity and signing checks (strongly recommended)
EXPECTED_SHA256=""       # sha256sum of the .pkg file
EXPECTED_TEAM_ID="X9E956P446"  # CrowdStrike's Apple Developer Team ID

FORCE_REINSTALL="false"
LOG_FILE="/var/log/mdm-crowdstrike-install.log"
### ===========================================================================

umask 077
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

log()  { echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] [CrowdStrike] $*"; }
fail() { log "ERROR: $*"; exit 1; }
warn() { log "WARNING: $*"; }

[[ "$(id -u)" -eq 0 ]] || fail "Must run as root/admin. Configure your MDM to run scripts as root."

log "Starting CrowdStrike Falcon install script."
log "macOS $(sw_vers -productVersion) | $(uname -m)"

FALCONCTL="/Applications/Falcon.app/Contents/Resources/falconctl"

is_cs_installed() {
  # Check multiple signals to avoid false negatives
  if [[ -x "$FALCONCTL" ]] && "$FALCONCTL" stats 2>/dev/null | grep -q "State"; then return 0; fi
  if [[ -d "/Applications/Falcon.app" ]]; then return 0; fi
  if pkgutil --pkgs 2>/dev/null | grep -qi "crowdstrike"; then return 0; fi
  if /bin/ls /Library/LaunchDaemons/ 2>/dev/null | grep -qi "falcon"; then return 0; fi
  return 1
}

if [[ "$FORCE_REINSTALL" != "true" ]] && is_cs_installed; then
  log "SKIP: CrowdStrike Falcon already installed. No action taken."
  exit 0
fi

# ── Temp dir setup ────────────────────────────────────────────────────────────
TMP_DIR="$(mktemp -d)"
PKG_PATH="$TMP_DIR/CrowdStrike.pkg"
trap 'rm -rf "$TMP_DIR" 2>/dev/null || true' EXIT

# ── Download ─────────────────────────────────────────────────────────────────
log "Downloading CrowdStrike Falcon PKG..."
curl -fLsS --retry 3 --retry-delay 2 --connect-timeout 15 --max-time 900 \
  -o "$PKG_PATH" "$CS_PKG_URL" \
  || fail "Download failed. Check CS_PKG_URL."

# ── Format validation ─────────────────────────────────────────────────────────
if ! file "$PKG_PATH" | grep -qi "xar archive"; then
  log "File type: $(file "$PKG_PATH")"
  fail "Downloaded file is not a valid .pkg (XAR archive). Check the URL."
fi

# ── Checksum verification ─────────────────────────────────────────────────────
if [[ -n "$EXPECTED_SHA256" ]]; then
  ACTUAL_SHA256="$(shasum -a 256 "$PKG_PATH" | awk '{print $1}')"
  [[ "$ACTUAL_SHA256" == "$EXPECTED_SHA256" ]] || fail "SHA256 mismatch. Got: ${ACTUAL_SHA256}"
  log "SHA256 verified."
else
  warn "EXPECTED_SHA256 not set; skipping checksum verification."
fi

# ── Signature verification ────────────────────────────────────────────────────
if [[ -n "$EXPECTED_TEAM_ID" ]]; then
  SIG_OUT="$(/usr/sbin/pkgutil --check-signature "$PKG_PATH" 2>/dev/null || true)"
  echo "$SIG_OUT" | grep -qi "Status: signed" || fail "PKG is not signed."
  echo "$SIG_OUT" | grep -q "$EXPECTED_TEAM_ID" || fail "Team ID mismatch (expected ${EXPECTED_TEAM_ID})."
  log "PKG signature verified (Team ID: ${EXPECTED_TEAM_ID})."
else
  warn "EXPECTED_TEAM_ID not set; skipping signature verification."
fi

# ── Install ────────────────────────────────────────────────────────────────────
log "Installing CrowdStrike Falcon silently..."
/usr/sbin/installer -pkg "$PKG_PATH" -target / || fail "installer(8) failed."

# ── Wait for falconctl to become available ────────────────────────────────────
log "Waiting for Falcon agent to initialize (up to 60s)..."
for _ in {1..30}; do
  [[ -x "$FALCONCTL" ]] && break
  sleep 2
done

# ── Provide CID (Customer ID) ─────────────────────────────────────────────────
if [[ -n "$CS_CUSTOMER_ID" ]] && [[ -x "$FALCONCTL" ]]; then
  log "Licensing agent with Customer ID (CID not logged)..."
  "$FALCONCTL" license "$CS_CUSTOMER_ID" > /dev/null 2>&1 \
    || warn "CID licensing step returned non-zero. Agent may self-license via MDM."
else
  warn "CS_CUSTOMER_ID not set or falconctl not found. Agent may not register correctly."
fi

# ── Validate ──────────────────────────────────────────────────────────────────
if is_cs_installed; then
  log "SUCCESS: CrowdStrike Falcon installed and detected as present."
  exit 0
fi

fail "Installation did not validate. Check ${LOG_FILE} and the Falcon console."
