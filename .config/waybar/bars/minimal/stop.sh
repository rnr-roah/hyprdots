#!/bin/env bash
#!/bin/bash

pkill -x waybar
waybar & disown
hyprctl reload
~/.config/hypr/scripts/wallpaper-restore.sh
hypridle & disown
exit
