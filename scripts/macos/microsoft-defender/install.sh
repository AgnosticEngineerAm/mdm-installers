#!/bin/bash
set -euo pipefail

###############################################################################
# Microsoft Defender for Endpoint — macOS install (MDM Script)
# Version: 1.0
# Tested on: macOS 13 Ventura, 14 Sonoma, 15 Sequoia (Intel + Apple Silicon)
#
# Prerequisites:
#   Deploy these profiles BEFORE running this script:
#   - profiles/macos/microsoft-defender/system-extension.mobileconfig
#   - profiles/macos/microsoft-defender/pppc.mobileconfig
#
# Onboarding package:
#   Microsoft Defender for Endpoint also requires an onboarding package
#   (WindowsDefenderATPOnboardingPackage.zip) from the Microsoft 365 Defender
#   portal. Deploy the onboarding .pkg as a separate policy item or include
#   it in your MDM's app catalog.
###############################################################################

### ====== CONFIG ==============================================================
DEFENDER_PKG_URL="PASTE_YOUR_MDE_PKG_URL_HERE"
# Download from: https://aka.ms/mdatpmac (latest) or your specific version URL

# Optional integrity check
EXPECTED_SHA256=""
EXPECTED_TEAM_ID="UBF8T346G9"   # Microsoft's Apple Developer Team ID

FORCE_REINSTALL="false"
LOG_FILE="/var/log/mdm-defender-install.log"
### ===========================================================================

umask 077
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

log()  { echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] [MicrosoftDefender] $*"; }
fail() { log "ERROR: $*"; exit 1; }
warn() { log "WARNING: $*"; }

[[ "$(id -u)" -eq 0 ]] || fail "Must run as root/admin."

log "Starting Microsoft Defender for Endpoint install."
log "macOS $(sw_vers -productVersion) | $(uname -m)"

MDATP="/usr/local/bin/mdatp"

is_defender_installed() {
  if [[ -x "$MDATP" ]] && "$MDATP" health 2>/dev/null | grep -q "healthy"; then return 0; fi
  if [[ -d "/Applications/Microsoft Defender.app" ]]; then return 0; fi
  if pkgutil --pkgs 2>/dev/null | grep -qi "microsoft.*defender"; then return 0; fi
  return 1
}

if [[ "$FORCE_REINSTALL" != "true" ]] && is_defender_installed; then
  log "SKIP: Microsoft Defender already installed and healthy. No action taken."
  exit 0
fi

# ── Temp dir setup ────────────────────────────────────────────────────────────
TMP_DIR="$(mktemp -d)"
PKG_PATH="$TMP_DIR/MicrosoftDefender.pkg"
trap 'rm -rf "$TMP_DIR" 2>/dev/null || true' EXIT

# ── Download ─────────────────────────────────────────────────────────────────
log "Downloading Microsoft Defender for Endpoint PKG..."
curl -fLsS --retry 3 --retry-delay 2 --connect-timeout 15 --max-time 900 \
  -o "$PKG_PATH" "$DEFENDER_PKG_URL" \
  || fail "Download failed. Check DEFENDER_PKG_URL."

# ── Format validation ─────────────────────────────────────────────────────────
if ! file "$PKG_PATH" | grep -qi "xar archive"; then
  log "File type: $(file "$PKG_PATH")"
  fail "Downloaded file is not a valid .pkg (XAR archive)."
fi

# ── Checksum verification ─────────────────────────────────────────────────────
if [[ -n "$EXPECTED_SHA256" ]]; then
  ACTUAL="$(shasum -a 256 "$PKG_PATH" | awk '{print $1}')"
  [[ "$ACTUAL" == "$EXPECTED_SHA256" ]] || fail "SHA256 mismatch. Got: ${ACTUAL}"
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
log "Installing Microsoft Defender for Endpoint silently..."
/usr/sbin/installer -pkg "$PKG_PATH" -target / || fail "installer(8) failed."

# ── Wait for mdatp ────────────────────────────────────────────────────────────
log "Waiting for mdatp daemon to become available (up to 60s)..."
for _ in {1..30}; do
  [[ -x "$MDATP" ]] && break
  sleep 2
done

# ── Validate ──────────────────────────────────────────────────────────────────
if is_defender_installed; then
  log "SUCCESS: Microsoft Defender for Endpoint installed."
  log "NOTE: Onboarding requires deploying the onboarding .pkg from your M365 Defender portal."
  exit 0
fi

fail "Installation did not validate. Check ${LOG_FILE}."
