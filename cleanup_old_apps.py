import json
import os
import shutil

valid_apps = {"_lib", "_tools", "microsoft-365-apps", "microsoft-defender", "slack", "zoom", "jumpcloud-agent", "docker-desktop", "microsoft-office", "google-chrome", "sentinelone", "crowdstrike", "1password"}

with open("apps.json", "r") as f:
    apps = json.load(f)
    for app in apps:
        valid_apps.add(app["id"])

for os_name in ["macos", "windows", "linux"]:
    dir_path = f"scripts/{os_name}"
    if not os.path.exists(dir_path): continue
    for folder in os.listdir(dir_path):
        folder_path = os.path.join(dir_path, folder)
        if os.path.isdir(folder_path) and folder not in valid_apps:
            print(f"Removing deprecated app directory: {folder_path}")
            shutil.rmtree(folder_path)
