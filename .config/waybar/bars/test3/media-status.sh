#!/bin/bash
# Outputs JSON for waybar only when media is actively playing/paused
# Shows nothing (empty) when no player is active

STATUS=$(playerctl status 2>/dev/null)

if [ -z "$STATUS" ] || [ "$STATUS" = "Stopped" ]; then
  echo ""
  exit 0
fi

MUTED=$(pactl get-sink-mute @DEFAULT_SINK@ | grep -c "yes")

if [ "$MUTED" -eq 1 ]; then
  MUTE_ICON="󰝟"
  MUTE_CLASS="muted"
else
  MUTE_ICON="󰕾"
  MUTE_CLASS="unmuted"
fi

if [ "$STATUS" = "Playing" ]; then
  PLAY_ICON=""
  CLASS="playing"
else
  PLAY_ICON=""
  CLASS="paused"
fi

echo "{\"text\": \"  $PLAY_ICON  \", \"class\": \"$CLASS\", \"alt\": \"$MUTE_ICON\", \"tooltip\": \"$STATUS\"}"
