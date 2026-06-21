#!/bin/bash

# 1. Get the current workspace ID
current_workspace=$(hyprctl activeworkspace -j | jq -r '.id')

# 2. Get windows from workspace 10
# We pull address, class, and title
windows=$(hyprctl clients -j | jq -r '.[] | select(.workspace.id == 10) | "\(.address)|\(.class)|\(.title)"')

if [ -z "$windows" ]; then
    notify-send "No Windows" "Workspace 10 is empty"
    exit 0
fi

formatted_windows=""
declare -A window_map

while IFS='|' read -r address class title; do
    display_text="${title:-$class}"
    window_map["$display_text"]="$address"
    
    # --- DYNAMIC ICON MAPPING ---
    # Start with the default class
    icon_name="$class"

    # Check for common webapp patterns and map to personalized icons
    # Replace 'my-webapp-icon' with the actual name of your icon file (without .png/.svg)
    case "$class" in
        *"chrome-faol..."*) icon_name="google-chrome" ;; # Example: Map long ID to chrome
        *"brave-..."*)      icon_name="brave-browser" ;;
        # Add your specific webapp class names here:
        # "class-name-from-hyprctl") icon_name="your-custom-icon-name" ;;
    esac

    # If it's a Chrome/Brave webapp and we haven't mapped it yet, 
    # we can try to "guess" the icon name from the title or just use the browser icon
    if [[ "$icon_name" == *"chrome-"* ]]; then
        # Check if an icon exists that matches the title (lowercased, no spaces)
        clean_title=$(echo "$title" | tr '[:upper:]' '[:lower:]' | tr -d ' ')
        icon_name="google-chrome" # Default fallback
    fi
    # ----------------------------

    formatted_windows+="${display_text}\0icon\x1f${icon_name}\n"
done <<< "$windows"

# 3. Show rofi menu
# -en ensures the \0 and \x1f characters are interpreted correctly
selected=$(echo -en "$formatted_windows" | rofi -dmenu -i -show-icons -p "Restore Window:" -sep '\n')

if [ -z "$selected" ]; then
    exit 0
fi

# 4. Restore the window
window_address="${window_map[$selected]}"
if [ -n "$window_address" ]; then
    hyprctl dispatch movetoworkspacesilent "$current_workspace,address:$window_address"
    hyprctl dispatch focuswindow "address:$window_address"
fi
