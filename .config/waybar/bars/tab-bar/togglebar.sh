#!/bin/bash

pkill waybar

waybar -c ~/.config/waybar/tab-bar/config -s ~/.config/waybar/tab-bar/style.css &
sleep 0.5
waybar -c ~/.config/waybar/tab-bar/right-tab/config -s ~/.config/waybar/tab-bar/right-tab/style.css &

