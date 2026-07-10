import json
import os

apps = []

real_apps = [
    "adobe-acrobat-reader", "adobe-creative-cloud", "adobe-photoshop", "adobe-illustrator", "adobe-xd",
    "autocad", "fusion360", "sketchup", "blender", "unity", "unreal-engine",
    "rstudio", "anaconda", "tableau", "powerbi", "alteryx", "sas", "spss",
    "postman", "insomnia", "soapui", "gitkraken", "sourcetree", "github-desktop",
    "visual-studio", "intellij-idea", "pycharm", "webstorm", "phpstorm", "rider",
    "sublime-text", "notepad-plus-plus", "vim", "emacs", "nano", "atom",
    "docker-desktop", "rancher-desktop", "podman-desktop", "kubernetes-cli", "helm",
    "aws-cli", "azure-cli", "google-cloud-sdk", "terraform", "ansible", "packer",
    "cisco-anyconnect", "paloalto-globalprotect", "forticlient", "tailscale", "zerotier", "cloudflare-warp",
    "bitwarden", "lastpass", "1password", "keeper", "dashlane",
    "vlc", "handbrake", "obs-studio", "audacity", "camtasia",
    "7-zip", "winrar", "keka", "the-unarchiver", "peazip",
    "slack", "discord", "microsoft-teams", "zoom", "webex", "ringcentral",
    "google-drive", "dropbox", "onedrive", "box-drive", "egnyte",
    "mozilla-firefox", "google-chrome", "microsoft-edge", "brave-browser", "opera", "vivaldi",
    "notion", "asana", "trello", "evernote", "todoist", "monday"
]

for app in real_apps:
    mac_url = "PASTE_YOUR_MAC_URL_FOR_" + app.upper().replace("-", "_") + "_HERE"
    win_url = "PASTE_YOUR_WIN_URL_FOR_" + app.upper().replace("-", "_") + "_HERE"
    apps.append({
        "id": app,
        "name": app.replace("-", " ").title(),
        "macos_url": mac_url,
        "windows_url": win_url
    })

for i in range(len(apps) + 1, 501):
    apps.append({
        "id": f"enterprise-app-{i:03d}",
        "name": f"Enterprise App {i:03d}",
        "macos_url": "PASTE_MAC_URL_HERE",
        "windows_url": "PASTE_WIN_URL_HERE"
    })

with open("apps.json", "w") as f:
    json.dump(apps, f, indent=2)

print(f"Generated apps.json with {len(apps)} apps")
