#!/usr/bin/env bash
STATE_FILE="$HOME/.cache/center_expand_state"
[[ ! -f "$STATE_FILE" ]] && echo '{"text": ""}' && exit 0
STATE=$(<"$STATE_FILE")
[[ "$STATE" == "hidden" ]] && echo '{"text": ""}' && exit 0

USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print int($2)}')
echo "{\"text\": \"<span foreground='#ff005f'></span> ${USAGE}%\"}"
