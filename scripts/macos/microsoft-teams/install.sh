#!/bin/bash
set -euo pipefail

###############################################################################
# Microsoft Teams macOS install (MDM Script)
# Version: 1.0
# Tested on: macOS 13 Ventura, 14 Sonoma, 15 Sequoia (Intel + Apple Silicon)
# Note: This installs the "New Teams" client (Enterprise).
###############################################################################

### ====== CONFIG ==============================================================
TEAMS_PKG_URL="https://statics.teams.cdn.office.net/production-osx/enterprise/webview2/lkg/MicrosoftTeams.pkg"

EXPECTED_SHA256=""
EXPECTED_TEAM_ID="UBF8T346G9"  # Microsoft Corporation

FORCE_REINSTALL="false"
LOG_FILE="/var/log/mdm-teams-install.log"
### ===========================================================================

umask 077
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

if [[ -f "$(dirname "$0")/../_lib/common.sh" ]]; then
  source "$(dirname "$0")/../_lib/common.sh"
else
  log()  { echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] [Teams] $*"; }
  fail() { log "ERROR: $*"; exit 1; }
  warn() { log "WARNING: $*"; }
fi

[[ "$(id -u)" -eq 0 ]] || fail "Must run as root/admin."

log "Starting Microsoft Teams install."
log "macOS $(sw_vers -productVersion) | $(uname -m)"

is_teams_installed() {
  [[ -d "/Applications/Microsoft Teams.app" ]] || [[ -d "/Applications/Microsoft Teams (work or school).app" ]]
}

if [[ "$FORCE_REINSTALL" != "true" ]] && is_teams_installed; then
  log "SKIP: Microsoft Teams already installed. No action taken."
  exit 0
fi

TMP_DIR="$(mktemp -d)"
PKG_PATH="$TMP_DIR/Teams.pkg"
trap 'rm -rf "$TMP_DIR" 2>/dev/null || true' EXIT

log "Downloading Microsoft Teams PKG..."
curl -fLsS --retry 3 --retry-delay 2 --connect-timeout 15 --max-time 900 \
  -o "$PKG_PATH" "$TEAMS_PKG_URL" \
  || fail "Download failed."

if ! file "$PKG_PATH" | grep -qi "xar archive"; then
  fail "Downloaded file is not a valid .pkg."
fi

if [[ -n "$EXPECTED_SHA256" ]]; then
  ACTUAL="$(shasum -a 256 "$PKG_PATH" | awk '{print $1}')"
  [[ "$ACTUAL" == "$EXPECTED_SHA256" ]] || fail "SHA256 mismatch."
fi

if [[ -n "$EXPECTED_TEAM_ID" ]]; then
  SIG_OUT="$(/usr/sbin/pkgutil --check-signature "$PKG_PATH" 2>/dev/null || true)"
  echo "$SIG_OUT" | grep -qi "Status: signed" || fail "PKG is not signed."
  echo "$SIG_OUT" | grep -q "$EXPECTED_TEAM_ID" || fail "Team ID mismatch."
fi

log "Installing Microsoft Teams silently..."
/usr/sbin/installer -pkg "$PKG_PATH" -target / || fail "installer(8) failed."

if is_teams_installed; then
  log "SUCCESS: Microsoft Teams installed."
  exit 0
fi

fail "Microsoft Teams installation did not validate."
