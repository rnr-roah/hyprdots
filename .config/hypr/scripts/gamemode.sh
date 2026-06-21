#!/usr/bin/env bash

# Game mode: minimal bar, lower res, no eye candy

pkill -x waybar
sleep 0.2

waybar \
  -c "$HOME/.config/waybar/bars/minimal/config" \
  -s "$HOME/.config/waybar/bars/minimal/style.css" & disown

pkill -f mpvpaper
pkill -f hypridle

hyprctl eval '
hl.monitor({
    output = "eDP-1",
    mode = "1920x1200@120",
    position = "0x0",
    scale = "1",
})

hl.config({
    decoration = {
        rounding = 0,
        blur = {
            enabled = false,
        },
    },
    animations = {
        enabled = false,
    },
    general = {
        gaps_in = 0,
        gaps_out = 0,
    },
})
'

powerprofilesctl set balanced

exit 0
