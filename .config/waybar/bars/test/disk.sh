#!/usr/bin/env bash
STATE_FILE="$HOME/.cache/center_expand_state"
[[ ! -f "$STATE_FILE" ]] && echo '{"text": ""}' && exit 0
STATE=$(<"$STATE_FILE")
[[ "$STATE" == "hidden" ]] && echo '{"text": ""}' && exit 0

USAGE=$(df -h / | awk 'NR==2 {print $5}' | tr -d '%')
echo "{\"text\": \"<span foreground='#68b0d6'> </span> ${USAGE}%\"}"
