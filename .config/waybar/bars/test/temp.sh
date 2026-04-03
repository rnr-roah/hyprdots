#!/usr/bin/env bash
STATE_FILE="$HOME/.cache/center_expand_state"
[[ ! -f "$STATE_FILE" ]] && echo '{"text": ""}' && exit 0
STATE=$(<"$STATE_FILE")
[[ "$STATE" == "hidden" ]] && echo '{"text": ""}' && exit 0

TEMP=$(sensors | grep 'Package id 0' | awk '{print int($4)}' 2>/dev/null)
[[ -z "$TEMP" ]] && TEMP=$(sensors | grep 'Tdie' | awk '{print int($2)}' 2>/dev/null)
[[ -z "$TEMP" ]] && TEMP="N/A"
echo "{\"text\": \" ${TEMP}°C\"}"
