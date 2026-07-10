#!/usr/bin/env python3
import json
import os
import sys

def main():
    root_dir = os.path.join(os.path.dirname(__file__), "..", "..")
    apps_json_path = os.path.join(root_dir, "apps.json")

    if not os.path.exists(apps_json_path):
        print(f"Error: {apps_json_path} not found.")
        sys.exit(1)

    with open(apps_json_path, "r") as f:
        apps = json.load(f)

    for app in apps:
        app_id = app["id"]
        mac_url = app.get("macos_url", "")
        win_url = app.get("windows_url", "")
        
        # macOS
        mac_dir = os.path.join(root_dir, f"scripts/macos/{app_id}")
        os.makedirs(mac_dir, exist_ok=True)
        mac_script = os.path.join(mac_dir, "install.sh")
        
        if not os.path.exists(mac_script):
            content_mac = f"""#!/bin/bash
set -euo pipefail
# {app["name"]} Enterprise macOS MDM Install

PKG_URL="{mac_url}"
EXPECTED_SHA256=""

source "$(dirname "$0")/../_lib/common.sh"
log "Installing {app["name"]}..."

download_pkg "$PKG_URL" "$EXPECTED_SHA256"
install_pkg
log "SUCCESS: {app["name"]} installed."
"""
            with open(mac_script, "w") as f_mac:
                f_mac.write(content_mac)
            os.chmod(mac_script, 0o755)

        # Windows
        win_dir = os.path.join(root_dir, f"scripts/windows/{app_id}")
        os.makedirs(win_dir, exist_ok=True)
        win_script = os.path.join(win_dir, "install.ps1")
        
        if not os.path.exists(win_script):
            content_win = f"""<#
.SYNOPSIS
{app["name"]} Enterprise Windows MDM Install
#>
$MsiUrl = "{win_url}"
$ExpectedSha256 = ""

. "$PSScriptRoot\\..\\_lib\\common.ps1"
Write-Log "Installing {app["name"]}..."

$msiPath = Download-File -Url $MsiUrl -ExpectedSha256 $ExpectedSha256
Install-Msi -MsiPath $msiPath
Write-Log "SUCCESS: {app["name"]} installed."
"""
            with open(win_script, "w") as f_win:
                f_win.write(content_win)

    print(f"Generated scripts for {len(apps)} apps successfully.")

if __name__ == "__main__":
    main()
