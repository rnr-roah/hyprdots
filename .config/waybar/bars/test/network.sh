#!/usr/bin/env bash
STATE_FILE="$HOME/.cache/center_expand_state"
[[ ! -f "$STATE_FILE" ]] && echo '{"text": ""}' && exit 0
STATE=$(<"$STATE_FILE")
[[ "$STATE" == "hidden" ]] && echo '{"text": ""}' && exit 0

SSID=$(iwgetid -r 2>/dev/null)
[[ -z "$SSID" ]] && SSID="disconnected"
echo "{\"text\": \" ${SSID}\"}"
