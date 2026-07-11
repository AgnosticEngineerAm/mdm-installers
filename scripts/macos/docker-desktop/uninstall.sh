#!/bin/bash
set -euo pipefail

###############################################################################
# Docker Desktop macOS UNINSTALL (MDM Script)
# Version: 1.0
# Tested on: macOS 13 Ventura, 14 Sonoma, 15 Sequoia (Intel + Apple Silicon)
#
# Removes Docker Desktop, Docker CLI symlinks, containers, images, and volumes.
# WARNING: All local containers, images, and volumes will be destroyed.
###############################################################################

### ====== CONFIG ==============================================================
LOG_FILE="/var/log/mdm-docker-uninstall.log"
### ===========================================================================

umask 077
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

log()  { echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] [DockerDesktop-Uninstall] $*"; }
fail() { log "ERROR: $*"; exit 1; }

[[ "$(id -u)" -eq 0 ]] || fail "Must run as root/admin."

log "Starting Docker Desktop uninstall."
log "macOS $(sw_vers -productVersion) | $(uname -m)"

is_docker_installed() {
  [[ -d "/Applications/Docker.app" ]]
}

if ! is_docker_installed; then
  log "SKIP: Docker Desktop is not installed. No action taken."
  exit 0
fi

# Kill Docker processes
log "Stopping Docker processes..."
pkill -f "Docker" 2>/dev/null || true
sleep 3

# Remove the application
log "Removing Docker Desktop application..."
rm -rf "/Applications/Docker.app" 2>/dev/null || true

# Remove Docker CLI symlinks
rm -f /usr/local/bin/docker 2>/dev/null || true
rm -f /usr/local/bin/docker-compose 2>/dev/null || true
rm -f /usr/local/bin/docker-credential-desktop 2>/dev/null || true
rm -f /usr/local/bin/docker-credential-ecr-login 2>/dev/null || true
rm -f /usr/local/bin/docker-credential-osxkeychain 2>/dev/null || true
rm -f /usr/local/bin/kubectl 2>/dev/null || true
rm -f /usr/local/bin/com.docker.cli 2>/dev/null || true

# Remove user-level data for all users
log "Cleaning up Docker support files..."
for USER_HOME in /Users/*; do
  [[ -d "$USER_HOME" ]] || continue
  rm -rf "$USER_HOME/Library/Application Support/Docker Desktop" 2>/dev/null || true
  rm -rf "$USER_HOME/Library/Containers/com.docker.docker" 2>/dev/null || true
  rm -rf "$USER_HOME/Library/Group Containers/group.com.docker" 2>/dev/null || true
  rm -rf "$USER_HOME/Library/Preferences/com.docker.docker.plist" 2>/dev/null || true
  rm -rf "$USER_HOME/Library/Preferences/com.electron.docker-frontend.plist" 2>/dev/null || true
  rm -rf "$USER_HOME/Library/Caches/com.docker.docker" 2>/dev/null || true
  rm -rf "$USER_HOME/Library/Logs/Docker Desktop" 2>/dev/null || true
  rm -rf "$USER_HOME/.docker" 2>/dev/null || true
done

# Remove system-level Docker files
rm -rf /Library/PrivilegedHelperTools/com.docker.vmnetd 2>/dev/null || true
rm -f /Library/LaunchDaemons/com.docker.vmnetd.plist 2>/dev/null || true

if is_docker_installed; then
  fail "Docker Desktop still detected after uninstall. Manual cleanup may be required."
fi

log "SUCCESS: Docker Desktop has been uninstalled."
exit 0
