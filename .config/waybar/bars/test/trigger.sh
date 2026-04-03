#!/usr/bin/env bash
# trigger.sh — the toggle button icon

STATE_FILE="$HOME/.cache/center_expand_state"

if [[ ! -f "$STATE_FILE" ]]; then
    echo "hidden" > "$STATE_FILE"
fi

STATE=$(<"$STATE_FILE")

if [[ "$STATE" == "hidden" ]]; then
    echo '{"text": "󰋙", "class": "hidden"}'
else
    echo '{"text": "󰋙", "class": "visible"}'
fi
