#!/usr/bin/env bash
# window-name.sh — Clean window name for waybar

CLASS=$(hyprctl activewindow | grep 'class:' | awk '{print $2}')

if [[ -z "$CLASS" ]]; then
    echo ""
    exit 0
fi

# Handle Chrome web apps: chrome-claude.ai__-Default → Claude
if [[ "$CLASS" == chrome-* ]]; then
    NAME=$(echo "$CLASS" \
        | sed 's/^chrome-//' \
        | sed 's/__-Default$//' \
        | sed 's/__-Profile[0-9]*$//' \
        | awk -F'.' '{print $1}' \
        | sed 's/-/ /g' \
        | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2); print}')
    echo "$NAME"
else
    # Regular app — just capitalize first letter
    echo "$CLASS" | awk '{print toupper(substr($0,1,1)) substr($0,2)}'
fi
