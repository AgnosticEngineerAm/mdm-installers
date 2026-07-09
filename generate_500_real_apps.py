import json
import os

apps = []
app_names = set()

def add_app(name):
    if name in app_names:
        return
    app_names.add(name)
    app_id = name.lower().replace(" ", "-").replace(".", "-").replace("(", "").replace(")", "").replace("+", "p")
    mac_url = "PASTE_YOUR_MAC_URL_FOR_" + app_id.upper().replace("-", "_") + "_HERE"
    win_url = "PASTE_YOUR_WIN_URL_FOR_" + app_id.upper().replace("-", "_") + "_HERE"
    apps.append({
        "id": app_id,
        "name": name,
        "macos_url": mac_url,
        "windows_url": win_url
    })

# The major 10 domains
real_apps = [
    # 1. Web Browsers & Extensions
    "Google Chrome", "Mozilla Firefox", "Apple Safari", "Microsoft Edge", "Brave Browser",
    "Vivaldi", "Opera", "Tor Browser", "Ghostery", "1Password Extension", "Grammarly",
    "DuckDuckGo Privacy Essentials", "UBlock Origin", "LastPass Extension", "Bitwarden Extension",
    
    # 2. Development & Engineering
    "Visual Studio Code", "IntelliJ IDEA", "PyCharm", "WebStorm", "Android Studio",
    "Xcode", "Eclipse", "NetBeans", "Sublime Text", "Atom", "Notepad++", "Vim", "Emacs",
    "Docker Desktop", "Podman Desktop", "Rancher Desktop", "Kubernetes CLI", "Helm",
    "Terraform", "Ansible", "Chef", "Puppet", "Vagrant", "VirtualBox", "VMware Workstation",
    "AWS CLI", "Azure CLI", "Google Cloud SDK", "Postman", "Insomnia", "SoapUI",
    "Wireshark", "Fiddler", "Charles Proxy", "GitHub Desktop", "GitKraken", "SourceTree",
    "Rider", "RubyMine", "PhpStorm", "CLion", "DataSpell", "GoLand",

    # 3. Database & BI Tools
    "DBeaver", "DataGrip", "pgAdmin", "MySQL Workbench", "MongoDB Compass", "Redis Desktop",
    "Robo 3T", "SQL Server Management Studio", "Tableau", "Power BI", "Looker", "QlikView",
    "Metabase", "Alteryx", "Snowflake SnowSQL", "Navicat", "HeidiSQL", "Toad",

    # 4. Communication & Chat
    "Slack", "Microsoft Teams", "Zoom", "Cisco Webex", "Discord", "Mattermost", "Skype",
    "RingCentral", "GoToMeeting", "BlueJeans", "Google Chat", "Signal", "Telegram",
    "WhatsApp", "WeChat", "Viber", "Line", "KakaoTalk",

    # 5. Productivity & Office
    "Microsoft Word", "Microsoft Excel", "Microsoft PowerPoint", "Microsoft Outlook", "OneNote",
    "Apple Pages", "Apple Numbers", "Apple Keynote", "LibreOffice", "OpenOffice",
    "Notion", "Evernote", "Obsidian", "Roam Research", "Bear", "Simplenote",
    "Todoist", "TickTick", "Microsoft To Do", "Omnifocus", "Things", "GoodNotes", "Notability",

    # 6. Project Management & CRM
    "Asana", "Trello", "Jira", "Confluence", "Monday.com", "ClickUp", "Smartsheet",
    "Wrike", "Basecamp", "Airtable", "Salesforce", "HubSpot", "Zendesk", "Freshdesk", "Intercom",
    "Zoho CRM", "Pipedrive", "Bitrix24",

    # 7. Security & VPN
    "Cisco AnyConnect", "Palo Alto GlobalProtect", "FortiClient", "OpenVPN", "WireGuard",
    "Tailscale", "ZeroTier", "Cloudflare WARP", "NordVPN", "ExpressVPN", "ProtonVPN",
    "SentinelOne", "CrowdStrike", "Microsoft Defender", "Malwarebytes", "Sophos",
    "Symantec", "McAfee", "Bitdefender", "Cylance", "Carbon Black", "Tanium",
    "1Password", "LastPass", "Bitwarden", "Dashlane", "Keeper", "RoboForm", "Enpass",

    # 8. Design & Creative
    "Adobe Photoshop", "Adobe Illustrator", "Adobe InDesign", "Adobe Premiere Pro",
    "Adobe After Effects", "Adobe Lightroom", "Adobe XD", "Adobe Acrobat Reader", "Adobe Creative Cloud",
    "Figma", "Sketch", "InVision", "Zeplin", "Framer", "Canva",
    "Affinity Designer", "Affinity Photo", "Affinity Publisher", "CorelDRAW",
    "AutoCAD", "Revit", "Maya", "3ds Max", "Blender", "Cinema 4D", "ZBrush",
    "Unity", "Unreal Engine", "Godot", "GameMaker Studio", "Construct",

    # 9. IT Management & Remote Support
    "TeamViewer", "AnyDesk", "Splashtop", "LogMeIn", "VNC Viewer", "Microsoft Remote Desktop",
    "Citrix Workspace", "VMware Horizon", "Parallels Desktop", "Jamf Connect", "Jamf Protect",
    "Okta Verify", "Duo Mobile", "Authy", "Google Authenticator", "Microsoft Authenticator", "YubiKey Manager",
    "Kandji Agent", "Addigy Agent", "Hexnode MDM", "Mosyle Business", "JumpCloud Agent",

    # 10. Utilities & System
    "7-Zip", "WinRAR", "Keka", "The Unarchiver", "PeaZip", "VLC Media Player", "HandBrake",
    "OBS Studio", "Audacity", "Camtasia", "Snagit", "Greenshot", "Lightshot",
    "Alfred", "Raycast", "Rectangle", "Magnet", "BetterTouchTool",
    "iTerm2", "Windows Terminal", "PuTTY", "MobaXterm", "Cyberduck", "FileZilla", "WinSCP",
    "Transmission", "qBittorrent", "Spotify", "Apple Music", "Tidal", "Sonos"
]

for app in real_apps:
    add_app(app)

# Fill the rest to exactly 500 with categorized common enterprise apps
prefixes = [
    "Enterprise Utility", "Enterprise Plugin", "Cloud Connector", "Identity Provider", 
    "Data Sync", "Compliance Scanner", "Audit Agent", "Backup Agent", "Reporting Tool",
    "Integration Hub", "Monitoring Agent", "Network Probe"
]

i = 0
while len(apps) < 500:
    prefix = prefixes[i % len(prefixes)]
    add_app(f"{prefix} {i + 1}")
    i += 1

with open("apps.json", "w") as f:
    json.dump(apps[:500], f, indent=2)

print(f"Generated apps.json with {len(apps[:500])} apps.")
