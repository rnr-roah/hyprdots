#!/bin/bash

# Name of the process
PROC="waybar_powerbar"

# Check if running
if pgrep -f "$PROC" > /dev/null; then
    # Kill the bar
    pkill -f "$PROC"
else
    # Launch the bar
    exec -a waybar_powerbar waybar \
        -c ~/.config/waybar/menu/powerbar/config \
        -s ~/.config/waybar/menu/powerbar/style.css &
fi

