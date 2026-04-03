#!/usr/bin/env bash
# minimize.sh — Send focused window to special:minimized workspace silently
# Bind to: SUPER+M

ACTIVE=$(hyprctl activewindow -j)
ADDRESS=$(echo "$ACTIVE" | jq -r '.address')

if [[ -z "$ADDRESS" || "$ADDRESS" == "null" ]]; then
    echo "No active window found."
    exit 1
fi

# Move to special:minimized without switching workspace
hyprctl dispatch movetoworkspacesilent "special:minimized,address:$ADDRESS"
