#!/usr/bin/env bash
STATE_FILE="$HOME/.cache/drawer_state"

if [[ ! -f "$STATE_FILE" ]]; then
    echo "closed" > "$STATE_FILE"
fi

if [[ "$1" == "toggle" ]]; then
    STATE=$(<"$STATE_FILE")
    if [[ "$STATE" == "closed" ]]; then
        echo "open" > "$STATE_FILE"
    else
        echo "closed" > "$STATE_FILE"
    fi
    pkill -SIGRTMIN+8 waybar
    exit 0
fi

STATE=$(<"$STATE_FILE")
if [[ "$STATE" == "closed" ]]; then
    echo '{"text": "󰄽", "class": "closed"}'
else
    echo '{"text": "󰄾", "class": "open"}'
fi
