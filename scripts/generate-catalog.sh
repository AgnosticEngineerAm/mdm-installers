#!/bin/bash
# Generates a JSON catalog of all available MDM scripts and profiles.
# This makes the repository machine-readable for automation pipelines
# or a future web frontend.

set -euo pipefail

cd "$(dirname "$0")/.."

OUTPUT_FILE="catalog.json"

echo "Generating MDM catalog..."

cat << 'EOF' > "$OUTPUT_FILE"
{
  "name": "MDM Installers Catalog",
  "version": "1.0.0",
  "last_updated": "$(date -u +'%Y-%m-%dT%H:%M:%SZ')",
  "tools": [
EOF

# Extract tools by scanning the directory structure
FIRST_TOOL=true

# Function to parse tools from a specific OS directory
parse_os() {
  local os=$1
  local os_dir="scripts/$os"
  
  if [[ -d "$os_dir" ]]; then
    for tool_dir in "$os_dir"/*; do
      if [[ -d "$tool_dir" ]] && [[ "$(basename "$tool_dir")" != "_lib" ]]; then
        local tool_name=$(basename "$tool_dir")
        
        if [ "$FIRST_TOOL" = true ]; then
          FIRST_TOOL=false
        else
          echo "    ," >> "$OUTPUT_FILE"
        fi
        
        echo "    {" >> "$OUTPUT_FILE"
        echo "      \"id\": \"$tool_name\"," >> "$OUTPUT_FILE"
        echo "      \"name\": \"$(echo "$tool_name" | awk -F'-' '{for(i=1;i<=NF;i++){$i=toupper(substr($i,1,1)) substr($i,2)}} 1' | sed 's/ / /g')\"," >> "$OUTPUT_FILE"
        echo "      \"os\": \"$os\"," >> "$OUTPUT_FILE"
        
        # Check for installation script
        if [[ -f "$tool_dir/install.sh" ]]; then
          echo "      \"install_script\": \"$tool_dir/install.sh\"," >> "$OUTPUT_FILE"
        elif [[ -f "$tool_dir/install.ps1" ]]; then
          echo "      \"install_script\": \"$tool_dir/install.ps1\"," >> "$OUTPUT_FILE"
        fi
        
        # Check for profiles (macOS)
        local profile_dir="profiles/macos/$tool_name"
        if [[ "$os" == "macos" ]] && [[ -d "$profile_dir" ]]; then
          echo "      \"profiles\": [" >> "$OUTPUT_FILE"
          local first_profile=true
          for profile in "$profile_dir"/*.mobileconfig; do
            if [[ -f "$profile" ]]; then
              if [ "$first_profile" = true ]; then
                first_profile=false
              else
                echo "        ," >> "$OUTPUT_FILE"
              fi
              echo "        \"$profile\"" >> "$OUTPUT_FILE"
            fi
          done
          echo "      ]," >> "$OUTPUT_FILE"
        fi
        
        # Check for docs
        if [[ -f "docs/$tool_name/$os.md" ]]; then
          echo "      \"documentation\": \"docs/$tool_name/$os.md\"" >> "$OUTPUT_FILE"
        else
          echo "      \"documentation\": null" >> "$OUTPUT_FILE"
        fi
        
        echo "    }" >> "$OUTPUT_FILE"
      fi
    done
  fi
}

parse_os "macos"
parse_os "windows"
parse_os "linux"

cat << 'EOF' >> "$OUTPUT_FILE"
  ]
}
EOF

# Update the timestamp dynamically (workaround for cat EOF)
sed -i.bak "s/\"\$(date.*)\"/\"$(date -u +'%Y-%m-%dT%H:%M:%SZ')\"/g" "$OUTPUT_FILE"
rm -f "$OUTPUT_FILE.bak"

echo "Catalog generated at $OUTPUT_FILE"
