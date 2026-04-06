#!/bin/bash

FRAMES_PLAY=("󰽲" "󰽲" "󰽲" "󰽵" "󰽵" "󰽵")
#FRAMES_PLAY=("·" "▪" "◆" "" "" "▪" "" "·")
#FRAMES_PLAY=("󰄰" "󰪞" "󰪟" "󰪠" "󰪡" "󰪢" "󰪣" "󰪤" "󰪥")
i=0

while true; do
  STATUS=$(playerctl -a status 2>/dev/null | grep -m1 -E 'Playing|Paused')

  if [ -z "$STATUS" ]; then
    echo ""
    sleep 1
    continue
  fi

  if [ "$STATUS" = "Paused" ]; then
    echo ""
    sleep 0.5
    continue
  fi

  echo "${FRAMES_PLAY[$i]}"
  i=$(( (i + 1) % ${#FRAMES_PLAY[@]} ))
  sleep 0.12
done
