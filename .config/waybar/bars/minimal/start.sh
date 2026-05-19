#!/bin/env bash
pkill -x waybar
waybar -c ~/.config/waybar/bars/minimal/config -s ~/.config/waybar/bars/minimal/style.css & disown
hyprctl keyword monitor "eDP-1,1920x1200@120,0x0,1"
pkill mpvpaper
hyprctl keyword decoration:rounding 0
hyprctl keyword animations:enabled false
hyprctl keyword decoration:blur:enabled false
hyprctl keyword general:gaps_in 0
hyprctl keyword general:gaps_out 0
powerprofilesctl set balanced
exit
