#!/usr/bin/env bash

STATE_FILE="/tmp/hypr_gaming_mode"

set_submap() {
    hyprctl dispatch "hl.dsp.submap(\"$1\")"
}

if [[ -f "$STATE_FILE" ]]; then
    rm "$STATE_FILE"
    set_submap "reset"
    notify-send -u critical "System" "OFF - Normal binds restored"
else
    touch "$STATE_FILE"
    set_submap "gaming"
    notify-send -u critical "System" "ON - Hotkeys unbound"
fi
