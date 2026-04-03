#!/usr/bin/env bash

layout=$(echo "scrolling|master|dwindle|monocle" | rofi -dmenu -sep '|')

# Exit if nothing was selected
[ -z "$layout" ] && exit 0

ID=$(hyprctl -j activeworkspace | jq '.id')
hyprctl keyword workspace $ID, layout:$layout
