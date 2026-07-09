#!/bin/bash
###############################################################################
# mdm-installers — Shared Library (macOS)
# Source this file at the top of any macOS install/uninstall script.
#
# Usage:
#   SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
#   # shellcheck source=../../_lib/common.sh
#   source "$SCRIPT_DIR/../../_lib/common.sh" 2>/dev/null || true
#
# NOTE: Many MDMs copy scripts to a temp location and cannot deploy this lib
# alongside the script. In that case, inline these functions directly into your
# script. This file exists for local dev/testing and for MDMs that support
# script bundle deployment (e.g., Jamf package-based scripts).
###############################################################################

### ── Logging ─────────────────────────────────────────────────────────────────

# log <message> — writes a UTC-timestamped line to stdout (captured by MDM)
log() {
  echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] $*"
}

# fail <message> — logs an error and exits 1
fail() {
  log "ERROR: $*"
  exit 1
}

# warn <message> — logs a warning without exiting
warn() {
  log "WARNING: $*"
}

### ── Root Check ───────────────────────────────────────────────────────────────

# require_root — exits 1 if not running as root
require_root() {
  [[ "$(id -u)" -eq 0 ]] || fail "Must run as root/admin. Configure your MDM to run scripts as root."
}

### ── Downloads ────────────────────────────────────────────────────────────────

# download_file <url> <dest_path> [label]
# Downloads a file with retry logic. Fails if download returns non-200.
download_file() {
  local url="$1"
  local dest="$2"
  local label="${3:-file}"

  log "Downloading ${label}..."
  curl \
    --fail \
    --location \
    --silent \
    --show-error \
    --retry 3 \
    --retry-delay 2 \
    --connect-timeout 15 \
    --max-time 900 \
    --output "$dest" \
    "$url" \
    || fail "Download failed for ${label}. URL: ${url}"
  log "Download complete: ${dest}"
}

### ── Integrity Verification ───────────────────────────────────────────────────

# verify_sha256 <file_path> <expected_sha256>
# Exits 1 if the checksum does not match.
verify_sha256() {
  local file="$1"
  local expected="$2"

  if [[ -z "$expected" ]]; then
    warn "EXPECTED_SHA256 not set; skipping checksum verification."
    return 0
  fi

  local actual
  actual="$(shasum -a 256 "$file" | awk '{print $1}')"
  if [[ "$actual" != "$expected" ]]; then
    fail "SHA256 mismatch. Expected: ${expected}  Got: ${actual}"
  fi
  log "SHA256 verified: ${actual}"
}

# verify_team_id <pkg_path> <expected_team_id>
# Exits 1 if the pkg signer Team ID does not match.
verify_team_id() {
  local pkg="$1"
  local expected_team="$2"

  if [[ -z "$expected_team" ]]; then
    warn "EXPECTED_TEAM_ID not set; skipping signature verification."
    return 0
  fi

  local sig_out
  sig_out="$(/usr/sbin/pkgutil --check-signature "$pkg" 2>/dev/null || true)"
  echo "$sig_out" | grep -qi "Status: signed" || fail "PKG does not appear signed: ${pkg}"
  echo "$sig_out" | grep -q "$expected_team" || fail "Signer Team ID mismatch. Expected: ${expected_team}"
  log "PKG signature verified (Team ID: ${expected_team})."
}

# verify_pkg_format <file_path>
# Exits 1 if the file is not a valid macOS .pkg (XAR archive).
verify_pkg_format() {
  local file="$1"
  if ! file "$file" | grep -qi "xar archive"; then
    log "Downloaded file type: $(file "$file")"
    fail "Downloaded file does not look like a macOS .pkg (XAR). Check the URL."
  fi
  log "PKG format verified (XAR)."
}

### ── Installation ─────────────────────────────────────────────────────────────

# install_pkg <pkg_path>
# Installs a .pkg silently to /. Exits 1 on failure.
install_pkg() {
  local pkg="$1"
  log "Installing PKG silently: ${pkg}"
  /usr/sbin/installer -pkg "$pkg" -target / || fail "installer(8) failed for: ${pkg}"
  log "PKG installation complete."
}

### ── Temp Directory ───────────────────────────────────────────────────────────

# make_temp_dir
# Creates a secure temp directory and sets TMP_DIR. Registers EXIT trap.
# Call this before any temp file operations.
make_temp_dir() {
  umask 077
  TMP_DIR="$(mktemp -d)"
  # shellcheck disable=SC2064
  trap "rm -rf '${TMP_DIR}' 2>/dev/null || true" EXIT
  log "Temp directory: ${TMP_DIR}"
}

### ── Platform Info ────────────────────────────────────────────────────────────

# get_macos_version
# Prints the macOS version string (e.g., "15.3.1")
get_macos_version() {
  sw_vers -productVersion
}

# get_arch
# Prints the CPU architecture: "arm64" or "x86_64"
get_arch() {
  uname -m
}

log "mdm-installers common library loaded. macOS $(get_macos_version) / $(get_arch)"
