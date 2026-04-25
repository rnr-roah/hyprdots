#!/bin/bash

STATE_FILE="/tmp/hypr_gaming_mode"

if [ -f "$STATE_FILE" ]; then
    # Gaming mode is ON, turn it off
    rm "$STATE_FILE"
    hyprctl dispatch submap reset
    notify-send -u critical "System" "OFF - Normal binds restored"
else
    # Gaming mode is OFF, turn it on
    touch "$STATE_FILE"
    hyprctl dispatch submap gaming
    notify-send -u critical "System" "ON - Hotkeys unbound"
fi
