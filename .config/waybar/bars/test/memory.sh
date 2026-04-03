#!/usr/bin/env bash
STATE_FILE="$HOME/.cache/center_expand_state"
[[ ! -f "$STATE_FILE" ]] && echo '{"text": ""}' && exit 0
STATE=$(<"$STATE_FILE")
[[ "$STATE" == "hidden" ]] && echo '{"text": ""}' && exit 0

USAGE=$(free | awk '/Mem:/ {printf "%d", $3/$2 * 100}')
echo "{\"text\": \"<span foreground='#9ece6a'></span> ${USAGE}%\"}"
