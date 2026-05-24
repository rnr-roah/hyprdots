#!/usr/bin/env bash

DEVICE="at-translated-set-2-keyboard"
STATE_FILE="/tmp/laptop-keyboard-disabled"

if [ -f "$STATE_FILE" ]; then
    hyprctl keyword "device[at-translated-set-2-keyboard]:enabled" true
    rm "$STATE_FILE"
    notify-send "Laptop keyboard enabled"
else
    hyprctl keyword "device[at-translated-set-2-keyboard]:enabled" false
    touch "$STATE_FILE"
    notify-send "Laptop keyboard disabled"
fi
