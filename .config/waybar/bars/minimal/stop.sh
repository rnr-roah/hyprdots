#!/bin/env bash
#!/bin/bash

pkill -x waybar
waybar & disown
hyprctl reload
swaybg -i /home/roah/Wallpapers/default/background.png -m fill
exit
