#!/bin/env bash
#!/bin/bash
pkill -x waybar
waybar -c ~/.config/waybar/bars/minimal/config -s ~/.config/waybar/bars/minimal/style.css & disown

hyprctl keyword decoration:rounding 0
hyprctl keyword animations:enabled false
hyprctl keyword decoration:blur:enabled false
hyprctl keyword general:gaps_in 0
hyprctl keyword general:gaps_out 0
swaybg -i '/home/roah/Wallpapers/New Project.png'  -m fill
exit
