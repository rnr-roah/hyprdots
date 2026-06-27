#!/usr/bin/env bash

# Normal mode: regular bar, native res, restore visuals

pkill -x waybar
sleep 0.2


~/.config/hypr/scripts/wallpaper-restore.sh & disown

pkill -x hypridle & disown
sleep 0.2
hypridle & disown

hyprctl eval '
hl.monitor({
    output = "eDP-1",
    mode = "2880x1800@120",
    position = "0x0",
    scale = "1.5",
})

hl.config({
    decoration = {
        rounding = 10,
        blur = {
            enabled = true,
        },
    },
    animations = {
        enabled = true,
    },
    general = {
        gaps_in = 5,
        gaps_out = 20,
    },
})
'

exit 0
