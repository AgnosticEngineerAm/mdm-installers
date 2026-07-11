#!/usr/bin/env python3
import os
import json
from datetime import datetime, timezone

def generate_catalog(repo_root):
    catalog = {
        "name": "MDM Installers Catalog",
        "version": "1.3.0",
        "last_updated": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "tools": []
    }

    # Find all tools by looking at docs directory
    tools = [d for d in os.listdir(os.path.join(repo_root, "docs")) 
             if os.path.isdir(os.path.join(repo_root, "docs", d)) and d not in ("guides", "migrations", "rippling")]

    for tool in tools:
        # Check platforms
        for os_name in ["macos", "windows", "linux"]:
            tool_entry = {
                "id": tool,
                "name": tool.replace("-", " ").title(),
                "os": os_name
            }
            
            # Check for install script
            script_ext = "sh" if os_name in ["macos", "linux"] else "ps1"
            install_path = f"scripts/{os_name}/{tool}/install.{script_ext}"
            if os.path.exists(os.path.join(repo_root, install_path)):
                tool_entry["install_script"] = install_path
            
            # Check for uninstall script
            uninstall_path = f"scripts/{os_name}/{tool}/uninstall.{script_ext}"
            if os.path.exists(os.path.join(repo_root, uninstall_path)):
                tool_entry["uninstall_script"] = uninstall_path
                
            # Check for documentation
            doc_path = f"docs/{tool}/README.md"
            if os.path.exists(os.path.join(repo_root, doc_path)):
                tool_entry["documentation"] = doc_path
                
            # Add if at least an install script exists
            if "install_script" in tool_entry:
                catalog["tools"].append(tool_entry)

    # Sort tools
    catalog["tools"] = sorted(catalog["tools"], key=lambda x: (x["id"], x["os"]))

    # Write catalog
    catalog_path = os.path.join(repo_root, "catalog.json")
    with open(catalog_path, 'w') as f:
        json.dump(catalog, f, indent=2)
        
    print(f"✅ Generated catalog.json with {len(catalog['tools'])} entries.")

if __name__ == "__main__":
    repo_root = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    generate_catalog(repo_root)
