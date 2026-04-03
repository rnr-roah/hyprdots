#!/usr/bin/env bash
# show-minimized.sh — Toggle the special:minimized overlay.

SPECIAL_WS="special:minimized"

MINIMIZED=$(hyprctl clients -j | jq -r --arg ws "$SPECIAL_WS" \
    '[.[] | select(.workspace.name == $ws)]')

COUNT=$(echo "$MINIMIZED" | jq 'length')

if [[ "$COUNT" -eq 0 ]]; then
    notify-send "No minimized windows" "Nothing to restore." -t 2000
    hyprctl dispatch submap reset
    exit 0
fi

CURRENT_SPECIAL=$(hyprctl activewindow -j | jq -r '.workspace.name')

if [[ "$CURRENT_SPECIAL" == "$SPECIAL_WS" ]]; then
    hyprctl dispatch togglespecialworkspace minimized
    hyprctl dispatch submap reset
    exit 0
fi

CURRENT_WS=$(hyprctl activewindow -j | jq -r '.workspace.id')
if [[ -z "$CURRENT_WS" || "$CURRENT_WS" == "null" ]]; then
    CURRENT_WS=$(hyprctl monitors -j | jq -r '.[0].activeWorkspace.id')
fi

echo "$CURRENT_WS" > /tmp/hypr_minimize_origin_ws
hyprctl dispatch togglespecialworkspace minimized
