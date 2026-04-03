#!/usr/bin/env bash
# toggle.sh — toggles center modules visibility

STATE_FILE="$HOME/.cache/center_expand_state"

if [[ ! -f "$STATE_FILE" ]]; then
    echo "hidden" > "$STATE_FILE"
fi

STATE=$(<"$STATE_FILE")

if [[ "$STATE" == "hidden" ]]; then
    echo "visible" > "$STATE_FILE"
else
    echo "hidden" > "$STATE_FILE"
fi

# Signal all center modules to refresh (signals 8-13)
for i in 8 9 10 11 12 13; do
    pkill -SIGRTMIN+$i waybar
done
