#!/usr/bin/env bash
# restore-on-click.sh — Restores the focused window if it's in special:minimized.
# Triggered directly by a mouse bind in hyprland.conf (not a daemon).
# Add to hyprland.conf:
#   bind = , mouse:272, exec, ~/.config/hypr/scripts/restore-on-focus.sh

SPECIAL_WS="special:minimized"
ORIGIN_FILE="/tmp/hypr_minimize_origin_ws"

sleep 0.1
ACTIVE=$(hyprctl activewindow -j 2>/dev/null)
WS_NAME=$(echo "$ACTIVE" | jq -r '.workspace.name')

if [[ "$WS_NAME" != "$SPECIAL_WS" ]]; then
    exit 0
fi

ADDRESS=$(echo "$ACTIVE" | jq -r '.address')

if [[ -f "$ORIGIN_FILE" ]]; then
    TARGET_WS=$(cat "$ORIGIN_FILE")
else
    TARGET_WS=1
fi

hyprctl dispatch movetoworkspace "${TARGET_WS},address:${ADDRESS}"
hyprctl dispatch workspace "$TARGET_WS"
rm -f "$ORIGIN_FILE"
